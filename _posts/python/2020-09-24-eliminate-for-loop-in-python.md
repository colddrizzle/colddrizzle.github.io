---
layout: post
title: 在python中消灭for循环

tagline: "Supporting tagline"
category : python
tags : [python]

---
{% include JB/setup %}

* toc
{:toc}

<hr/>

消灭for循环，写出更加pythonic的代码。

本篇是仿造[在js中消灭for循环][0]而写，就其中所提到的类似的问题，一一给出python下的
一种解法，这通常是借助于函数式编程工具来实现的。

## 一、filter、filterfalse、map、starmap

filter与map是python3内置函数，filtermap与starmap则是itertools中提供的函数。

filter返回条件为真的项，filterfalse则相反。filterfalse似乎有多余之嫌，但是使用好也可以让代码更易读。

map返回一个将 function 应用于 iterable 中每一项并输出其结果的迭代器。 如果传入了额外的 iterable 参数，function 必须接受相同个数的实参并被应用于从所有可迭代对象中并行获取的项。 当有多个可迭代对象时，最短的可迭代对象耗尽则整个迭代就将结束。

对于函数的输入已经是参数元组的情况，则可以使用`itertools.starmap()`。二者传参的结构并不一样。
对于starmap，传入的列表或元组的每一项作为一组参数。对于map，函数需要几个参数就传几个列表，每次调用函数从各个列表里取一个为参数，比如：

```brush:python

# 注意pow可以接收第三个参数对结果取余 pow(base, exp[, mod])

itertools.starmap(pow, [(2,5), (3,2), (10,3)]) # --> 32 9 1000

map(pow, (2,5), (3,2)) # --> 8 25 分别调用pow(2, 3) pow(5, 2)

map(pow, (2,5), (3,2), (10,3)) # --> 8, 1 分别调用pow(2, 3, 10) pow(5, 2, 3)

```

注意这些函数返回的都是生成器，意味着真正迭代的时候才开始计算。

### 1. 将数组中的false值去除

```brush:python

arrContainsEmptyVal = [3, 4, 5, 2, 3, None, 0, ""]

filter(lambda x:bool(x), arrContainsEmptyVal)
```


### 2. 将数组中的 VIP 用户余额加 10

```brush:python
users = [ 
      { "username": "Kelly", "isVIP": True, "balance": 20 },   
      { "username": "Tom", "isVIP": False, "balance": 19 },   
      { "username": "Stephanie", "isVIP": True, "balance": 30 } ]

def p(u):
	if u["isVIP"]:
		u["balance"] += 10

list(map(p, users))

```

解释下这个例子。

* 为什么不用lambda函数？ lambda函数的函数体只能包含一行表达式
* 为什么不用starmap？根据starmap的文档，starmap会将传入的users里的每个元素加星号后传入func, 而一个字典加星号得到的是所有的key(散的状态)。
* 为什么要调用list？ map仅仅是构造一个生成器，不用list执行一下，修改就不会生效

## 二、any与all

这两个也是python3的内置函数。

`any()`等价代码：

```brush:python

def any(iterable):
    for element in iterable:
        if element:
            return True
    return False

```

`all()`等价代码：

```brush:python
def all(iterable):
    for element in iterable:
        if not element:
            return False
    return True
```

注意，在传入的迭代对象为空的时候，`any()`返回False，`all()`返回True。

### 3. 判断字符串中是否含有元音字母

给定字符串`randomStr = "hdjrwqpi"`。


```brush:python

randomStr = "hdjrwqpi"

def isVowel(letter):
	if letter in ("a", "e", "o", "i", "u"):
		return True
	return False

any(map(isVowel, randomStr))

```

一种错误解法：

```brush:python

randomStr = "hdjrwqpi"

def isVowel(letter):
	if letter in ("a", "e", "o", "i", "u"):
		return True
	return False

any([isVowel(x) for x in randomStr])

```

这两种解法的区别在于下面的解法实际上生成了另一个布尔值列表，而上面的解法用map仅构造了一个生成器，
在字符串特别巨大的时候，错误的解法要耗费很多内存。

### 4. 判断用户是否全是成年人

```brush:python
users = [
  { "name": "Jim", "age": 23 },
  { "name": "Lily", "age": 17 },
  { "name": "Will", "age": 25 }
]

all(map(lambda x: x["age"] >= 18, users))

```

类似问题3，注意用map构造一个生成器。

## 三、first_true

