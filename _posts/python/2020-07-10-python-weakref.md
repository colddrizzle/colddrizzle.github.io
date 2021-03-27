---
layout: post
category : python
tagline: "Supporting tagline"
tags : [python lib, weakref]
title: python标准库之weakref
---
{% include JB/setup %}


* toc
{:toc}

<hr />

本文总结自[weakref doc][0].

未完成。

## weakref的应用场景

弱引用的主要用途是实现保存大对象的高速缓存或映射，但又不希望大对象仅仅因为它出现在高速缓存或映射中而保持存活

## 弱引用与代理

`weakref.ref()`创建弱引用，`weakref.proxy()`创建使用弱引用的代理。
二者的区别是弱引用需要执行以下才能获得被引用对象，而proxy不需要。

```brush:python
import weakref
class Object:
    pass

o = Object()
r = weakref.ref(o)
o2 = r() #需要执行一下才能拿到被引用对象
print(o is o2)

p = weakref.proxy(o)
print(o is p)
```

## 弱引用容器类

WeakKeyDictionary

WeakValueDictionary

WeakSet

## 弱引用方法

weakref.WeakMethod: 一个模拟对绑定方法（即在类中定义并在实例中查找的方法）进行弱引用的自定义 ref 子类。 由于绑定方法是临时性的，标准弱引用无法保持它。 WeakMethod 包含特别代码用来重新创建绑定方法，直到对象或初始函数被销毁。注意适用于绑定方法。

```brush:python
class C:
    def method(self):
        print("method called!")

c = C()
r = weakref.ref(c.method)
r()
r = weakref.WeakMethod(c.method)
r()

r()()

del c
gc.collect()

r()

```

## finalize终结器对象
使用 finalize 的主要好处在于它能更简便地注册回调函数，而无须保留所返回的终结器对象。

这样我们就可以带被引用对象销毁的时候做一些清理的工作，而不是像下面的例子那样仅仅打印一条信息。

```brush:python
import weakref
class Object:
    pass

kenny = Object()
weakref.finalize(kenny, print, "You killed Kenny!")  

del kenny
```

weakref.finalize返回的是终结器对象，其在对象销毁的时候被调用一次，当然也可以手动直接调用它。

终结器对象只会被调用一次。

可以使用detach()来注销一个终结器。

除了`kill`杀死进程等暴力终结之外，除非你将atexit 属性设为 False，否则终结器在程序退出时如果仍然存活就将被调用

### 比较终结器与del方法
```brush:python
import tempfile
import weakref
import shutil

class TempDir:
    def __init__(self):
        self.name = tempfile.mkdtemp()
        
        self._finalizer = weakref.finalize(self, print, self.name)
        self._finalizer = weakref.finalize(self, shutil.rmtree, self.name)

    def remove(self):
        self._finalizer()

    @property
    def removed(self):
        return not self._finalizer.alive


t = TempDir()

del t


```

注意，终结器可以注册多个回调函数，终结器是弱引用库注册的，但是对象不必经弱引用然后在销毁，终结器回调一样起作用。

`__del__()` 方法的处理会严重地受到具体实现的影响，
因为它依赖于解释器垃圾回收实现方式的内部细节。而如果使用终结器，即使对象一直未被作为垃圾回收，终结器仍会在退出时被调用。


？？？？严重地受到具体实现的影响，具体是什么意思呢？


上面所说的“退出时”指的是什么时候呢？指的是程序正常执行完退出的时候，从c语言的角度讲，主函数返回的时候或者调用`exit()`的时候。

注意，已经验证使用`kill -9`或`kill -15`杀死进程都不会触发。

### 善用妙用终结器

基于弱引用的终结器还具有另一项优势，就是它们可被用来为定义由第三方控制的类注册终结器，例如当一个模块被卸载时运行特定代码:

```brush:python
import weakref, sys
def unloading_module():
    # implicit reference to the module globals from the function body
weakref.finalize(sys.modules[__name__], unloading_module)
```

## 疑难

### 终结器失效

如果当程序退出时你恰好在守护线程中创建终结器对象，则有可能该终结器不会在退出时被调用。 但是，在一个守护线程中 atexit.register(), try: ... finally: ... 和 with: ... 同样不能保证执行清理。

### 不是所有的对象都可以创建weakref

参考文档。

### 弱引用与hashable、排序、比较

参考文档。

### weakref创建的引用在cpython中是个对象吗

不是对象，是个结构体`struct _PyWeakReference`。

### 引用的引用？

```brush:python
import sys
import weakref

class A(object):
    pass

a = A()
wa1=weakref.ref(a)
wa2=weakref.ref(a)
wa3=weakref.ref(a)
print(sys.getrefcount(wa1))

w_wa=weakref.ref(wa1)
```

Output:
```
4
Traceback (most recent call last):
  File "g:\python2_projects\ref_6.py", line 13, in <module>
    w_wa=weakref.ref(wa1)
TypeError: cannot create weak reference to 'weakref' object

```
对weakref调用所有方法都是对原对象的操作。

不能再创建引用的引用。


[0]:https://docs.python.org/zh-cn/3/library/weakref.html