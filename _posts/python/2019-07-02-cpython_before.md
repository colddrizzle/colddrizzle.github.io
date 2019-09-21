---
layout: post
category : python
tagline: "Supporting tagline"
tags : [python, cpython]
title: cpython源码阅读前提条件
---
{% include JB/setup %}

这是一个结合cpython源码理解python语言机制的系列文章。
本篇是这些文章的一个准备样的东西。
<hr/>

在开始之前，先让我们抛弃真正的cpython源代码实现，引导自己思考来想象一下我们将会遇到的问题吧!
从问题出发有助于我们理解将要面临的处境。

首先，我们知道cpython是python的解释器c语言实现，也就是说我们的python代码将会作为cpython的输入，被cpython处理来实现python代码的真正运行。对于python来说，cpython就像一个虚拟机。一个python函数首先被cpython处理成一系列C函数，然后当python语言中发生该函数调用的时候就是调用这一系列的c函数，创建类、实例、访问属性也是如此。我们必须清楚的是，当cpython处理了python代码之后，实际上是将python代码转换成了一组c语言代码的表现形式，通过cpython的语法树的语义处理阶段，将python代码语义与c语言挂钩。

python是一种"Everything is object"的语言，c语言是一种面向过程的语言，期间必然有c语言模拟OOP的思想与实现，这是怎么实现的呢？python里面有内建函数与内建对象，还有python语言下用户自定义的函数、方法与类以及实例，那么在cpython的实现中，二者是怎么区分的呢或者没有区分的必要？

再者，为了清楚弄清cpython的运行免不了就要对其调试，当然官方文档有详细的工程构建、调试说明我们先放一边，首先在这里要清楚的意识到，对于cpython来说，python代码只是一串输出字符串，从c语言调试器的角度来看，是没有python语言层面的直观的对象与函数栈的概念的，当然官方有提供[工具][0]，但这些工具只是帮助我们从gdb调式中观察python层面的对象与栈，其调试断点本身还是在c语言层面的，并不能在python代码层面断点，然后看其在c语言层面的执行情况， 当然这一点是可以做到的，前提是需要cpython的支持，想象一下，在python代码层面打一个断点，并把这个断点告知cpython，当cpython执行到这个断点的时候，自己引发一个调试中断就可以了。有关调试中断的内容请参见XXXXXXXXXXXXXXXXXXXX？？？？？？？？？？？？？？

<hr/>

有了上面一些思考预热，我们对于接下来要做的事情、要探求的问题就有了基本方向。

## 搭建cpython调试环境
详细的过程参见[官方文档][1]。这里只说搭建过程中遇到的一些坑。本人使用的源码版本是2.7。本来打算在自己的mac上编译，我们知道mac上那套原生的c系语言编译系统是llvm\\clang那一套，官方也提供了使用clang编译的[支持][2]。然而由于我的mac osx系统版本是10.14比较新，mac在之前版本中抛弃了X11的支持，编译古老的python2.7的源码会被告知缺少Xlib.h头文件，google一番发现cpython邮件列表里有相同的问题被提出来，然而已经有大约5、6年没处理了，鉴于mac系统自成风格颇有古怪，于是放弃。转而在linux系统下构建，使用vscode加gdb的方式来调试，编译没有问题，然而vscode对于断点调试支持貌似有bug（毕竟vscode还是一个年轻的主要面向js开发的项目）。当然一边在命令行下使用gdb调试一边用vscode翻阅代码不是问题，但是来回切换窗口总是不方便，而且命令行下管理断点也是麻烦。于是又放弃。最终在window7系统下编译调试成功。

## 初步了解cpython源码结构
参考[官方文档][3]
## 当然是从对象开始
既然python语言中一切都是对象，python语言的这一哲学观有许多奇妙之处，建议在继续了解cpython之前先看这篇[有关python世界观的文章][4]，那么我们自然关心没有对象概念的c语言如何实现这一点，
而python语言中的很多内建对象又是python语言的基础，从对象入手很容易理解。这里我们避开语法分析处理与opcode这些太过于无关python语言层面的东西，有机会再展开这部分。

在cpython中实际上是使用结构体来描述一个对象的。
首先cpython中定义了一个结构体叫做[PyObject][5]，这个结构体很简单，将所有的PyObject组织成为一个双向链表，并且有一个字段tp_type指明这个Object的类型。之后定义的所有PyXXXObject结构体开头都与这个PyObject结构体相同，c语言里一个指针的解释取决于这个指针的类型，因此这里使用的是c语言中常见的结构体嵌套那套把戏，linux源码也有这样的技巧，值得注意的是这种结构体嵌套本身就像类的继承。之后所有PyXXXObject指针都可以声明成PyObject的指针，只要在必要的上下文中转换为其真正的类型，注意PyObject的tp_type字段存储了这个指针的真正类型，从而保证了类型检查。

定义了PyObject之后，cpython随后定义一个非常重要的结构体:[PyTypeObject][6]。之后python层面的所有类型都是这个结构体的一个实例。python中最基础的type是其实例，
最基础的object也是其实例，用户定义的一个新式类经过解释器解释之后也会生成这个结构体的一个实例，int类型、long类型、python语言层面隐藏的function类型都是其实例。很容易在相应的XXXobject.c文件中找到这个实例的定义，并且很容易通过__doc__字段来验证这一点。

比如type类型对应[PyType_Type][7], object类型对应的[PyBaseObject_Type][8], 用户自定义function类型对应的[PyFunction_Type][9]。

![img](/assets/resources/cpython_before_1.png){:width="100%"}


有了以上的基础理解，阅读cpython代码便略有眉目了。

但关于断点条件，由于vs没有像gdb那样提供cpython调试的特殊支持，在我们调试的时候需要注意几个点，一个是PyOject指针需要转换成其真正的指针类型，第二个就是vs貌似在调试观察变量的时候不支持宏，因此有些包含宏的结构体定义做类型转换就会失败，目前遇到的主要是PyTypeObject转换，第三个就是主要通过观察对象的名字来确定python代码层面与c语层面的对应关系，这些在之后的文章中还会再谈到。

[0]:https://devguide.python.org/gdb/
[1]:https://devguide.python.org/
[2]:https://devguide.python.org/clang/
[3]:https://devguide.python.org/exploring/
[4]:/2019/07/02/the-object-model-in-python
[5]:https://github.com/python/cpython/blob/2.7/Include/object.h#L106
[6]:https://github.com/python/cpython/blob/2.7/Include/object.h#L376
[7]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L2879
[8]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L3681
[9]:https://github.com/python/cpython/blob/2.7/Objects/funcobject.c#L544