这个函数来自于more_itertools扩展包。下面是其定义：

```brush:python

def first_true(iterable, default=False, pred=None):
    """Returns the first true value in the iterable.

    If no true value is found, returns *default*

    If *pred* is not None, returns the first item
    for which pred(item) is true.

    """
    # first_true([a,b,c], x) --> a or b or c or x
    # first_true([a,b], x, f) --> a if f(a) else b if f(b) else x
    return next(filter(pred, iterable), default)
```

### 5. 找出上面用户中的第一个未成年人

```brush:python

 first_true(users, default=None, pred=lambda u: u["age"]>=18)

```

## 四、unique_everseen与unique_justseen

这两个函数来自more_itertools中，具体参见[文档][1]

### 6. 将数组中重复项清除

```brush:python
dupArr = [1, 2, 3, 3, 3, 3, 6, 7]


unique_everseen(dupArr)

```

## 五、还是map

注意理解，map本质是将迭代器中元素逐个进行制定函数调用。

### 7,  生成由随机正整数组成的数组，数组长度和元素大小范围可自定义

原文中是利用JS中的Array的一个特殊构造函数实现的。python自然没有这样的构造函数。

这个问题实际上就是构造一个生成器，生成器每次返回一个随机数，限制下总长度就可以了。

```brush:python
import itertools as it

def genNumArr(length, limit):
	return map(random.randint, it.repeat(1, length), it.repeat(limit,length))

```

## 六、随机排列组合

参考more_itertools文档。

## 七、reduce

reduce来自于functools,上面提到都是来自itertools或内置函数。

### 8. 不借助高阶函数，定义reduce

这个python文档已经给出了：

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

通常，reduce有两种理解，其一是聚合，其二是状态转换。

所谓聚合就是reduce就是通过function函数，将iterable的元素聚合为一个单一结果。

所谓转换就是reduce通过function函数，根据iterable的逐个元素作为输入，将一个初始状态转换为一个最终状态。

要注意状态转换这种理解，这是reduce的精妙所在。下面的取对象的深层属性就是利用了这一点。


### 9. 将多重嵌套列表转为单层列表，也就是展平

在more_itertools中提供了一个flatten函数，仅用于二层嵌套展开。

而多重嵌套，很容易可以想到用递归来实现：
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
	return functools.reduce(concat, nest_lists, [])

a = [[1,2,3], [[4,5,6],[7,8,9]]]

print(flatten(a))

```


### 10. 将下面数组转成字典，key/value 对应里层数组的两个值

```brush:python

objLikeArr = [["name", "Jim"], ["age", 18], ["single", True]]

def addon(d, pair):
	d[pair[0]]=pair[1]
	return d

r = functools.reduce(addon, objLikeArr, {})

print(r)

```

### 11. 取出对象的深层属性

```brush:python

deepAttr = { "a": { "b": { "c": 15 } } }

def pluckDeep(path, obj):
	return functools.reduce(lambda o,a:o[a], path.split("."), obj)

print(pluckDeep("a.b.c", deepAttr))

```

### 12. 将用户中的男性和女性分别放到不同的数组里

```brush:python
users = [
  { "name": "Adam", "age": 30, "sex": "male" },
  { "name": "Helen", "age": 27, "sex": "female" },
  { "name": "Amy", "age": 25, "sex": "female" },
  { "name": "Anthony", "age": 23, "sex": "male" },
]

def seperate(r, item):
    if item["sex"] == "male":
        r[0].append(item)
    else:
        r[1].append(item)
    return r

r = functools.reduce(seperate, users, [[],[]])

```

### 13. 定义unfold 

reduce 的计算过程，在范畴论里面叫 catamorphism，即一种连接的变形。和它相反的变形叫 anamorphism。现在我们定义一个和 reduce 计算过程相反的函数 unfold（注：reduce 在 Haskell 里面叫 fold，对应 unfold）

unfold接收两个参数，一个是生成函数func，另一个是种子。生成函数根据前一个值，生成后一个值，初始值就是种子。
当生成函数返回False或者None的时候，生成过程停止。

```brush:python

def go(func, seed, acc):
    pre, post = func(seed)
    if post:
        acc.append(pre)
        return go(func, post, acc)
    else:
        return acc

def unfold(func, seed):
	return go(func, seed, [])


def my_range(_min, _max, step=1):
    def func(x):
        if x < _max-1:
            return [x, x+step]
        return [x, None]
    return unfold(func, _min)

