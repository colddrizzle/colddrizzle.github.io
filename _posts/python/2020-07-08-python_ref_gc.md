---
layout: post
title: cpython垃圾回收
description: ""
category: python
tags: [cpython, gc, python]
---
{% include JB/setup %}

* toc
{:toc}

<br />

奇怪的refcount

回收算法

gc模块

del属性




# 概述

python语言不要求用户手动释放对象内存，而代之以垃圾回收机制。
python的是引用计数、标记清除以及分代管理三者结合的结果。

引用计数用来处理“非容器类”对象的自动释放，而标记清除用来释放“循环引用”的对象。
分代管理用来控制自动GC的频率（否则我们什么时候才应该进行循环引用检查并释放这部分内存呢？分代就是这样一个回答，当某一代限定的对象数目阈值达到之后才进行实质的内存释放）。

在cpython内，gc模块特指实现标记清除与分代管理算法的模块，该只关心容器类对象。非容器类对象使用reference counting collector，容器对象使用garbage collector。标记清除算法其实是在引用计数的基础之上进行的，因此两个collector并不是独立存在的。


	The algorithm that CPython uses to detect those reference cycles is implemented in the gc module. The garbage collector only focuses on cleaning container objects (i.e. objects that can contain a reference to one or more objects). These can be arrays, dictionaries, lists, custom class instances, classes in extension modules, etc. One could think that cycles are uncommon but the truth is that many internal references needed by the interpreter create cycles everywhere.

	来自Python Developer's Guide--Design of CPython’s Garbage Collector



实际上cpython中的内存申请与释放也不只是直接使用libc层级的`malloc、free`而是自有一套机制。
本文不涉及cpython的内存管理机制，可以参考[这里][0]。

# 应用

用户对python内部的垃圾回收机制能做的事情并不多，相关接口都暴露在gc模块中。

## 引用计数
可以通过`gc.getrefcount(obj)`来查看一个对象的引用计数。比如

```brush:python
import sys
a = dict()
print(sys.getrefcount(a))
b = a
c = a
print(sys.getrefcount(a))
del b
print(sys.getrefcount(a))
c = None
print(sys.getrefcount(a))
del a
print(sys.getrefcount(a))
```
Output:
```
2
4
3
2
Traceback (most recent call last):
  File "g:\pycharm_projects\compile_source\demo5.py", line 12, in <module>
    print(sys.getrefcount(a))
NameError: name 'a' is not defined
```
可以看到每当用一个变量保存一个对象引用之后，引用计数就加1。删除一个引用变量计算就减1。

当一个非gc类对象的引用计数减少到0的时候，其内存就被回收了。

	什么是非gc类对象原理部分会解释。

但是存在循环引用的时候，其引用计数永远无法减到0。看下面的例子：
```
import sys

#互相引用
a = []
b = [a]
a.append(b)

print(sys.getrefcount(a)) # 3
print(sys.getrefcount(b)) # 3

#自引用
c=[]
c.append(c)
print(sys.getrefcount(c)) # 3

del c
```

可以看到上面的例子中其实际的引用计数都是3，当`del c`之后，会删除名字“c”对列表对象的引用，一个不被外部引用列表对象内还存在对其的引用，因而此时引用计数回收器失效，这就是为什么需要gc
模块以及实现标记-清除算法。

还可以看到实际输出的引用计数比“看起来的”引用数多1，那是因为`getrefcount()`函数的参数本身是复制传值的，因此引用加1。

但并不是对象传入任意函数后其引用计数就加1，具体引用计数加多少取决于函数内部实现，`getrefcount`本质是个c函数。

通常的Python函数（PyFunction_Type）中引用计数加2。看下面的例子：

