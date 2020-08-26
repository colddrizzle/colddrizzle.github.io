---
layout: post
title: python虚拟机框架与运行环境初始化
description: ""
category: python
tags: [python,cpython]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

本篇文章关注的重点是python代码是如何跑起来的，或者详细点说，python虚拟机本身的大致结构以及是如何处理python代码的。
本质上是《Python源码剖析》的读书笔记。

也许你注意到了标题“虚拟机”这个词，是的，python并不是一门通常意义上的解释型语言，python更像是一门编译型语言。cpython会首先把
python代码编译成字节码，再扔到虚拟机里去执行。如果拿真实机器来对应，字节码就是汇编代码，虚拟机就是CPU与内存构成的裸机。

# python代码的编译与运行
python源码py文件会先编译成pyc文件。py文件是python代码无疑，而pyc文件其实是整个源文件对应的PyCodeObject对象的2进制存储，或者说是用C语言
层面的逻辑把python代码重新组织了一边，毕竟将python代码结构化才能处理。
## python源码、PyCodeObject、Pyc文件相互转换
根据以下四种方法可以得知转换方法。

* 使用内建函数`compile` 该方法直接返回一个PyCodeObject对象

* 使用`py_compile`模块的`compile` 该方法编译并写到pyc文件，其实这个模块是对内建函数`compile`的简单封装。该方法可以看到一个
PyCodeObject是如何被写成文件的。据此我们可以反推出如何读取一个pyc文件得到PyCodeObject对象。pyc文件的开头是一个Long类型的MagicNumber和
一个Long类型的timestamp，在Long为4字节的平台上，可以简单的如下读取出PyCodeObject对象。

```brush:python
    fc = open(filename)
    fc.seek(8)
    code = marshal.load(fc)
```

* 使用`compiler`模块的`compile`方法。`compiler`模块属于Python Compiler Package，是对Python Language Services的简单封装，
在python3中以及被移除，Python Language Services暴露了python内部语法树、符号表等一些编译中间过程接口。

* 使用`imp`模块的`load_module`方法，该模块是内建模块，没有对应的python代码。`imp`暴露了内部`import`的一些接口，通过返回的Module对象获取Code对象。使用该模块读取Code对象，会同时加载在python实例中加载该模块。


## 执行PyCodeObject对象
Python层面，使用内建函数`eval`来执行code对象，参见[标准文档][0]。是的，`eval`不仅可以接受源码，也可以接受编译好的code对象。

C层面，使用接口`PyEval_EvalCodeEx`，参见[标准文档][1]。


## 代码块与code对象、frame对象对应关系

根据Python标准文档语言参考中执行模型一节可以知道：一个代码块编译成一个PyCodeObject，而一个PyCodeObject对应一个运行时的PyFrameObject。

	A block is a piece of Python program text that is executed as a unit. The following are blocks: a module, a function body, and a class definition. Each command typed interactively is a block. A script file (a file given as standard input to the interpreter or specified on the interpreter command line the first argument) is a code block. A script command (a command specified on the interpreter command line with the ‘-c’ option) is a code block. The file read by the built-in function execfile() is a code block. The string argument passed to the built-in function eval() and to the exec statement is a code block. The expression read and evaluated by the built-in function input() is a code block.

	A code block is executed in an execution frame. A frame contains some administrative information (used for debugging) and determines where and how execution continues after the code block’s execution has completed.

## PyCodeObject的嵌套

上节讲到一个类定义、函数定义都会形成一个单独的代码块，对应一个PyCodeObject，而一个源文件编译后只产生了一个pyc文件，原因就是PyCodeObject在pyc中是依照源码嵌套关系嵌套存储的。下层的PyCodeObject放在上层的`consts`字段中。

# 虚拟机组成与运行框架

## 基础组成部分

### PyCodeObject

[PyCodeObject][2] 包含程序所有的静态信息：字节码、变量名、变量值、对外部变量的引用、常量等

变量、常量信息实际声明包含在PyCodeObject中。

部分字段如下：

```brush:c
    int co_nlocals;		/* #local variables */
    int co_stacksize;		/* #entries needed for evaluation stack */
    int co_flags;		/* CO_..., see below */
    PyObject *co_code;		/* instruction opcodes */
    PyObject *co_consts;	/* list (constants used) */
    PyObject *co_names;		/* list of strings (names used) */
    PyObject *co_varnames;	/* tuple of strings (local variable names) */
    PyObject *co_freevars;	/* tuple of strings (free variable names) */
    PyObject *co_cellvars;      /* tuple of strings (cell variable names) */
```
其中`co_flags`用于表示该代码块的特征，取值也在同一个源文件中：

