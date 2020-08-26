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

生成器用来构造迭代器。

生成器包括两种语法，参考[文档][0]9.10与9.11：

* 生成器函数

```

def gen():
	for i in [1,2,3]:
		yield i

print type(gen())

output:
<class "generator">
```

* 生成器表达式

```
a = [i for i in [1, 2, 3]]

print type(a)

output:
<class "generator">
```

生成器表达式是一个函数，也会在编译的时候生成代码块，参见[文档][1]:

	The scope of names defined in a class block is limited to the class block; it does not extend to the code blocks of methods – this includes generator expressions since they are implemented using a function scope. 

[0]:https://docs.python.org/2.7/tutorial/classes.html#generators
[1]:https://docs.python.org/2.7/reference/executionmodel.html#interaction-with-dynamic-features