```brush:python
import sys
class A(object):
    def ref_count_func(self, a):
        print "in normal method", sys.getrefcount(a)

class B(object):
    def make_closure(self, a):
        print "in make closure method", sys.getrefcount(a)
        def closure():
            print "in closure", sys.getrefcount(a)
            print a
        return closure

a = A()
print "after create", sys.getrefcount(a)

obj = object()
a.ref_count_func(obj)
print "after normal method", sys.getrefcount(a)

b = B()
c = b.make_closure(a)

print "after make closure method", sys.getrefcount(a)

c()
```
Output:
```
after create 2
in normal method 4
after normal method 2
in make closure method 5
after make closure method 3
in closure 3
<__main__.A object at 0x00000000022FF9E8>
```

可以看到无论是普通函数还是类方法中引用计数都加2。之所以加2貌似是与cpython内部`fast_funciton`调用机制相关的，参数传递给函数前会入栈，引用加1，`fast_function`中构建`frame`的时候会再次入栈，所以引用加2,
大致是这样，这部分源码我还没有彻底了解清楚。

还可以看到当一个闭包引用了某个变量之后，引用计数也加1。

## 弱引用weakref
上面讲到“循环引用”会使得引用计数回收器失效，但是如果使用弱引用的话，依然可以正常回收，比如

```
import sys
import weakref

class A(object):
    pass

a = A()
wa=weakref.ref(a)
print(sys.getrefcount(wa))
```

其根本原因是因为弱引用**根本**不会增加引用计数。


	并非所有的对象都可以创建弱引用 参考标准weakref模块文档。
	每当通过`weakref`创建一个对象o的弱引用，在对象o的内部实现上就增加一个弱引用对象，之后的引用都是对这个弱引用对象的引用。
	所有的弱引用对象对象维护在对象的`tp_weaklist`字段中。

实际上，在python中来说，weakref也不是为了解决循环引用而提供的，cpython内部的标记清除算法就可以解决循环引用，weakref的一个典型的
应用场景是cache，详情参看标准weakref模块文档。

## 自定义`__del__`方法

自定义类可以提供一个`__del__`方法，用来在该类实例释放时执行销毁操作。注意`del x`并不是调用`x.__del__`，这一点在文档的[Note][1]部分说的很清楚。

此外，在[gc模块文档中讲到][2]，当一个循环引用的对象链中有一个对象自定义了`__del__`方法之后，gc将不再自动释放这些对象，而是将其放入`gc.garbage`中，因为cpython无法获知正确调用这些`__del__`方法的顺序。

注意，只有循环引用中有`__del__`方法不会被自动调用释放，非循环引用该释放时还是自动调用`__del__`方法进行释放。

？？？ del方法是覆盖原来默认的还是钩子？

## gc模块其他
### threshold
```brush:python
gc.set_threshold()
gc.get_threshold()
```

概述部分提到过，对象是分代管理的，cpython中共有0,1,2三代。新创建的对象在第0代，如果一个对象在经过一次gc.collect()之后活了（仍然有对象在使用它）下来，会被移动到下一代中。每一代有其限制数目，就是通过`threshold`来设置。当达到限制数目后，触发垃圾回收，显然，一定是第0代先触发限制数目，然后以此类推，三代就像从高到低三个水池，高的满了自动流到下一个。

注意，将threshold设置为0并不是限制为0，而是关闭GC：Setting threshold0 to zero disables collection.

### 禁用gc
```brush:python
gc.disable()
```
文档对其的说明太少。但是通过查阅源码以及网上资料可知，所谓禁用仅仅是禁用了gc模块中的算法，也就是不再进行循环引用检查。

有的时候，需要大量创建、销毁对象，第0代频繁触发数目限制引起collect，如果你能确定这其中并不会产生太多循环引用的话，这种检查就是纯粹的在浪费CPU。就可以使用`gc.disable()`来关闭循环引用检查和分代算法，等到创建与销毁结束后再开启gc。

实际上，instagram的工程师正是这么干的，参考[这里][3]。

需要注意的是，这个禁用仅仅是禁用了garbage collector的自动运行，reference counting collector仍然在起作用，手动调用`gc.collect()`不受限制：

