---
layout: post
category : python
tagline: "Supporting tagline"
tags : [python, weakref]
title: python库之weakref
---
{% include JB/setup %}


* toc
{:toc}

<hr />

未完成。

## weakref的应用场景

参考文档
## 不是所有的对象都可以创建weakref

参考文档

## weakref创建的引用在cpython中是个对象吗

不是对象，是个结构体`struct _PyWeakReference`。

## proxy的使用

## 引用的引用？

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