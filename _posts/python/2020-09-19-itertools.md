---
layout: post
title: python标准库之itertools
category : python
tagline: "Supporting tagline"
tags : [python lib, itertools]
---
{% include JB/setup %}


* toc
{:toc}

<hr />
本篇属于[函数式编程模块其一][0].
主要参考自[官方文档itertools][1].

## itertools

首先需要注意官方文档里区分各种迭代器工具的方式：无限迭代器；终结于最短输入序列的迭代器; 组合迭代器。

大部分迭代器比较简单，下面仅指出一些需要注意的地方。


`dropwhile`: 丢弃，直到满足某个条件不再丢弃。
`takewhile`: 返回，直到满足某个条件不再返回。

`chain(*iterables)`与`chain.from_iterable(iterables)`:二者的区别非常小，从参数上就可以看出来了，
其实是相当于前者可以帮你把你给出的参数打包成一个列表。

注意chain接收的参数本身必须是可迭代的，将chian自动将其打包后，再逐一返回出来，看起来就像是两层。

因此`a = iter.chain([1, 2, 3],[4, 5, 6,[7,8,9]])`的最后一个元素`[7,8,9]`将会原样返回。

`a = iter.chain(1,2,3)`执行`next(a)`将会出错，因为`1`不可迭代。


`groupby()`: 看起来是接收一个字典，实际上仍然是仅接收一个可迭代对象。以迭代值本身作为分组依据。

```brush:python
[k for k, g in groupby('AAAABBBCCDAABBB')]

output: ['A', 'B', 'C', 'D', 'A', 'B']

[list(g) for k, g in groupby('AAAABBBCCD')]

output: [['A', 'A', 'A', 'A'], ['B', 'B', 'B'], ['C', 'C'], ['D']]

```

`tee()`从效果来看，与其说是拆分，不如说是复制了n份同样的迭代器。

## more_itertools

使用`pip install more-itertools`安装，这个扩展包利用itertools实现更多的工具函数。这里简单学习几个。

### convolve

```brush:python
def convolve(signal, kernel):
    # See:  https://betterexplained.com/articles/intuitive-convolution/
    # convolve(data, [0.25, 0.25, 0.25, 0.25]) --> Moving average (blur)
    # convolve(data, [1, -1]) --> 1st finite difference (1st derivative)
    # convolve(data, [1, -2, 1]) --> 2nd finite difference (2nd derivative)
    kernel = tuple(kernel)[::-1]
    n = len(kernel)
    window = collections.deque([0], maxlen=n) * n
    for x in chain(signal, repeat(0, n-1)):
        window.append(x)
        yield sum(map(operator.mul, kernel, window))
```
### flatten

```brush:python

def flatten(list_of_lists):
    "Flatten one level of nesting"
    return chain.from_iterable(list_of_lists)
```

上面是将一层嵌套的列表展平，下面是任意层嵌套展平：

```brush:python
import functools
from collections.abc import Iterable

def concat(lst, item):
    if isinstance(item, Iterable):
        lst.extend(flatten(item))
    else:
        lst.append(item)
        
    return lst

def flatten(nest_lists):
	return list(functools.reduce(concat, nest_lists, []))

a = [[1,2,3], [[4,5,6],[7,8,9]]]

print(flatten(a))
```


[0]:https://docs.python.org/3/library/functional.html
[1]:https://docs.python.org/3/library/itertools.html