引用计数收集器仍然工作：
```brush:python
import gc
gc.disable()

class A(object):
    def __del__(self):
        print("del "+repr(self))

a = A()
del a

```

手动调用`gc.collect()`仍然在起作用，下面来演示说明：

首先，设置0代threshold为2，保证能自动触发一次gc，因为`gc.garbage`在触发gc时会存放不可回收的对象，我们用这点来检查gc是否触发。
可以看到程序运行后`gc.garbage`不为空
```
import gc
#gc.disable()

class A(object):
    def __del__(self):
        print("del "+repr(self))

b = A()
c = A()
b._c = c
c._b = b
del b 
del c

gc.set_threshold(2)
d=A()
d=A()
#gc.collect()
print(gc.garbage)
```

Output:
```
del <__main__.A object at 0x00000000021C79B0>
[<__main__.A object at 0x00000000021C7908>, <__main__.A object at 0x00000000021C7940>]
del <__main__.A object at 0x00000000021C79E8>
```

关闭gc再一次执行：
```
del <__main__.A object at 0x00000000023979B0>
[]
del <__main__.A object at 0x00000000023979E8>
```

关闭gc但手动调用collect，结果为：
```
del <__main__.A object at 0x00000000022F79B0>
[<__main__.A object at 0x00000000022F7908>, <__main__.A object at 0x00000000022F7940>]
del <__main__.A object at 0x00000000022F79E8>
```

### gc.garbage
参考[标准文档][2]。

# 原理

可想而知，cpython内部要实现引用计数，就必须将所有的对象管理起来，因此我们首先看
python对象的申请与组织。

## 对象内存的申请与组织

python对象模型篇有过介绍，python中的对象可以分为三类，元类型、次生类型与普通对象，这个分类是按照其绝对创建关系分类的。
也可以按照相对创建关系分成类型与对象两类。类型无外两类，一类是内建类型，一类是自定义类型。无论那种类型，其类对象都是PyType_Type类型，对象也无外乎这两种类型所创建。

对于每一种内建类型t，其PyTypeObject结构体中都定义了相应的`tp_new`方法，用于在执行`TYPE(t)->tp_call`的时候创建其实例。

而对于自定义类型而言，在不定义元类重写元类的`__new__`方法的时候，默认继承自`PyType_Type`的`tp_new`方法，也就是`type_new`方法。

对于自定义类的实例而言，在不定义类的`__new__`方法的时候，默认继承自`PyBaseObject_Type`的`tp_new`方法，也就是`object_new`方法。

以上内容参考《cpython源码阅读之类与实例的创建》篇可以获得了解。

了解了python所有对象的创建的入口函数，那我们就可以分析其创建过程了。

gc模块的提到，gc只关注“容器类”对象。平时的使用中，除了int、float、string等几个基本类型之外，其余基本都是容器类型对象。

### 非容器类对象:以int为例

int的`tp_new`方法参见[int_new][4]，可以看到能以不同的参数创建int对象，以其中的`PyInt_FromLong`为例，可以看到其主要路径的调用顺序：
```
int_new
	->PyInt_FromLong
		->PyObject_INIT
			->_Py_NewReference
```

int对象的内存的申请还涉及到python的内存管理，我们略去不管。

### 容器类对象：以自定义类型与实例为例
我们依然考察期tp_new方法中的主要路径。

对于[type_new][5]，其对象的内存申请是通过下面这一行代码实现的：

```brush:c
// https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L2340

/* Allocate the type object */
    type = (PyTypeObject *)metatype->tp_alloc(metatype, nslots);
```

默认情况下，metatype就是`PyType_Type`，通过源码可知其`tp_alloc`字段为0，这表示该字段继承自基类，可`PyType_Type`的`tp_base`字段也是0。

我们知道`PyType_Ready()`会为每个python类型对象做初始化工作，在这个方法中可以看到如下代码：
```brush:c
    /* Initialize tp_base (defaults to BaseObject unless that's us) */
    base = type->tp_base;
    if (base == NULL && type != &PyBaseObject_Type) {
        base = type->tp_base = &PyBaseObject_Type;
        Py_INCREF(base);
    }
```
所以其基类时`object`，这与我们在python REPL中打印`type.__class__`看到的一致。

