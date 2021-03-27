---
layout: post
title: python生成器语法
description: ""
category: python
tags: [python]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

生成器用来构造一种特殊的迭代器，其待生成的序列不必事先存储在内存或硬盘上，可以运行时生成，因而节省内存，这是生成器的优点。

### 语法

生成器包括两种语法，参考[文档][0]9.10与9.11：

* 生成器函数

```brush:python

def gen():
	for i in [1,2,3]:
		yield i

print type(gen())

#
# output:
# <class "generator">
```

* 生成器表达式

```brush:python
a = [i for i in [1, 2, 3]]

print type(a)

# output:
# <class "generator">
```

生成器表达式是一个函数，也会在编译的时候生成代码块，参见[文档][1]:

	The scope of names defined in a class block is limited to the class block; it does not extend to the code blocks of methods – this includes generator expressions since they are implemented using a function scope. 


### 原理推测

下面仅仅是推测的原理。

其实不难想象使用longjmp与setjmp实现yield。

函数开始执行的时候，先用longjmp跳转到指定位置（通常继续一个循环），若指定位置为空，则从头开始执行。

在生出结果的位置setjmp保存现场，在setjmp返回0的分支里（非longjmp跳转过来的分支）返回当前的结果。



[0]:https://docs.python.org/2.7/tutorial/classes.html#generators
[1]:https://docs.python.org/2.7/reference/executionmodel.html#interaction-with-dynamic-features