r = my_range(1, 5)
	
```

上面的写法是通过递归，但不是生成器，显然unfold是可以写成生成器的：

```brush:python
def unfold(func, seed):
    pre = seed
    while True:
        yield pre
        pre, post = func(pre)
        if post:
            pre = post
        else:
            break
        

def my_range(_min, _max, step=1):
    def func(x):
        if x < _max-1:
            return [x, x+step]
        return [x, None]
    return unfold(func, _min)

r = my_range(1, 5)
for i in r:
    print(i)
```

写成了生成器，不可避免的用到了循环，因为python貌似不允许用递归定义生成器，
若是递归定义生成器，生成器该如何停止呢？抛出或者返回一个StopIteration都是不对的。

## 八、用递归代替循环

实际上，下面的章节中用递归来实现不如用生成器来实现，但js中没有生成器，原文不得不那么做。这里仅做对比学习之用，不要这么写代码。

### 14. 将两个数组每个元素一一对应相加

注意，第二个数组比第一个多出两个，不要把第二个数组遍历完。

```brush:python
num1 = [3, 4, 5, 6, 7]
num2 = [43, 23, 5, 67, 87, 3, 6]
r = map(sum, zip(num1, num2))
print(list(r))
```

原文js解法的思路是先定义了zip，但zip是python内置函数,且文档给出了zip的等价定义：

```brush:python
def zip(*iterables):
    # zip('ABCD', 'xy') --> Ax By
    sentinel = object()
    iterators = [iter(it) for it in iterables]
    while iterators:
        result = []
        for it in iterators:
            elem = next(it, sentinel)
            if elem is sentinel:
                return
            result.append(elem)
        yield tuple(result)
```

上述定义简而言之，就是用生成器生成zip的结果的每一个元素，而对于每一个元素的生成，
则是对iterables中的每一个迭代器调用next然后放入result列表中。

本问题原本意在用递归定义zip函数，则：

```brush:python

def my_zip(*iterables):
    iterators = [iter(it) for it in iterables]
    return do_zip(iterators)

def do_zip(iterators):
    # zip('ABCD', 'xy') --> Ax By
    sentinel = object()

    result = []
    for it in iterators:
        elem = next(it, sentinel)
        if elem is sentinel:
            return []
        result.append(elem)
        
    acc = [tuple(result)]
    acc.extend(do_zip(iterators))
    return acc

print(my_zip('ABCD', 'xy'))
```

注意递归意味递归栈的存在，实际上还是要在内存中存储生成的整个结果的，不如生成器节省内存。

### 15. 将 Stark 家族成员提取出来。
注意，目标数据在数组前面，使用 filter 方法遍历整个数组是浪费。

```brush:python
houses = [
  "Eddard Stark",
  "Catelyn Stark",
  "Rickard Stark",
  "Brandon Stark",
  "Rob Stark",
  "Sansa Stark",
  "Arya Stark",
  "Bran Stark",
  "Rickon Stark",
  "Lyanna Stark",
  "Tywin Lannister",
  "Cersei Lannister",
  "Jaime Lannister",
  "Tyrion Lannister",
  "Joffrey Baratheon"
]
```

这个问题意在定义`takewhile`，而takewhile也是itertools提供了的函数。

但我们不妨自己用递归重新定义下takewhile。

所谓takewhile就是取某个序列中的元素，知道条件判断为假停止。

```brush:python

def my_takewhile(iterable, pred):
    item = next(iterable)
    if pred(item):
        r = [item]
        r.extend(my_takewhile(iterable, pred))
        return r
    else:
        return []

print(my_takewhile(iter(houses), lambda x: "Stark" in x))

```

同时我们给出生成器写法：

```brush:python

def my_takewhile(lst, pred):
	for item in lst:
		if pred(item):
			yield item
		else:
			break
```

可见生成器的写法简洁多了，因此python中不推荐递归的那种写法，既麻烦又浪费内存。

### 16. 找出数组中的奇数，然后取出前4个

```brush:python
numList = [1, 3, 11, 4, 2, 5, 6, 7]
```

意在定义takefirst(limit, func, lst)。其中func为真值判断函数，lst是列表。limit是func为真的个数限制。
takeFirst取出lst中func为真的前limit个元素。

不难用递归给出定义。

```brush:python