`object`也就是`PyBaseObject_Type`的`tp_alloc`字段为`PyType_GenericAlloc`。

因此主要路径为：
```
type_new
	->PyType_GenericAlloc
		->_PyObject_GC_Malloc
		->PyObject_INIT
			->_Py_NewReference
		->_PyObject_GC_TRACK

```

类似地，我们可以得到[object_new][6]的主要路径：

```
object_new
	->PyType_GenericAlloc
		->_PyObject_GC_Malloc
		->PyObject_INIT
			->_Py_NewReference
		->_PyObject_GC_TRACK
```
### 总结

可以看到，无论容器类还是非容器类申请好对象内存后都会调用[`_Py_NewReference`][7]。但是容器类对象的内存申请
都是通过[`_PyObject_GC_Malloc`][8]来进行的。

在`_Py_NewReference`中可以看到，所有的对象都是通过对象头结构`PyObject_HEAD`组织成双向链表，其中包含其引用计数`ob_refcnt`。

```brush:c
/* Define pointers to support a doubly-linked list of all live heap objects. */
#define _PyObject_HEAD_EXTRA            \
    struct _object *_ob_next;           \
    struct _object *_ob_prev;

/* PyObject_HEAD defines the initial segment of every PyObject. */
#define PyObject_HEAD                   \
    _PyObject_HEAD_EXTRA                \
    Py_ssize_t ob_refcnt;               \
    struct _typeobject *ob_type;
```

并且在`_Py_NewReference`中`ob_refcnt`被初始化为1。

注意这里一个对象一旦被创建其引用计数就为1，虽然此时还未必有变量引用该对象（比如直接写`dict()`而不是`a=dict()`），
但是栈中肯定引用了该对象，这个引用计数1其实是栈引用，后面不进行STORE_NAME操作的话，会将其从栈中弹出，然后引用计数减1。


在`_PyObject_GC_Malloc`中可以看到，所有的容器类对象都有一块额外的`PyGC_Head`来组成成另一个双向链表。
并且，**在该方法中检查第0代的数目限制触发collect** 。

最后在`_PyObject_GC_TRACK`方法中将这个新申请的gc对象纳入gc双向链表中的第0代管理起来。

gc对象的内存视图大概是（来自[文档][9]）：

![img](/assets/resources/gc_obj_memory.png){:width="100%"}

## 回收器
有了python对象申请过程与组织结构，我们就可以分析python中对象自动回收的机制了。

### 引用计数回收器
引用计数回收器可以通过如下的一个例子来说明：
```brush:python
a = dict()
b = a
c = a
del b
c = None
del a

dict()
```

反编译成字节码：
```
  1           0 LOAD_NAME                0 (dict)
              3 CALL_FUNCTION            0
              6 STORE_NAME               1 (a)

  2           9 LOAD_NAME                1 (a)
             12 STORE_NAME               2 (b)

  3          15 LOAD_NAME                1 (a)
             18 STORE_NAME               3 (c)

  4          21 DELETE_NAME              2 (b)

  5          24 LOAD_CONST               0 (None)
             27 STORE_NAME               3 (c)

  6          30 DELETE_NAME              1 (a)

  8          33 LOAD_NAME                0 (dict)
             36 CALL_FUNCTION            0
             39 POP_TOP
             40 LOAD_CONST               0 (None)
             43 RETURN_VALUE
```

从反编译的字节码可以看到，创建一个引用包括对None的引用都是`STORE_NAME`，删除一个引用对应的字节码是`DELETE_NAME`。
从`ceval.c`中可以很容易找到`TARGET(STORE_NAME)`与`TARGET(DELETE_NAME)`对应的语义。

