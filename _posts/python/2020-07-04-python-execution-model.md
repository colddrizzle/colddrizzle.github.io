---
layout: post
title: python执行模型
description: ""
category: python
tags: [python]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

本文是对python2标准文档中Language References中Execution Model一节的翻译与注解。


## 原文以及翻译

Names refer to objects. Names are introduced by name binding operations. Each occurrence of a name in the program text refers to the binding of that name established in the innermost function block containing the use.

名字（names）用来引用对象（objects）。名字本身通过名字绑定（name binding）引用进来。对于程序文本中中任意一个名字，其对应的是包含这个名字的最内部的函数块所绑定的名字引用。

A block is a piece of Python program text that is executed as a unit. The following are blocks: a module, a function body, and a class definition. Each command typed interactively is a block. A script file (a file given as standard input to the interpreter or specified on the interpreter command line the first argument) is a code block. A script command (a command specified on the interpreter command line with the ‘-c’ option) is a code block. The file read by the built-in function execfile() is a code block. The string argument passed to the built-in function eval() and to the exec statement is a code block. The expression read and evaluated by the built-in function input() is a code block.

代码块（code block）是作为一个单位执行的一小块python程序。下面这些都是代码块：一个模块、一个函数体、一个类定义。交互式环境下每一个命令都是一个代码块。 一个代码文件是一个代码块。一个以`-c`传入的命令串是一个代码块。被内建函数`execfile`读取的文件是一个代码块。传递给内建函数`eval`或`exec`语句的字符串是一个代码块。被内建函数`input`读取执行的表达式是一个代码块。

A code block is executed in an execution frame. A frame contains some administrative information (used for debugging) and determines where and how execution continues after the code block’s execution has completed.

代码块在一个执行帧（execution frame）中被执行。

A scope defines the visibility of a name within a block. If a local variable is defined in a block, its scope includes that block. If the definition occurs in a function block, the scope extends to any blocks contained within the defining one, unless a contained block introduces a different binding for the name. The scope of names defined in a class block is limited to the class block; it does not extend to the code blocks of methods – this includes generator expressions since they are implemented using a function scope. This means that the following will fail:

```
class A:
    a = 42
    b = list(a + i for i in range(10))
```

When a name is used in a code block, it is resolved using the nearest enclosing scope. The set of all such scopes visible to a code block is called the block’s environment.

作用域（scope）定义一个名字在一个代码块内的可见性。如果一个本地变量（local variable）定义在一个代码块中，那它的作用域就包括那个代码块。
如果变量定义出现一个函数块中，它的作用域扩展到任何包含在这个函数块中的代码块中，除非被包含的代码块引入了该变量名的一个不同绑定。定义在类定义块（class block）中的名字作用域局限在类定义块之内，并不会扩展到类定义中方法块里面去--这其中包括生成器表达式，因为它们使用函数作用域。这意味着如下的代码将会失败：


```brush:python
class A:
	a = 42
	b = list( a + i for i in range(10) )
```

	补充：如果一个变量定义在文件中（不在任何类、函数块内），它的作用域会扩展到文件包含的所有类与函数中去，并且会递归的扩展。这意味着上面的例子中将a定义在外面就能正常引用(看起来好像a穿透了class A的作用域)：

	a = 42
	class A:
		b = list( a + i for i in range(10) )


当名字a在一个代码块中使用的时候，它使用最近的包含它的封闭作用域（the nearest enclosing scope）来解析。所有对一个代码块可见的作用域叫做这个代码块的执行环境（the block's environment）。

以上内容用一幅图来表达就是：
![img](/assets/resources/python-scopes.png){:width="100%"}

从图中可见，定义在函数与文件中非常相似，都会向其包含的代码块扩展。

If a name is bound in a block, it is a local variable of that block. If a name is bound at the module level, it is a global variable. (The variables of the module code block are local and global.) If a variable is used in a code block but not defined there, it is a free variable.

如果一个名字在一个代码块内被绑定，它就是那个代码块的一个局部变量(local variable)。如果一个名字绑定在模块级别，它就是一个全局变量（global variable）。（模块代码块中定义的变量既是局部的，也是全局的）。如果一个变量
在一个代码块中被使用却没有被定义在同一个代码块，它就是一个自由变量（free variable）。

	模块代码块中定义的名字既是局部的，也是全局的，实际上，有理由相信在这种个情况下globals其实是对locals的引用。通常这不会有什么问题，
	但在exec函数中，可以自定义globals与locals，差别就显现出来了。更多参考《python exec()与名字解析》篇。


When a name is not found at all, a NameError exception is raised. If the name refers to a local variable that has not been bound, a UnboundLocalError exception is raised. UnboundLocalError is a subclass of NameError.