sentinel = object()
def my_takefirst(limit, func, iterable):
    item = next(iterable, sentinel)
    if limit>0 and item != sentinel:
        if func(item):
            r = [item]
            r.extend(my_takefirst(limit-1, func, iterable))
            return r
        else:
            return my_takefirst(limit,func,iterable)
    else:
        return []

print(my_takefirst(100, lambda x: x%2==1, iter(numList)))
```

同时也很容易给出生成器写法：

```brush:python

def my_takefirst(limit, func, lst):
    for item in lst:
        if limit>0 and func(item):
            yield item
            limit -= 1

print(list(my_takefirst(4, lambda x:x%2==1, numList)))
```

## 九、使用高阶函数遍历数组时可能遇到的陷阱

### 17. 从长度为 100 万的随机整数组成的数组中取出偶数，再把所有数字乘以3

```brush:python
# 使用上面定义的genNumArr生成随机大数组，其实是个生成器
bigArr = genNumArr(int(1e6), 100)
```

原文所谓错误的解法是先用filter再用map，理由是相当于遍历两次数组。
然而实际上python中的filter与map都是生成器，并不会遍历两次。

下面是python中执行时间测试：
```brush:python

import timeit

#timeit返回的时间是秒，执行一百万次，相当于执行一次的微秒时间

bigArr = genNumArr(int(1e6), 100)
def foo():
    list(map(lambda x: x*3, filter(lambda x: x%2, bigArr)))

t = timeit.timeit(foo, number=1000000)
print(t, "us")

# 使用循环对比测试
bigArr = genNumArr(int(1e6), 100)

def foo2():
    r=[]
    for i in bigArr:
        if i%2:
            r.append(i*3)

t = timeit.timeit(foo2, number=1000000)
print(t, "us")

#output:

# 1.987407118 us
# 1.2077594520000003 us
```
可见仅需要2微秒左右，非常快。

## 十、transduce

原文中transduce是为了解决上面遍历两遍的问题而提到的，python中没有这个问题，不过transduce依然是个有趣的东西，
鉴于原文讲的实在太烂了，我们重新表述下transduce是个什么东西。理解transduce需要先理解函数闭包与reduce。

首先，从名字上看，transduce是一种reduce。

其次，虽然python中filter与map都是生成器，但reduce并不是生成器，reduce调用的时候整个迭代器都被遍历了。
所以，为了复现问题，我们先将filter与map重新定义下。

再次，filter与map都可以看做一个reduce过程。

因此，我们使用reduce重新定义filter与map，这样就不是生成器了。

```brush:python

def r_filter(func, iterable):
    def concat(acc, item):
        if func(item):
            acc.append(item)
        return acc

    return functools.reduce( concat, iterable, [])

def r_map(func, iterable):
    def trans(acc, item):
        acc.append(func(item))
        return acc

    return functools.reduce(trans, iterable, [])

```


这一步就很清晰了，filter与map都是reduce过程，只不过reduce的func逻辑不一样，
而想要实现一遍遍历，那么就要将filter与map的func想办法合并成一个func，然后再传入reduce。

我们先将concat与trans这俩func抽出来:

```brush:python

def concat_wrapper(func):
    def concat(acc, item):
        if func(item):
            acc.append(item)
        return acc
    return concat

def trans_wrapper(func):
    def trans(acc, item):
        acc.append(func(item))
        return acc
    return trans

# 重新定义俩func
isEven = lambda x: x%2==0
triple = lambda x: x*3

concat_w = concat_wrapper(isEven)
trans_w = trans_wrapper(triple)
```

在原文中，这一步抽象后的函数叫`filter`与`map`，但其实根据原文中它的定义，这已经不是filter与map了，仅仅是它们的func。
下面是原文中定义：

```brush:javascript

const filter = f => reducer => (acc, value) => {
  if (f(value)) return reducer(acc, value);
  return acc;
};
 
const map = f => reducer => (acc, value) => reducer(acc, f(value));

//(acc.push(value), acc)表示执行前一句，但是将acc作为匿名函数结果返回

const pushReducer = (acc, value) => (acc.push(value), acc);

```

我们认为原文将这俩func重新定义后取名叫filter与map搞乱了逻辑，因此不采用这种名字。

要将filter与map的func合并，需要将二者的共同逻辑抽取出来，然后仅将不同之处合并。
concat与trans两个func的接收的参数都是acc与item，最后的操作也都是往acc中添加一个元素。
而最后添加这一步操作也可以看做是接收acc与item，并且返回修改后的acc的这一一个函数。

一个自然的想法是将trans传入concat，替代concat的这最后一步操作。为什么要替代而不是并存？因为这俩都是
往acc里添加一个元素，并存就会多添加，逻辑就错了。

合并后的操作为：

```brush:python
def combine_op(trans):
	def concat_wrapper(func):
		def concat(acc, item):
			if func(item):
				return trans(acc, item)
			return acc
		return concat
	return concat_wrapper