我们先来看`STORE_NAME`:
```brush:c
        TARGET(STORE_NAME)
        {
            w = GETITEM(names, oparg);
            v = POP();
            if ((x = f->f_locals) != NULL) {
                if (PyDict_CheckExact(x))
                    err = PyDict_SetItem(x, w, v);
                else
                    err = PyObject_SetItem(x, w, v);
                Py_DECREF(v);
                if (err == 0) DISPATCH();
                break;
            }
            t = PyObject_Repr(w);
            if (t == NULL)
                break;
            PyErr_Format(PyExc_SystemError,
                         "no locals found when storing %s",
                         PyString_AS_STRING(t));
            Py_DECREF(t);
            break;
        }

```
无论是`PyDict_SetItem`还是`PyObject_SetItem`（涉及到slotdefs[]中查看一个Map类或序列类对象的默认设置方法），最后都用对`v`调用:

```brush:c
Py_INCREF(value);
```


再来看`DELETE_NAME`:
```brush:c
        TARGET(DELETE_NAME)
        {
            w = GETITEM(names, oparg);
            if ((x = f->f_locals) != NULL) {
                if ((err = PyObject_DelItem(x, w)) != 0)
                    format_exc_check_arg(PyExc_NameError,
                                         NAME_ERROR_MSG,
                                         w);
                break;
            }
            t = PyObject_Repr(w);
            if (t == NULL)
                break;
            PyErr_Format(PyExc_SystemError,
                         "no locals when deleting %s",
                         PyString_AS_STRING(w));
            Py_DECREF(t);
            break;
        }
```

可以看到直接就是调用:
```brush:c
Py_DECREF(t)
```

我们来看下这俩宏定义：
```brush:c
#define Py_INCREF(op) (                         \
    _Py_INC_REFTOTAL  _Py_REF_DEBUG_COMMA       \
    ((PyObject*)(op))->ob_refcnt++)

#define Py_DECREF(op)                                   \
    do {                                                \
        if (_Py_DEC_REFTOTAL  _Py_REF_DEBUG_COMMA       \
        --((PyObject*)(op))->ob_refcnt != 0)            \
            _Py_CHECK_REFCNT(op)                        \
        else                                            \
        _Py_Dealloc((PyObject *)(op));                  \
    } while (0)

```

可以看到前者就是将引用计数加1，后者则是减1然后判断是否为0，为0则调用`_Py_Dealloc`，其内部再调用`_Py_ForgetReference`。
`_Py_ForgetReference`将对象从`PyObject_HEAD`组成的双向链表中移除，然后调用`Py_TYPE(op)->tp_dealloc`实现内存的回收。

可以看到对于引用计数回收器而言，引用计数降至0，直接回收。不涉及循环引用处理以及分代管理。

下面我们看gc模块实现的垃圾收集器。

### gc回收器
被gc模块管理的对象有一块额外的`PyGC_HEAD`头：

```brush:c
/* GC information is stored BEFORE the object structure. */
typedef union _gc_head {
    struct {
        union _gc_head *gc_next;
        union _gc_head *gc_prev;
        Py_ssize_t gc_refs;
    } gc;
    double dummy; /* Force at least 8-byte alignment. */
    char dummy_padding[sizeof(union _gc_head_old)];
} PyGC_Head;

```
除了`gc_prev\gc_next`组成双向链表之外，还有一个字段`gc_refs`。

根据源码中的注释以及文档[Design of CPython’s Garbage Collector][9]可知这是gc算法实现的关键。

注释：
![img](/assets/resources/gc_refs_comment.png)

上面我们提到，`_PyObject_GC_Malloc`中触发gc，跟踪源码后可知主要路径为：
```
_PyObject_GC_Malloc
	->collect_generations
		->collect
```

主要逻辑都在[`collect`][10]中。结合[文档][9]、`gc_refs`注释以及collect注释，下面通过注释的方式解读该算法，
为了方便理解我们将其调用的函数的注释也搬到这里来了。