当一个名字最终没有被找到，python运行时就会抛出一个NameError异常。如果一个名字引用一个未被绑定的局部变量，就抛出一个UnboundLocalError异常。UnboundLocalError是NameError的子类。

	问题：什么叫“引用一个未被绑定的局部变量”？
	def foo():
    	a = a + 1
	foo()
	这段代码就会抛出UnboundLocalError，Python中并不区分赋值与定义，a = 实际上定义了局部变量，但在定义a变量的过程中又在同一个作用域引用了a变量。
	同样，下面这段代码也会同样报错：
	def foo():
    	print a
    	a = 1
	foo()

The following constructs bind names: formal parameters to functions, import statements, class and function definitions (these bind the class or function name in the defining block), and targets that are identifiers if occurring in an assignment, for loop header, in the second position of an except clause header or after as in a with statement. The import statement of the form from ... import * binds all names defined in the imported module, except those beginning with an underscore. This form may only be used at the module level.

下面这些用法或形式会绑定名字：函数形参、导入语言、类与函数定义（将类与函数名绑定其定义所在的代码块）、目标是标识符的赋值语句、for循环头内声明的变量（绑定在for所在的代码块）、except语句后面的第二个位置的标识符、with语句的as后面的标志符。形如`from ... import *`的导入语句将被导入模块内的所有名字绑定到导入语句所在代码块，除了那些以下划线开头的名字。这种形式可能只会被用在模块级别。

A target occurring in a del statement is also considered bound for this purpose (though the actual semantics are to unbind the name). It is illegal to unbind a name that is referenced by an enclosing scope; the compiler will report a SyntaxError.

出现在del语句中的目标也被认为是名字绑定（虽然实际的语义是解除绑定）。解绑定一个被封闭作用域引用的名字是非法的，编译器将会报告SyntaxError。

Each assignment or import statement occurs within a block defined by a class or function definition or at the module level (the top-level code block).

赋值或导入语句可以出现在类或者函数定义块中，或者模块级别（最顶级的代码块）。

If a name binding operation occurs anywhere within a code block, all uses of the name within the block are treated as references to the current block. This can lead to errors when a name is used within a block before it is bound. This rule is subtle. Python lacks declarations and allows name binding operations to occur anywhere within a code block. The local variables of a code block can be determined by scanning the entire text of the block for name binding operations.

如果一个名字绑定操作出现在一个代码块的任意一个位置，这个代码块中这个名字的所有使用都被视为对当前代码块的引用。当代码块内一个名字使用在绑定之前的时候，就会导致错误。这条规则很微妙。python缺少声明语法并且允许名字绑定操作出现在代码块的任意位置。一个代码块的局部变量可以通过扫描整个代码块中所有的名字绑定操作来确定。

If the global statement occurs within a block, all uses of the name specified in the statement refer to the binding of that name in the top-level namespace. Names are resolved in the top-level namespace by searching the global namespace, i.e. the namespace of the module containing the code block, and the builtins namespace, the namespace of the module __builtin__. The global namespace is searched first. If the name is not found there, the builtins namespace is searched. The global statement must precede all uses of the name.

对于出现在代码块中的`global`语句，该语句内使用的所有名字都会去引用顶级命名空间中绑定的那个名字。通过搜索全局命名空间来解析顶级命名空间中的名字，这就是说，包含那个代码块的模块的命名空间、builtins命名空间--模块`__builtin__`的命名空间。首先搜索globals命名空间。如果名字没有找到，然后再去builtins命名空间中去找。`global`语句必须出现在所有对它的使用之前。（补充：global语句仅仅在该语句所在的代码块生效）

The builtins namespace associated with the execution of a code block is actually found by looking up the name `__builtins__` in its global namespace; this should be a dictionary or a module (in the latter case the module’s dictionary is used). By default, when in the `__main__` module, `__builtins__` is the built-in module `__builtin__` (note: no ‘s’); when in any other module, `__builtins__` is an alias for the dictionary of the `__builtin__` module itself. `__builtins__` can be set to a user-created dictionary to create a weak form of restricted execution.

与一个代码块执行时关联的builtins命名空间实际上是通过查找其全局命名空间(globals变量)中的`__builtins__`来实现的。builtins命名空间必须是一个字段或者一个模块（后者实际使用的是模块的字典）。默认情况下，在`__main__`模块中，`__builtins__`变量是内建模块`__builtin__`；在任何其他模块中，变量`__builtins__`是`__builtin__`模块字段的别名。`__builtins__`可以被设置成用户自定义的一个字典来创建一种弱形式的受限执行。

	CPython implementation detail: Users should not touch __builtins__; it is strictly an implementation detail. Users wanting to override values in the builtins namespace should import the __builtin__ (no ‘s’) module and modify its attributes appropriately.

	Cpython实现细节：用户不应该更改__builtins__；它完全是一个实现细节。用户想要覆盖builtins命名空间应该通过引用__builtin__模块并适当修改器属性来实现。

