---
layout: post
title: init、new、call方法的区别

tagline: "Supporting tagline"
category : python
tags : []

---
{% include JB/setup %}

* toc
{:toc}

<hr />


根据《python中函数、方法的cpython视角》可以知道，
python中函数、对象、类的执行方法都是一样的，本质上都是通过

```
 aPyObject(args) => type(aPyObject)->tp_call(aPyObject, args)
```

因此call用于执行，只不过需要注意，按照上面的伪代码，定义在类中的`__call__`方法其实是在对该类的实例进行`()`调用时才会执行的，而如果需要给类自定义`__call__`方法，则需要元类。

根据《cpython源码阅读之类与实例的创建》可知道，
`__new__`与`__init__`则分别是新对象的创建与初始化，实际上是在系统的根type的`type_call()`方法中的调用的，
对外面来说，其实就是类创建对象过程中的两个钩子方法。同样，类本身也是对象，若要自定义类这个对象的创建过程，需要元类。


以上就是原理。

其他通俗向参考：https://zhuanlan.zhihu.com/p/27830675
