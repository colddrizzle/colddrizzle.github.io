---
layout: post
title: python中的对象思想
description: ""
category: python
tags: [python]
---
{% include JB/setup %}

建议在本文之前，建议先看下这篇文章[《The Forgotten History of OOP》][0]和
这篇[《A Brief History of Object-Oriented Programming》][1],尤其是第一篇。
在最初的OOP中是没有类型（class）的概念，而python中无疑是有class概念的。
在python中，一切都是对象。类型是对象，实例也是对象，那么一个对象到底是实例还是类型呢？这其实是相对而言的。
在python中，类型也是由其他类型创建的，对这种类型而言它是实例。
<hr />
如上面所说，python中对象可以相对的分成两类：

* 类型
* 实例

而类型又可以分为两类：

* 类型其创建的实例也是类型
* 类型创建的实例不是类型

对于类型的这种区分，python中实际上也是有区分二者的，就是metaclass与class，这点通过阅读cpython的源码略可窥见。
然而一般情况下metaclass指的是继承自type的用于自定义类创建过程的一个类。
为了更明确，本文中不妨称第一种类型为原始类型，第二种类型为次生类型。
显然，内建的`type`是一个原始类型，继承自type的用户自定义metaclass也是原始类型。
而用户定义的类则是次生类型，很多内建类型如`function,int,long`也是次生类型。

<hr />
对象与对象之间的关系：
* 类型继承类型
* 类型创建类型
* 类型创建实例

这三种关系下对象的类型的传递：

* 类型A继承类型B，则类型A本身的类型与类型B本身的类型相同---cpython中可以看到类型A是通过类型B的类型作为元类来创建的，也就是说用创建类型B的那个类型来创建类型A。
* 类型A创建类型B，则类型B的类型就是类型A
* 类型A创建实例a，则实例a的类型就是类型A

<hr />
python中对象模型一图表达就是：
![img](/assets/resources/python_type_model.jpeg){:width="100%"}

[0]:https://medium.com/javascript-scene/the-forgotten-history-of-oop-88d71b9b2d9f
[1]:http://web.eecs.utk.edu/~huangj/CS302S04/notes/oo-intro.html