The namespace for a module is automatically created the first time a module is imported. The main module for a script is always called `__main__`.

当模块第一次被导入的时候，模块的命名空间就被自动建立起来。脚本的main模块总是被命名为`__main__`。

The global statement has the same scope as a name binding operation in the same block. If the nearest enclosing scope for a free variable contains a global statement, the free variable is treated as a global.

`global`语句作为一个名字绑定操作在同一个代码块内总是有相同的作用域，而与global语句出现在代码块内的位置无关。如果一个自由变量最近的封闭作用域含有一个该变量global声明，这个自由变量也会被当做全局变量。

	这两句话很难理解，上面的翻译是根据后面的链接的解释调整后的： https://stackoverflow.com/questions/45068028/scope-of-a-global-statement 


A class definition is an executable statement that may use and define names. These references follow the normal rules for name resolution. The namespace of the class definition becomes the attribute dictionary of the class. Names defined at the class scope are not visible in methods.

一个类定义是一个可执行语句，其中可能定义或者使用名字。这些引用遵循名字解析的一般规则。类定义的名字空间称为类的属性字典。类定义域内定义的名字在方法中不可见。

## 问答
1. Q: 什么是自由变量？

A: 本文中有定义：在代码块中使用但未定义。

但还有另一种看法，根据[stackoverflow上的一个回答][2]，自由变量是指在本代码块中有使用且未在globals中找到但最终又在运行时某个封闭作用域内找到绑定的名字。

仔细理解下这个定义，如果在本代码块中有定义且未在globals中有定义，那么这个名字未定义，所以但是未定义不是自由变量，因此自由变量最终要在某个封闭作用域（一定是封闭作用域，因为类作用域不向下扩展，而只有三种作用域：module、class、封闭作用域（函数或lambda或生成器表达式））内找到定义。

其实我认为文档的说法比较根本，而stackoverflow中的回答只是解释了为什么我们在locals()函数或者`sys._getframe().f_code.vo_freevars`中看不到“使用但不定义在此处”的全局变量---仅仅是因为这些名字最终在全局名字空间中被找到了。

其实这两种理解哪种准确不重要，最重要的是上文python标准文档中下面这句话：

	When a name is used in a code block, it is resolved using the nearest enclosing scope.

这条规则总是成立的，除非用上面这条规则往上一层层做名字解析的时候，发现不再有封闭作用域仍未找到（此前找到的就成自由变量了），这时候就从globals中去找，globals中也找不到，就报错了。