* `co_nlocals`：定义在该代码块中的变量个数
* `co_stacksize`：运行本代码块需要的栈空间的大小（python虚拟机模拟了c语言运行栈，每个函数都需要一定的栈空间）
* `co_freevars`：本代码块的自由变量
* `co_cellvars`：为内部嵌套的代码块使用的本代码块的变量 与freevars正好对称

以上4部分在运行时建立PyFrameObject的时候会用到，下面会讲。

* co_code 字节码文件。python类库opcode.py中定义各种操作码，以及操作码的参数情况。
	标准库方法`dis.dis`用于反编译一个PyCodeObject，其中可以看到co_code详细格式。简单的说，co_code就类似汇编代码，每条代码由自己的地址以及操作数。
	当虚拟机执行一个PyFrameObject时，就从这里面循环取指令。

* co_consts 常量。本代码块定义的类、函数、变量都存储在这里（函数、类以另一个PyCodeObject的形式存在），只存储右值，co_code中的指令码操作数的地址就是这里面的地址。

* co_names 本代码块用到的所有的名字 这些名字最终被解析成globals、locals、builtins名字空间中的变量或自由变量。

* co_varnames 本代码块定义的变量的名字，也就是locals名字空间里的名字


### PyFrameObject

[PyFrameObject][3] 包含程序执行时的动态信息 比如self引用，外部变量等，其值要到运行时才能确定。

名字空间信息包含在PyFrameObject中，名字空间相当于变量的动态引用后的结果。

部分字段如下：

```brush:c
    PyObject *f_builtins;	/* builtin symbol table (PyDictObject) */
    PyObject *f_globals;	/* global symbol table (PyDictObject) */
    PyObject *f_locals;		/* local symbol table (any mapping) */

    PyObject **f_valuestack;	/* points after the last local */

    /* Next free slot in f_valuestack.  Frame creation sets to f_valuestack.
       Frame evaluation usually NULLs it, but a frame that yields sets it
       to the current stack top. */
    PyObject **f_stacktop;
    int f_lasti;		/* Last instruction if called */
    /* Call PyFrame_GetLineNumber() instead of reading this field
       directly.  As of 2.3 f_lineno is only valid when tracing is
       active (i.e. when f_trace is set).  At other times we use
       PyCode_Addr2Line to calculate the line from the current
       bytecode index. */
    int f_lineno;		/* Current line number */
    int f_iblock;		/* index in f_blockstack */
    PyTryBlock f_blockstack[CO_MAXBLOCKS]; /* for try and loop blocks */
    PyObject *f_localsplus[1];	/* locals+stack, dynamically sized */
```

我们来看下`f_valuestack`、`f_stacktop`、`f_localsplus`的含义与关系。

在[PyFrame_New][4]中可以找到如下代码：

```brush:c
        Py_ssize_t extras, ncells, nfrees;
        ncells = PyTuple_GET_SIZE(code->co_cellvars);
        nfrees = PyTuple_GET_SIZE(code->co_freevars);
        extras = code->co_stacksize + code->co_nlocals + ncells +
            nfrees;
        /** 省略 **/
        f = PyObject_GC_NewVar(PyFrameObject, &PyFrame_Type,extras);
        /** 省略 **/

        f->f_code = code;
        extras = code->co_nlocals + ncells + nfrees;
        f->f_valuestack = f->f_localsplus + extras;
```
可以看到extras包含4部分内容并且在申请PyFrameObject的内存的时候一并申请，成为PyFrameObject的一部分。

申请完内存随后就是PyFrameObject的初始化代码，我们看到extras重新计算为`code->co_nlocals + ncells + nfrees`三者的和，不再包括`code->co_stacksize`
这很容易理解，因为此时运行时栈还是空的。随后：

```brush:c
f->f_valuestack = f->f_localsplus + extras;
```

我们注意到`f_localsplus`是PyFrameObject的最后一个元素且是一个指针，可以推测出PyFrameObject申请时extras那4部分是附在PyFrameObject尾部的，并且
`f->f_valuestack`就是运行时栈的栈底部，而`f_stacktop`自然就是栈顶。用一副图来表示就是：

![img](/assets/resources/cpython-frame-memory.png)

在[ceval.c PyEval_EvalFrameEx][5]中，可以看到如下代码：