```

最终整个问题的解变为：

```brush:python
import functools
import itertools
import random

isEven = lambda x: x%2==0
triple = lambda x: x*3

def concat_wrapper(func):
    def concat(acc, item):
        if func(item):
            acc.append(item)
        return acc
    return concat

def trans_wrapper(func):
    def trans(acc, item):
        acc.append(func(item))
        return acc
    return trans

concat_w = concat_wrapper(isEven)
trans_w = trans_wrapper(triple)


def combine_op(trans):
    def concat_wrapper(func):
        def concat(acc, item):
            if func(item):
                return trans(acc, item)
            return acc
        return concat
    return concat_wrapper

    
combine_trans = combine_op(trans_w)(isEven)

def genNumArr(length, limit):
    return map(random.randint, itertools.repeat(1, length), itertools.repeat(limit,length))
bigArr = genNumArr(int(1e6), 100)

r = functools.reduce(combine_trans, bigArr, [])

print(r[:10])
      
```

回过头来我们想一想，若是先将数组中元素乘以3再找出偶数呢？诚然，乘以3不改变奇偶性，但若是其他任意什么操作呢，比如除以2向上取整再找出偶数。
难道我们在讲这两个操作写一堆闭包手动合并吗？显然太麻烦。我们将上面我们做的事情再进一步抽象，使得任意两个reduce中的func可以合并，
两个可以合并，那多个也就可以合并了（别忘了，合并后的结果函数签名不变）。

上面我们讲到trans、concat以及其最后一步操作，都有相同的函数签名，我们不妨把这类函数叫做reducer

```brush:python

def reducer(acc, item):
    # do something
    return acc

```

实际上`do something`里会调用一个func，也就是原filter与map的func，因此再包一层：

```brush:python
def reducer(func):
    def reducer_in(acc, item):
        # do something with func
        # return acc in somewhere
        return acc
    return reducer_in

```

既然reducer_in返回的是acc，那么也可以返回另外一个reducer：

```brush:python

def combined_reducer(another_reducer):
    def reducer(func):
        def reducer_in(acc, item):
            # do something with func
            # return another_reducer(acc, item) in somewhere
            return another_reducer(acc, item)
        return reducer_in

    return reducer

```

上面就是任意两个reduce中的func可以合并的秘密了。

我们用上面的风格重新定义trans与concat，这次我们给它们其名叫filter_reducer与map_reducer:

```brush:python

def filter_reducer(another_reducer):
    def reducer(func):
        def reducer_in(acc, item):
            if func(item):
                return another_reducer(acc, item)
            return acc
        return reducer_in
    return reducer

def map_reducer(another_reducer):
    def reducer(func):
        def reducer_in(acc, item):
            return another_reducer(acc, func(item))
        return reducer_in
    return reducer

```
看起来是不是跟之前的combine_op一模一样，只不过这次既可以先filter在map，也可以先map再filter
```brush:python

# 任意组合操作

filter_reducer(map_reducer(?)(triple))(isEven)

map_reducer(filter_reducer(?)(isEven))(triple)

```

我们也定义一个pipe操作，支持传入任意个reducer：

```brush:python
def pipe(fx, fy):
    return fx(fy)
```

实际上，上面的combine_op的func与trans参数调换一下对计算逻辑没有影响，但是可以方便我们之后抽象：
```brush:python
def combined_reducer(func):
    def reducer(another_reducer):
        def reducer_in(acc, item):
            # do something with func
            # return another_reducer(acc, item) in somewhere
            return another_reducer(acc, item)
        return reducer_in

    return reducer

```

这样任意组合就变成了：

```brush:python

# 任意组合操作

filter_reducer(isEven)(map_reducer(triple)(?))

map_reducer(triple)(filter_reducer(isEven)(?))

# 这样看起来就是
# f1(f2(?))
# 这方便了我们之后对pipe的抽象
```

还有一个问题，在上面的filter_reducer与map_reducer中我们传入了一个问号，这个问号应该是个什么reducer呢？

可以定义一个最简单的reducer，也就是原文的pushReducer:

```brush:python