```brush:c
    /* update collection and allocation counters */
    if (generation+1 < NUM_GENERATIONS)
        generations[generation+1].count += 1;
    for (i = 0; i <= generation; i++)
        generations[i].count = 0;

    /* merge younger generations with one we are currently collecting */
    for (i = 0; i < generation; i++) {
        gc_list_merge(GEN_HEAD(i), GEN_HEAD(generation));
    }

    /* handy references */
    young = GEN_HEAD(generation);
    if (generation < NUM_GENERATIONS-1)
        old = GEN_HEAD(generation+1);
    else
        old = young;

    /* Using ob_refcnt and gc_refs, calculate which objects in the
     * container set are reachable from outside the set (i.e., have a
     * refcount greater than 0 when all the references within the
     * set are taken into account).
     */

     /* Set all gc_refs = ob_refcnt.  After this, gc_refs is > 0 for all objects
 		* in containers, and is GC_REACHABLE for all tracked gc objects not in
 		* containers.
 	*/
    update_refs(young);
    

	/* Subtract internal references from gc_refs.  After this, gc_refs is >= 0
	 * for all objects in containers, and is GC_REACHABLE for all tracked gc
	 * objects not in containers.  The ones with gc_refs > 0 are directly
	 * reachable from outside containers, and so can't be collected.
	 */
	 // 注意理解这是标记-清除算法最关键的一步。
	 // 想象一下所有的对象按引用关系组织成一个有向图，并且
	 // 所有对象又都组成一个双向链表，当按双向链表的顺序访问所有的对象的时候
	 // 使用visit_decref访问容器类对象内部引用的其他对象
	 // 如果一个容器类对象内部有引用其他对象，则将其引用的对象的引用计数-1。
	 // 显然，如果一个对象在n在容器中，则其引用计数会被减至0。
	 // 如果不为0，则说明该对象在“外部”有引用（globals或locals名字空间中）
	 // 但是计数为0并不说明该对象不可达，下面会再处理。
    subtract_refs(young);

    /* Leave everything reachable from outside young in young, and move
     * everything else (in young) to unreachable.
     * NOTE:  This used to move the reachable objects into a reachable
     * set instead.  But most things usually turn out to be reachable,
     * so it's more efficient to move the unreachable things.
     */
    gc_list_init(&unreachable);
    //将young中gc_refs=0的移动到unreachable中，标记为GC_TENTATIVELY_UNREACHABLE
    //将gc_refs>0的用visit_reachable访问该容器类对象内引用的对象


	/* Move the unreachable objects from young to unreachable.  After this,
	 * all objects in young have gc_refs = GC_REACHABLE, and all objects in
	 * unreachable have gc_refs = GC_TENTATIVELY_UNREACHABLE.  All tracked
	 * gc objects not in young or unreachable still have gc_refs = GC_REACHABLE.
	 * All objects in young after this are directly or indirectly reachable
	 * from outside the original young; and all objects in unreachable are
	 * not.
	 */

	//前面说gc_refs为0并不说明该对象不可达，因为有可能其容器对象的
	//gc_refs仍然可达，因此这里将gc_refs的标记为“暂时不可达”--GC_TENTATIVELY_UNREACHABLE
    //注意该方法按链表顺序遍历yong中的对象，因此会出现
    //一个对象（gc_refs大于0）用visit_reachable访问的时候其内部引用的对象
    //gc_refs已经标记为GC_TENTATIVELY_UNREACHABLE情况，这恰恰说明这个临时可达是真正可达，
    //因此又会把它放回到young中，
    //之后young中留下的都是可达的对象了
    //而unreachable中就是循环引用且不可达的（注意这里绝不包含非循环引用不可达对象，这种早被引用计数回收器干掉了）
    move_unreachable(young, &unreachable);

    /* Move reachable objects to next generation. */
    if (young != old) {
        if (generation == NUM_GENERATIONS - 2) {
            long_lived_pending += gc_list_size(young);
        }
        gc_list_merge(young, old);
    }
    else {
        /* We only untrack dicts in full collections, to avoid quadratic
           dict build-up. See issue #14775. */
        untrack_dicts(young);
        long_lived_pending = 0;
        long_lived_total = gc_list_size(young);
    }

    /* All objects in unreachable are trash, but objects reachable from
     * finalizers can't safely be deleted.  Python programmers should take
     * care not to create such things.  For Python, finalizers means
     * instance objects with __del__ methods.  Weakrefs with callbacks
     * can also call arbitrary Python code but they will be dealt with by
     * handle_weakrefs().
     */

     //自定义了__del__方法的对象称之为finalizer
     //将这些对象都放入finalizers列表中
    gc_list_init(&finalizers);
    /* Move the objects in unreachable with __del__ methods into `finalizers`.
	 * Objects moved into `finalizers` have gc_refs set to GC_REACHABLE; the
	 * objects remaining in unreachable are left at GC_TENTATIVELY_UNREACHABLE.
	 */
	 //注意此时unreachable中对象都是循环引用且不可达
	 //之所以还被标记为临时可达的状态
	 //将其中定义了__del__方法的移动到finalizers列表中
	 //移动后标记为可达状态（避免下一步move_finalizer_reachable中重复移动）
	 //这一步过后unreadchable中才是真正不可达但可回收的
    move_finalizers(&unreachable, &finalizers);

    /* finalizers contains the unreachable objects with a finalizer;
     * unreachable objects reachable *from* those are also uncollectable,
     * and we move those into the finalizers list too.
     */
    //循环引用中的finalizer cpython是无法回收的，finalizer引用的对象
    //必然也是无法回收的，因此也移动到finalizer中
    move_finalizer_reachable(&finalizers);

    /* Clear weakrefs and invoke callbacks as necessary. */
    //
    //调用weakref的回调
    m += handle_weakrefs(&unreachable, old);

    /* Call tp_clear on objects in the unreachable set.  This will cause
     * the reference cycles to be broken.  It may also cause some objects
     * in finalizers to be freed.
     */
     // 这时候unreachable都是循环引用不可达但可回收的

     // 注意里面的逻辑，通过破除循环引用，破除过程中clear方法中调用Py_DECREF
     // 触发引用计数回收器回收。
     //注意里面循环的写法，gc_list_move会不断修改collectable->gc.next指向的值，使得循环能继续下去

     //疑问：里面的判断条件if (collectable->gc.gc_next == gc)，为什么此时将gc放回old？？？
     //unreachable中不都是可回收的吗 而且根据PyGC_HEAD链表的初始化，此时gc不就是个链表头吗
     //真的指向任何对象吗
     //不会出现段错误吗
    delete_garbage(&unreachable, old);


    /* Append instances in the uncollectable set to a Python
     * reachable list of garbage.  The programmer has to deal with
     * this if they insist on creating this type of structure.
     */
     //将定义了__del__的挂到gc.garbage列表中
    handle_finalizers(&finalizers, old);
```

## gc优化

暂略，可参考[文档][9]。

## 其他参考资料

https://rushter.com/blog/python-garbage-collector/

https://hbprotoss.github.io/post/pythonla-ji-hui-shou-ji-zhi/

[0]:https://rushter.com/blog/python-memory-managment/
[1]:https://docs.python.org/2.7/reference/datamodel.html#object.__del__
[2]:https://docs.python.org/2.7/library/gc.html#gc.garbage
[3]:https://www.jianshu.com/p/8bb7cd3c1766
[4]:https://github.com/python/cpython/blob/2.7/Objects/intobject.c#L1061
[5]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L2093
[6]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L3001
[7]:https://github.com/python/cpython/blob/2.7/Objects/object.c#L2228
[8]:https://github.com/python/cpython/blob/2.7/Modules/gcmodule.c#L1492
[9]:https://devguide.python.org/garbage_collector/
[10]:https://github.com/python/cpython/blob/2.7/Modules/gcmodule.c#L866