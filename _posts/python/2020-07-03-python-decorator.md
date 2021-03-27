---
layout: post
title: python装饰器
description: ""
category: python
tags: [python]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

### 装饰器原理

参考[python闭包][0]，python装饰器是利用函数闭包实现的，只不过闭包引用的自由变量是被装饰的函数。

还可以参考[这里][1].

### 装饰器用法

#### 函数装饰器

函数装饰器就是一个可执行对象，其接收一个函数作为参数，然后返回一个被装饰后的函数。注意返回后的函数可以跟传入的函数没有任何关系。

##### 不带参数的装饰器

```brush:python

def should_say(fn):
    def say(*args):
        print("say something..")
        fn(*args)
    return say

@should_say
def func():
    print("in func")

#func = should_say(func)

func()

```

##### 给装饰器传参数

其实就是在无参装饰器上再包裹一层，这一层接收参数，返回一个无参装饰器，后面就跟无参装饰器一样了，对目标进行装饰，返回目标。

```brush:python
def logging(flag):
    def decorator(fn):
        def inner(num1, num2):
            if flag == "+":
                print("--正在努力加法计算--")
            elif flag == "-":
                print("--正在努力减法计算--")
            result = fn(num1, num2)
            return result
        return inner
    return decorator

@logging("+")             # @logging("+") ==> @decorator
def add(a, b):
    return a + b

@logging("-")             # @logging("-") ==> @decorator
def sub(a, b):
    return a - b

result = add(1, 2)
print(result)

result = sub(1, 2)
print(result)

```

运行结果：
```
===运行结果：=======================================================================

--正在努力加法计算--
3
--正在努力减法计算--
-1

```

#### 类装饰器

所谓类装饰器就是一个可执行对象，其接收一个类作为参数，然后返回一个被装饰后的类。注意，返回后的类跟传入的类可以没有任何关系。

##### 无参类装饰器

```brush:python

# coding=utf-8
def decorater(cls):            
    cls.num_of_animals = 10
    return cls

@decorater
class animal:
    pass

A = animal()  

print(A.num_of_animals)

```


##### 给类装饰器传参

类似地，也是在无参装饰器上再包一层用来接收参数。

```brush:python

def decorater(v):
    def decorater_in(cls):            
        cls.num_of_animals = v     
        return cls
    return decorater_in

@decorater(10)
class animal:
    pass

A = animal()  

print(A.num_of_animals)

```

#### 类作为装饰器

在[python闭包][0]中曾提到，用闭包来模拟一些简单的类，既然装饰器是利用闭包实现的，那么装饰器自然也可以用类实现。

不论是闭包（函数）还是类，cpython执行器操作起来都是一样的，都是如下操作

```
# 未经过装饰
result = decorated_target(decorated_target_args)

# 装饰后
result = decorator(decorator_args)(decorated_target_args)

```

其中decorator就是一个对象A，其可以接收参数执行，并且其执行结果B还可以接受参数执行的这么一个玩意儿。

这样一个玩意自然可以是返回一个函数的函数，或者为实例定义了`__call__`方法的类。这就是用类作为装饰器的本质了。

只不过作为函数装饰器的时候，B是一个函数，作为类装饰器的时候，B是个类。

### 多个装饰器的叠加

从下到上，前一个装饰器的输出作为后一个装饰器的输入。

### 装饰器的一个应用

https://blog.csdn.net/weixin_33847182/article/details/91779200

### 其他资料

函数装饰器：有参、无参、基于类实现的装饰器的定义方法总结：[1][1]
类装饰器：[2][2]

[0]:/2020/07/05/python-closure
[1]:https://www.cnblogs.com/luxiangyu111/p/9671395.html
[2]:https://www.cnblogs.com/wickedpriest/p/11872402.html