def push_reducer(acc, item):
    acc.append(item)
    return acc

```

现在我们可以定义pipe了：

```brush:python

def pipe(*args):
    def combine(fx, f1):
        return f1(fx)
    return functools.reduce(combine, args[:-1], args[-1])

```
注意pipe是将最后一个函数

于是整个问题的解变为：

```brush:python
import functools
import itertools
import random

isEven = lambda x: x%2==0
triple = lambda x: x*3

def filter_reducer(func):
    def reducer(another_reducer):
        def reducer_in(acc, item):
            if func(item):
                return another_reducer(acc, item)
            return acc
        return reducer_in
    return reducer

def map_reducer(func):
    def reducer(another_reducer):
        def reducer_in(acc, item):
            return another_reducer(acc, func(item))
        return reducer_in
    return reducer

def push_reducer(acc, item):
    acc.append(item)
    return acc

def pipe(*args):
    def combine(fx, f1):
        return f1(fx)
    return functools.reduce(combine, args[:-1], args[-1])

def genNumArr(length, limit):
    return map(random.randint, itertools.repeat(1, length), itertools.repeat(limit,length))

bigArr = genNumArr(int(1e6), 100)

c  = pipe(filter_reducer(isEven), map_reducer(triple), push_reducer)

r = functools.reduce( c, bigArr, [])

print(r[:10])

```
上面的写法跟原文基本一模一样了，原文中`pipe(filter(isEven), map(triple))(pushReduce)`的传参风格是因为JS里函数闭包的特殊补参机制，
使用`functools.partial`改写上面的函数闭包后，效果是一样的，改写方式参考《python标准库之functools》篇。

本篇仿造的原文JS那篇文章这块儿讲的太烂了，transduce这个玩意，肯定不是一步想出来的，是在实践中不断改进代码最后搞出来的这么一个抽象，
上面试图一步步还原这个这个实践过程，当然这只是一种实践路径，但足以帮助我们理解transduce。

## 十一、生成器的神奇之处

为什么js里那么晦涩的函数式风格编程解决的问题，在python中生成器的概念下如此的简单清晰？

生成器是一种惰性计算，用到一个值的时候就去求一个值，于是在下面的代码中，当map需要一个值的时候，他去调用filter获得一个值。
```brush:python
map(lambda x: x*3, filter(lambda x: x%2, bigArr))
```

而JS中reduce定义的filter与map（或者说python中使用reduce重新定义的filter与map），当调用其的时候其就完成一次遍历。

既然生成器这么好用，能在其他语言中模拟生成器吗？

生成器本质上是一个带状态的函数（或称不可重新进入的函数），那么C中使用结构体或者java里面用对象都可以模拟生成器。

下面给出一个C中的range模拟：

```brush:c
#include <stdio.h>

typedef struct {
    int min;
    int max;
    int step;
    int stop;
    int current;
}Range;

void range_init(Range * this, int min, int max, int step){
    this->min = min;
    this->max = max;
    this->step = step;
    this->current = min;
    this->stop = 0;
}

int range_next(Range * this){
    if(this->stop){
        return 0;
    }

    int last = this->current;

    if(this->current + this->step < this->max ){
        this->current +=  this->step;
    }else{
        this->stop = 1;
    }
    return last;
}

int range_has_next(Range * this){
    return 1-this->stop;
}

int main(void){
    Range r = {1, 10, 2};
    range_init(&r, 1, 10, 2);

    while(range_has_next(&r)){
        printf("%d\n", range_next(&r));
    }
    return 0;
}

```

还有一种使用局部静态变量的写法，但这种写法在整个程序生命周期只能使用一次。

那么C中能不能用setjmp或ucontext来模拟呢？

注意不能使用setjmp，因为yield生成器函数会多次重入，且使用了栈上私有变量，而setjmp不保存栈。

或者能不能使用ucontext复现python中的yield语义？注意makecontext的入口函数不能有返回值。


当然完整实现transduce还要做很多事情，因为python还为生成器提供了一系列的配套语法糖，但基本原理C都可以实现。

[0]:https://blog.csdn.net/guolinengineer/article/details/84935630
[1]:https://docs.python.org/zh-cn/3/library/itertools.html#itertools-recipes
[2]:https://blog.csdn.net/allanGold/article/details/86667908
[3]:https://zhuanlan.zhihu.com/p/109719403