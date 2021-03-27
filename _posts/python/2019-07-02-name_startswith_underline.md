---
layout: post
title: 类与模块中以下划线开头的名字

tagline: "Supporting tagline"
category : python
tags : []

---
{% include JB/setup %}

* toc
{:toc}

<hr />

模块基本的全局变量若以下划线开头（只要有一个下划线），在import这个模块的时候，这个名字就不会被导入。

类对象的变量若是以双下划线开头，则表明这是一个私有变量，但python中的私有变量不是绝对没有办法访问，而是可以通过
`_ClassName__PrivateName`的方式来访问，比如：

```brush:python;
_g1 = 0
g2 = 2

class A():
    def __init__(self):
        self.__a  = 1
        self._b = 2
        self.c = 3

a = A()
print(a.c)
print(a._b)
print(a._A__a) #可以这样来访问

```

类中的方法若是以双下划线开头和结尾，则是一些特殊方法，比如`__init__`，不再表述。