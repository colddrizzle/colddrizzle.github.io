---
layout: post
title: 关于python的nonlocal与global
description: ""
category: python
tags: [python]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 从例子入手

```brush:python

# example 1
x=4
def foo():
    print(x+1)

foo()

# output：
# 5

# example 2
x=4
def foo():
    print(x+1)
    x = 1
foo()

# output：
# UnboundLocalError: local variable 'x' referenced before assignment
```

看上面两个例子，第一个很好理解，第二个例子则会报未绑定错误。

造成这个现象的原因可以说有两个：其一是因为python没有专门的声明变量的语法,`x=1`既可以看做是赋值也可以看做是声明了变量x=1。其二是[python执行模型文档][0]中讲的：

	If a name binding operation occurs anywhere within a code block, all uses of the name within the block are treated as references to the current block. This can lead to errors when a name is used within a block before it is bound.

也就是一个代码块中任意位置出现了某个变量声明，该代码块中其他地方的同名变量都被看做是对该声明的引用。但是

从而，在上面的第二个例子中，`x=1`被看做是变量声明，前一行的x执行的时候x尚未绑定，因此引用了未绑定的x。

试想若是python有专门的声明语句，比如`declare`，从而将第二个例子改成如下就不会有问题了。

```brush:python
# example 1
declare x = 4
def foo():
	print(x+1)
	x=1 # 这是对全局变量x的一个赋值而已。

foo()

# example 2
declare x = 4
def foo():
	print(x+1)
	declare x=1 # 覆盖全局变量或者变量名冲突，视python规则（有declare的新python规则）而定

foo()

```

还有一种更隐蔽的形式也会报未绑定错误，那就是`+= -=`等操作符：


```brush:python
x=4
def foo():
	x += 1
foo()

```


## 我们的意图与global、nonlocal

在开头的例子2中，我们确实是想要将全局变量加+1然后修改全局变量的值，此时`x=1`只当做赋值，根据上面讲的python名字绑定与解析规则，这是没有办法做到的。

于是python提供了global关键字，讲某个非全局代码块中的名字声明为全局作用域。


有时候，我们不想要绑定到全局作用域，而是封闭作用域的上一层，比如：

```brush:python
x=0
def outter():
    x = 1
    def inner():
        #global x
        nonlocal x
        print(x+1) # x引用自嵌套的封闭作用域上一层的x
        x=3			# 变为赋值语句，修改上一层的x变量
    inner()

outter()

# output
2

```

这时候就需要`nonlocal`，nonlocal这个名字并不是很好，其实际意义更接近于`freevar`，将一个名字变为自由变量。


[0]:https://docs.python.org/3/reference/executionmodel.html#resolution-of-names