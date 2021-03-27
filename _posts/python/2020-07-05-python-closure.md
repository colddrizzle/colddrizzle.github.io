---
layout: post
title: python闭包
description: ""
category: python
tags: [python]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 什么是闭包

以下定义来自[python closures][0]。

A closure is a nested function which has access to a free variable from an enclosing function that has finished its execution. Three characteristics of a Python closure are:

* it is a nested function
* it has access to a free variable in outer scope
* it is returned from the enclosing function

A free variable is a variable that is not bound in the local scope. In order for closures to work with immutable variables such as numbers and strings, we have to use the nonlocal keyword.

Python closures help avoiding the usage of global values and provide some form of data hiding. They are used in Python decorators.

## 闭包底层原理

有关闭包的底层实现详细可以参考《Python源码剖析》11.6节。

简单来讲，cpython在编译时通过cellvars与freevars记录闭包相关信息。
其中cellvars记录将会被内层函数引用的本地局部变量，freevars则记录该函数引用的自由变量。若是cpython发现cellvars不为空，则用PyCellObject包装（以指针的形式引用）cellvars中指定的那些变量，
然后将这些PyCellObject对象放入当前函数的f_localsplus指向的空间中。当cpython发现freevars不为空时，则设法找到freevars中的那些变量的PyCellObject，作为参数传给当前函数。

因此，从原理上将，闭包的实现类似函数参数的默认值：

```brush:python
base  = 1

def get_compare(base):
	def real_compare(value):
		return value > base
	return real_compare

compare_with_10 = get_compare(10)
print(compare_with_10(5)) # False
print(compare_with_10(20)) # True
```

等价于：

```brush:python
base  = 1

def get_compare(b):
	def real_compare(value, base = b):
		return value > base
	return real_compare

compare_with_10 = get_compare(10)
print(compare_with_10(5)) # False
print(compare_with_10(20)) # True
print(compare_with_10(5, 1))
```

注意，使用参数默认值的这个例子完全没有用到闭包，跟闭包一点关系都没有。但效果上又完全模拟了闭包，因为底层也是差不过的实现过程。


既然使用参数默认值，上面的代码还可以等价于：

```brush:python
base  = 1


def real_compare(value, base = 10):
	return value > base

print(real_compare(5)) # False
print(real_compare(20)) # True

```

还可以使用偏函数包装下：

```brush:python

from functools import partial

def real_compare(value, base): # 注意这里不必再指定默认值
	return value > base

compare = partial(real_compare, base=10) # 默认值包装在这里

print(compare(5)) # False
print(compare(20)) # True

```

本质上又变成了闭包。

## 闭包与装饰器

不妨看一个装饰器的例子：

```brush:python

def should_say(fn):
    def say(*args):
        print("say something..")
        fn(*args)
    return say

@should_say
def func():
    print("in func")

func()

```

不使用装饰器，下面的代码等效于上面的装饰器代码：

```brush:python

def should_say(fn):
    def say(*args):
        print("say something..")
        fn(*args)
    return say



def func():
    print("in func")


func = should_say(func)

func()

```

不使用装饰器的代码就是个闭包，只不过这里的自由变量变成了一个函数，由此可见，装饰器实际上借由闭包实现的。


## 闭包与nonlocal

参考[nonlocal][1]

## 闭包模拟小类

参考自[python closure][0]。

因为闭包函数看上去好像带有自己的一个小的名字空间，因此类似于对象, 翻过来，可以用闭包模拟对象。

```brush:python

class Summer():

    def __init__(self):
        self.data = []

    def add(self, val):

        self.data.append(val)
        _sum = sum(self.data)

        return _sum

summer = Summer()

s = summer.add(1)
print(s)

s = summer.add(2)
print(s)

s = summer.add(3)
print(s)

s = summer.add(4)
print(s)
```

用闭包实现：

```brush:python
def make_summer():

    data = []

    def summer(val):

        data.append(val)
        _sum = sum(data)

        return _sum

    return summer

summer = make_summer()

s = summer(1)
print(s)

s = summer(2)
print(s)

s = summer(3)
print(s)

s = summer(4)
print(s)
```




[0]:http://zetcode.com/python/python-closures/
[1]:/2020/09/22/nonlocal_and_global




