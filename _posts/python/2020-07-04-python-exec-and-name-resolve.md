---
layout: post
title: python exec()与名字解析
description: ""
category: python
tags: [python]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

这篇是关于exec语句在版本2与3中的一点小差异。

## exec语义

版本2与3中的exec标准文档分别在：[2][0]和[3][1]。需要注意的是在p2中exec既可以像函数那样使用（并非内建函数）也可以像关键字那样使用，而在p3中exec不再是一个语句而变成一个内建函数。

可见，不论2与3，exec的都可以以函数的方式使用，其函数签名如下

```brush:python
exec(expr, globals, locals)
```

其含义是将expr作为一个代码块进行执行，并且使用指定的globals与locals作为名字空间。

当不传globals与locals参数或者为None的时候，使用exec所在代码块的globals与locals。但是
当自定义globals时，出现差异：

```brush:python
code="""
import sys
print(sys._getframe().f_globals.keys())
print(sys._getframe().f_locals.keys())
"""

#exec(code)
exec(code, None, None)

#exec(code, None, {})

```	
将会输出

```brush:bash
['code', '__builtins__', '__file__', '__package__', 'sys', '__name__', '__doc__']
['code', '__builtins__', '__file__', '__package__', 'sys', '__name__', '__doc__']
```

可以看到sys被加到globals与locals中去了（这与globals与locals的定义有关，参见《Python执行模型》篇）

但是当使用上面注释的最后一条写法`exec(code, None, {})`的时候，输出出现了差异：

```brush:bash 
['code', '__builtins__', '__file__', '__package__', '__name__', '__doc__']
['sys']
```

可以看到这次，名字sys只绑定到了locals没有绑定到globals。

上面展示的这种差异在python2与3中都存在。

这种差异使得我们有理由相信在module级别，globals之所以与locals一样，是因为内部实现globals引用了locals。当自定义一个空的locals但是没有自定义globals的时候，内部globals仍然引用原来的locals，使得名字sys绑定到了locals，但是不再绑定到globals。
实际上[p2 issues][3]与[p2 doc][0]支持我们这种猜测，doc中写道：
	
	Remember that at module level, globals and locals are the same dictionary. If two separate objects are given as globals and locals, the code will be executed as if it were embedded in a class definition.

### 与文档描述不符之处
本文主要要讲的2与3的小差异出在自由变量的解析上。

所谓自由变量是编译时就能确定的变量，自由变量在代码块中使用却没有在代码块中定义，并且在运行时该变量亦不能从当前代码块global名字空间中找到。


无论p2还是p3，exec中自由变量如同普通代码中的自由变量一样，使用最近的封闭作用域中的绑定，如果没有这样一个绑定，则报告名字找不到。这可以通过如下的代码来验证：

```bursh:python
code="""
import sys
module_local = 1
print("module", sys._getframe().f_globals.keys())
print("module", sys._getframe().f_locals.keys())

def outer():
    import sys
    outer_local = 2
    print("outer", sys._getframe().f_globals.keys())
    print("outer", sys._getframe().f_locals.keys())

    #print(module_local) #free variable

    def inner():
        inner_local = 3
        print("inner", sys._getframe().f_globals.keys())
        print("inner", sys._getframe().f_locals.keys())

        print(outer_local) #free variable

    inner()
outer()
"""
exec(code, {}, {})

```
在`inner`中，`outer_local`是一个自由变量，但是无论2与3，都能狗正确访问该变量。这显然与[p2文档][2]和[p3 文档][4]声称的东西是不符的：
	
	Free variables are not resolved in the nearest enclosing namespace, but in the global namespace.


同样是上面的例子，对于在`outer`中访问`module_local`，版本2与3的行为才符合文档描述。

但是需要注意的一点是，python实现上globals引用的locals，这上面提到过了。

再一个是在exec中包含生成器表达式（可看做一个函数）的时候，p2的处理似乎有bug。问题来源于[这里][5]。

```brush:python
data = {'_out':[1,2,3,3,4]}
codes = ['_tmp=[]',
         '[_tmp.append(x) for x in _out if x not in _tmp]',
         'print(_tmp)']
for c in codes:
    exec(c,{},data)
```

上面的代码中，`_tmp`显然是自由变量，并且调用exec自定义了globals与locals，`_tmp`一直在locals名字空间中，按理说`_tmp`应该是找不到的，但p2能访问，p3就能正确处理。

bugs.python.org上原理完全一样的一个[issue 13557][6]：
```bursh:python
def test():
    x = ['test'] * 20
    exec("lst = [x[i] for i in range(10)]")
    print(lst)

test()
```

以上都说明，在exec中包含生成器表达式（可看做一个函数）的时候，p2的处理有bug。

[0]:https://docs.python.org/2.7/reference/simple_stmts.html#the-exec-statement
[1]:https://docs.python.org/3/library/functions.html#exec
[2]:https://docs.python.org/2.7/reference/executionmodel.html#interaction-with-dynamic-features
[3]:https://bugs.python.org/issue13557
[4]:https://docs.python.org/3/reference/executionmodel.html#interaction-with-dynamic-features
[5]:https://stackoverflow.com/questions/34622902/python-exec-behaving-differently-between-2-7-and-3-3
[6]:https://bugs.python.org/issue13557