---
layout: post
title: python中函数、方法的cpython视角
description: ""
category: python
tags: [python,cpython]
---
{% include JB/setup %}


<hr />

## 一、函数与方法的根本
从cpython层面看,所有的可执行逻辑最后一定是一个c函数或者一个python字节满函数。
在cpython中，这分别由两种类型实例来实现:PyCFunction_Type与PyFunction_Type。其中PyFunction_Type定义tp_descr_get函数，因而是一个描述符，该描述符接受一个obj与一个type类型将函数绑定到实例obj上,返回一个PyMethod_Type的实例，指的注意的是这一步是在访问该方法从而触发描述符协议的时候发生的，class对象的字典里存储的仍然是一个函数，这个下面会细说。

由此可见所有的函数或方法的调用操作，最终都是一个PyObject的调用操作，而所有的PyObject的调用操作执行逻辑都是一样的，定义在[PyObject_Call][4]函数中，其大致逻辑相当于如下:
```
 aPyObject(args) => type(aPyObject)->tp_call(aPyObject, args)
```

## 二、细分
下面我们根据函数定义与出现的位置不同，分别从cpython层面观察一个函数是如何被执行的。

### 1、内建函数
根据[源码][0],所有的内建函数被定义成了PyMethodDef结构体的数组。需要注意的是这个函数列表与[python文档][1]中内建函数的列表并不完全一致，原因是python文档中的内建函数列表严格来讲并不都是函数，`type()`看起来是个函数，实际上是python最顶层的那个`type`类型。这个PyMethodDef函数列表在[python启动时][2]被初始化。从[初始化逻辑][3]来看，这些函数分别包装成PyCFunctionObject填充到模块`__builtin__`的字典中。

当打开python交互式窗口的时候，模块`__builtin__`就被自动导入到当前`__main__`模块中。于是当访问内建函数的时候，就会调用`PyModule_Type`的`tp_getattro`也就是`PyObject_GenericGetAttr`来访问该函数。注意PyCFunction_Type不是描述符类型。

拿到PyCFunctionObject之后，python解释器接着就是处理`()`操作符，最终以拿到的PyCFunctionObject为参数调用PyCFunction_Call()函数。

### 2、自定义函数
当python解释器遇到在模块层面定义的函数的时候，将其包装成一个PyFunctionObject设置到当前模块的`tp_dict`中。余下就跟内建函数一样了。
需要注意的是，虽然PyFunction_Type是描述符，但**描述符协议只有在访问类型属性时才会触发**，因此从模块中访问函数仍然得到的是PyFunctionObject。

### 3、类型中的内建方法
内建方法可以分为两类：一类通过slots，一类为c函数。slots与c函数的区别在于，slots最终的函数逻辑不一定是c语言实现的，大部分仅仅是一个桥接作用。

#### 1、slots原理
所有的类型公用一套slots定义，在类创建完执行PyType_Ready()的[add_operators()][5]方法时，将类型定义了值的字段包装成一个`PyWrapperDescrObject`对象，该对象是一个描述符。
当访问该函数触发描述符协议后，首先利用PyWrapper_New()函数，将PyWrapperDescrObject与当前self包装成一个`wrappertype`也就是`method-wrapper`对象，然后调用该对象，也就是以之为参数调用PyObject_Call，最终执行wrappertype的tp_call函数，也就是wrapper_call。
```
static PyObject *
wrapper_call(wrapperobject *wp, PyObject *args, PyObject *kwds)
{
    wrapperfunc wrapper = wp->descr->d_base->wrapper;
    PyObject *self = wp->self;

    if (wp->descr->d_base->flags & PyWrapperFlag_KEYWORDS) {
        wrapperfunc_kwds wk = (wrapperfunc_kwds)wrapper;
        return (*wk)(self, args, wp->descr->d_wrapped, kwds);
    }

    if (kwds != NULL && (!PyDict_Check(kwds) || PyDict_Size(kwds) != 0)) {
        PyErr_Format(PyExc_TypeError,
                     "wrapper %s doesn't take keyword arguments",
                     wp->descr->d_base->name);
        return NULL;
    }
    return (*wrapper)(self, args, wp->descr->d_wrapped);
}
```

如上图，wrapper是定义于slotdef的检测参数与返回值的包装函数，d_wrapped是实际执行的逻辑。` (*wrapper)(self, args, wp->descr->d_wrapped)`可以近似看做是
`check_args(); wp->descr->d_wrapped(self, args); check_results();`

#### 2、c函数实现原理
以list对象的append方法为例，在listobject.c中定义了[PyMethodDef数组][6]，
类型创建的PyType_Ready()方法中[add_methods][7]方法分别被包装成静态方法、类方法、与实例方法。我们重点关注实例方法。c函数实现的实例方法被包装成`PyMethodDescrObject`，该对象是一个描述符。当触发描述符协议时，若待绑定obj为null，则返回描述符本身，若不为null，则返回一个绑定的PyCFunctionObject。如图:

![img]()


### 4、类型中的自定义方法


## 三、场景分析
* 无穷__call__?

*



[0]:https://github.com/python/cpython/blob/2.7/Python/bltinmodule.c#L2626
[1]:https://docs.python.org/2/library/functions.html
[2]:https://github.com/python/cpython/blob/2.7/Python/bltinmodule.c#L2689
[3]:https://github.com/python/cpython/blob/2.7/Python/modsupport.c#L31
[4]:https://github.com/python/cpython/blob/2.7/Objects/abstract.c#L2536
[5]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L6566
[6]:https://github.com/python/cpython/blob/2.7/Objects/listobject.c#L2510
[7]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L3726
