---
layout: post
title: python标准库之functools
category : python
tagline: "Supporting tagline"
tags : [python lib, functools]
---
{% include JB/setup %}


* toc
{:toc}

<hr />

本篇属于[函数式编程模块其二][0].

## cache相关

functools.cache与functools.lru_cache:前者不设定缓冲总大小，因此不需要移除旧值，所以比lru_cache更小更快。但是使用者自己必须保证
缓冲大小有限，

functools.cached_property(func):将一个类方法转换为特征属性，一次性计算该特征属性的值，然后将其缓存为实例生命周期内的普通属性。
cached_property 装饰器仅在执行查找且不存在同名属性时才会运行。缓存的值可通过删除该属性来清空。
**这个装饰器要求每个实例上的`__dict__ `是可写的**。

## 排序相关

functools.cmp_to_key:

functools.total_ordering: 自动生成排序方法。给定一个声明一个或多个全比较排序方法的类，这个类装饰器实现剩余的方法。这减轻了指定所有可能的全比较操作的工作。
此类必须包含以下方法之一：`__lt__() 、__le__()、__gt__() 或 __ge__()`。另外，此类必须支持 `__eq__()` 方法。

比如给定`__lt__`与`__eq__`，则 `__le__()、__gt__() 或 __ge__()`都可以自动推导出来。

## 偏函数相关

functools.partial: 对于普通可调用对象（函数）。

functools.partialmethod: 对于绑定方法。

### 使用偏函数改写函数闭包


```brush:python

def fa(a):
    def fb(b):
        return a+b
    return fb

fa_3 = fa(3)
print(fa_3(2)) # -> 5

#等价于

import functools

def f(b, a):
    return a+b

fa_3 = functools.partial(f, a=3)

print(fa_3(2))
```

## 迭代器相关
functools.reduce：

逻辑伪代码：

```brush:python

def reduce(function, iterable, initializer=None):
    it = iter(iterable)
    if initializer is None:
        value = next(it)
    else:
        value = initializer
    for element in it:
        value = function(value, element)
    return value

```
## 泛型相关
functools.singledispatch

functools.singledispatchmethod

参考：https://blog.csdn.net/weixin_36338224/article/details/109014854


## 装饰器相关

functools.update_wrapper:

例子来自https://blog.csdn.net/hang916/article/details/79912298

```brush:python
def wrap(func):
    def call_it(*args,**kwargs):
        """wrap func: call_it"""
        print('before call')
        return func(*args,**kwargs)
    return call_it
 
@wrap
def hello():
    """say hello"""
    print("hello world")
 
from functools import update_wrapper
def wrap2(func):
    def call_it(*args, **kwargs):
        """wrap func: call_it2"""
        print('before call')
        return func(*args, **kwargs)
    return update_wrapper(call_it, func)
 
@wrap2
def hello2():
    """test hello"""
    print('hello world2')
 
if __name__ == '__main__':
    hello()
    print(hello.__name__)
    print(hello.__doc__)
 
    print()
    hello2()
    print(hello2.__name__)
    print(hello2.__doc__)

```

注意，返回的包装函数使用update_wrapper更新之后，其name与doc变的与被包装函数一样。


functools.wrappers: 是update_wrapper的装饰器写法，它等价于 
`partial(update_wrapper, wrapped=wrapped, assigned=assigned, updated=updated)`(注意这里直接调用的装饰器partial与update_wrapper), 看起来就是自定义装饰器的包装函数的装饰器，例子如下：

```brush:python
from functools import wraps
def my_decorator(f):
    @wraps(f)
    def wrapper(*args, **kwds):
        print('Calling decorated function')
        return f(*args, **kwds)
    return wrapper

@my_decorator
def example():
    """Docstring"""
    print('Called example function')

example()

example.__name__

example.__doc__
```


[0]:https://docs.python.org/3/library/functional.html