正确的理解了自由变量，那么闭包就很好理解了，所谓闭包就是内部函数引用外部函数变量作为自由变量的函数。关于闭包更多可参考[http://zetcode.com/python/python-closures/][10]。

stackoverflow中比较有意思的一点是提到了一种“伪全局自由变量”的情况，以下部分也来自该问答：

Code 1:
```brush:python
x = 0
def foo():
	print(x)
	print(locals())

foo()
```
Code 2:
```brush:python
def bar():
	x = 1
	def foo():
		print(x)
		print(locals())
	foo()
bar()
```

Definition of a free variable: Used, but neither global nor bound.
For example:

x is not free in Code 1, because it's a global variable.
x is not free in bar() in Code 2, because it's a bound variable.
x is free in foo().
Python makes this distinction because of closures. A free variable is not defined in the current environment, i. e. collection of local variables, and is also not a global variable! Therefore it must be defined elsewhere. And this is the concept of closures. In Code 2, foo() closes on x defined in bar(). Python uses lexical scope. This means, the interpreter is able to determine the scope by just looking at the code.

For example: x is known as a variable in foo(), because foo() is enclosed by bar(), and x is bound in bar().

Global scope is treated specially by Python. It would be possible to view the global scope as an outermost scope, but this is not done because of performance (I think). Therefore it is not possible that x is both free and global.

Exemption

Life is not so simple. There exist free global variables. Python docs (Execution model) says:
	
	The global statement has the same scope as a name binding operation in the same block. If the nearest enclosing scope for a free variable contains a global statement, the free variable is treated as a global.

```brush:python
x = 42
def foo()
	global x
	def baz():
		print(x)
		print(locals())
	baz()

foo()
```

关于自由变量值得注意的有两点，一是上本提到过的自由变量的解析是在运行时进行的，编译时仅仅能确定一个名字是否自由变量，但是没有相应的绑定。

```brush:python
source="""
def bar():
	x = 1
	def foo():
		print(x)
		print(locals())
	foo()
bar()
"""
code = compile(source,"example.py", "exec")
print code.co_consts
print code.co_consts[0].co_consts
print code.co_consts[0].co_consts[2].co_freevars

```
上面代码可以看出编译时就知道了是否是自由变量。

p3的[文档][6]中提到了自由变量在运行时进行名字解析。这意味着下面的代码结果是42。

```brush:python
i = 10
def f():
    print(i)
i = 42
f()

```

2. Q: 什么是the enclosing scope？

A: python文档与pep中并未给出定义，似乎是计算机语言学中既有的说法，但可以参考[stackoverflow][5]:Names assigned in the local scope of any and all statically enclosing functions (def or lambda), from inner to outer.

3. Q: 名字空间、作用域、执行环境怎么区分？

A: 每个PyFrameObject有三个名字空间：builtins、locals、globals。 变量比如定义在代码块中，在这个代码块以及包含的代码块中该变量的可见性就叫做该变量的作用域，作用域只会向内扩展，不会向外扩展。
因为作用域会扩展，一个代码块可以看到来自代码块外的变量，该代码块所看到的所有变量就叫做该代码块的执行环境。这个执行环境划定了这个代码块可以看到的所有变量。

4. Q: 什么是builtins、locals、globals名字空间？
内建模块__builtins__中的名字会被放在一个单独的名字空间中，被每一个PyFrameObject以builtins引用。
直接（不包括嵌套）在代码块中声明的变量就是该代码快的locals命名空间。
代码块所在的模块中定义（或者通过import引入）的名字就是globals名字空间。

注意三个命名空间并未包含该代码块可以看到的所有变量。比如下面这个例子：

```brush:python
import sys
a = 1
def foo():
    b = 1
    def inner():
        c = 1
        print sys._getframe().f_locals.keys()
        print sys._getframe().f_globals.keys()
        print sys._getframe().f_code.co_freevars
        print b

    inner()

foo()
```

变量b不在函数inner的三个命名空间中，但是函数inner可以引用b。实际上b是inner代码块的自由变量（free variable）。

但这也验证了上文说的名字解析的方式：When a name is used in a code block, it is resolved using the nearest enclosing scope. 可以看到封闭作用域是层层嵌套的，
对于一个名字，解析的时候一层层往上找（因为是函数嵌套，通过PyFrameObject的f_back字段很容易找到其调用者也就是外层封闭作用域），如果在一层作用域的locals中找到就绑定，
最后在globals中寻找或者最终找不到。

5. Q: 名字绑定是什么？

A: 所谓名字绑定就是将名字放到其作用域内各个代码块的三个名字空间的过程。一个名字只能被绑定到模块级别称为全局变量，或者被绑定到代码块级别称为该代码块局部变量。

6. Q:名字绑定与解析的一般规则是什么？

A: LEGB规则。参考[stackoverflow][5]。 关于绑定，以为python是以为文件为单位编译的，而文件是module级别的，定义在module级别的名字都是全局变量，定义在非module基本的都是local变量，
因此编译的时候python就能确定哪些名字是全局并绑定，哪些名字是local并绑定，确定哪些名字是自由变量但是不绑定或者说解析，自由变量的解析是运行时依照LEGB运行的（除了exec中的自由变量，参考《python exec()与名字解析》篇）

7. Q: 更多关于global语句

A:参考标准文档:[global statement][1]。
global语句仅仅是做名字解析的时候去globals名字空间去找，并非将该名字绑定到globals名字空间。

8. Q: 关于P3中新增的nolocal语句。

A: 参考[简谈Python3关键字nonlocal使用场景][7]。[stackoverflow:Why doesn't Python's nonlocal keyword like the global scope?][9]。

9. Q: 关于locals()语义的理解。[p3文档][8]提到:Free variables are returned by locals() when it is called in function blocks。有人据此在bugs.python.org提了两个[issue 28853][3]与[issue 26683][4]，
认为locals的语义不清，其实我认为就是因为locals实现将那些最终在globals中找到的自由变量不算做自由变量了。

## MORE
更多资料：

https://www.datacamp.com/community/tutorials/scope-of-variables-python

https://realpython.com/python-scope-legb-rule/

https://pythonpedia.com/en/tutorial/263/variable-scope-and-binding


[0]:https://docs.python.org/2.7/reference/executionmodel.html
[1]:https://docs.python.org/2.7/reference/simple_stmts.html#the-global-statement
[2]:https://stackoverflow.com/questions/12919278/how-to-define-free-variable-in-python
[3]:https://bugs.python.org/issue28853
[4]:https://bugs.python.org/issue26683
[5]:https://stackoverflow.com/questions/291978/short-description-of-the-scoping-rules
[6]:https://docs.python.org/3/reference/executionmodel.html#interaction-with-dynamic-features
[7]:https://zhuanlan.zhihu.com/p/96508259
[8]:https://docs.python.org/3/library/functions.html#locals
[9]:https://stackoverflow.com/questions/16873615/why-doesnt-pythons-nonlocal-keyword-like-the-global-scope
[10]:http://zetcode.com/python/python-closures/