```brush:c
    freevars = f->f_localsplus + co->co_nlocals;
    first_instr = (unsigned char*) PyString_AS_STRING(co->co_code);

    /* An explanation is in order for the next line.
       f->f_lasti now refers to the index of the last instruction
       executed.  You might think this was obvious from the name, but
       this wasn't always true before 2.3!  PyFrame_New now sets
       f->f_lasti to -1 (i.e. the index *before* the first instruction)
       and YIELD_VALUE doesn't fiddle with f_lasti any more.  So this
       does work.  Promise.
       When the PREDICT() macros are enabled, some opcode pairs follow in
       direct succession without updating f->f_lasti.  A successful
       prediction effectively links the two codes together as if they
       were a single new opcode; accordingly,f->f_lasti will point to
       the first code in the pair (for instance, GET_ITER followed by
       FOR_ITER is effectively a single opcode and f->f_lasti will point
       at to the beginning of the combined pair.)
    */

    next_instr = first_instr + f->f_lasti + 1;
    stack_pointer = f->f_stacktop;
```

根据`freevars = f->f_localsplus + co->co_nlocals;`我们可以得知extras部分locals与freevars的排布顺序。

我们也可以是如何从co_code中取指令执行的。

下面两个组成都来自于[pystate.h][7]。其中PyInterpreterState用来表示解释器状态，相当于虚拟机这个进程状态。python支持多线程，而且是
操作系统的原生线程，因此多个线程就有多个字节码执行引擎，每一个都需要一个PyThreadState来跟踪其状态。

### PyInterpreterState

部分字段如下：

```brush:c
    PyObject *modules;
    PyObject *sysdict;
    PyObject *builtins;
    PyObject *modules_reloading;
```

可以看到一个虚拟机内各线程共用一份加载后的modules、sysdict（就是内建模块sys）与builtins内建函数。

### PyThreadState
最重要的字段如下：

```brush:c
	 struct _frame *frame;
```

这个`struct _frame`就是PyFrameObject，可见线程状态里存放在着第一个栈帧（栈帧随着嵌套调用通过f_back形成链状结构）

## 运行时访问PyFrameObject对象

可以通过sys模块中`sys._getframe()`方法访问PyFrameObject对象。

## 运行环境初始化

真个cpython就是一个c语言程序，其当然有过一个main函数，位置在`cpython/Modules/python.c`中，循着这个入口，我们可以找打cpython的主要初始化动作都在
[Py_InitializeEx][6]中。

具体参考《Python源码剖析》第13章，暂略。

从`PyEval_EvalFrameEx`开始，这是一个巨大的函数，取指，实现指令语义都在这里，是真正的字节码执行引擎。

## 宏观图
![img](/assets/resources/cpython_runtime.png){:width="100%"}

![img](/assets/resources/cpython_init_env.png){:width="100%"}

(老实讲书上这两幅图不够理想，有时间再自画一幅详细的框架结构图)

# 作用域规则与命名空间

以下部分都可以参考另一篇《python执行模型》，也可以参考《源码剖析》第8章后半部分。
## 词法作用域规则
## globals与locals作用域
## 命名空间与属性引用

问题：当用`from moduleA import classB`的时候，其实只把classB的名字引入了，但当classB内部又使用moduleA中的其他类、函数、属性的时候
是怎么进行查找的呢？

import语句包含两部分，查找模块以及绑定名字，当绑定classB到当前全局名字空间的时候，其实已经将模块moduleA加载到了系统缓存中（`sys.modules`）中。编译的时候，classB编译为一个PyCodeObject，当classB访问moudleA中其他东西时，必然是在自己Frame进行的，并且classB中有字段标记自己所来自的moduleA，classB的frame自然也根据moduleA构建了自己的全局名字空间（词法作用域），自然就可以访问了。

## LEGB名字查找规则


[0]:https://docs.python.org/2.7/library/functions.html#eval
[1]:https://docs.python.org/2.7/c-api/veryhigh.html?highlight=pycodeobject#c.PyEval_EvalCodeEx
[2]:https://github.com/python/cpython/blob/2.7/Include/code.h#L10
[3]:https://github.com/python/cpython/blob/2.7/Include/frameobject.h#L16
[4]:https://github.com/python/cpython/blob/2.7/Objects/frameobject.c#L712
[5]:https://github.com/python/cpython/blob/2.7/Python/ceval.c#L1024
[6]:https://github.com/python/cpython/blob/2.7/Python/pythonrun.c#L161
[7]:https://github.com/python/cpython/blob/2.7/Include/pystate.h