---
layout: post
category : python
tags : [python, cpython]
title: cpython源码阅读之类与实例的创建
---
{% include JB/setup %}

本篇将大概分析cpython中类对象与实例对象的创建过程，其中新式类与经典类在cpython层面是不同的实现，对于经典类仅仅指出其代码位置不做分析。
文中出现的type与object若无特别说明都是指的python中最基础的那两个类型对象。
<hr />

我们仍然使用问题牵引的方法来展开我们的分析。

* 问题一
从python层面观察，用户自定义类是type的实例，而type的实例是类型，然而用户自定义的类的实例通常情况却不是类型，type、用户自定义类型、类型实例不都是对象吗，之间为什么会有这种区别？对象的区别仅仅在于属性与方法的区别而已才对，那么这些对象的不同是单纯的因为属性与方法不同吗？
![img](/assets/resources/cpython_class&object_2.png){:width="100%"}

* 问题二
 ![img](/assets/resources/cpython_class&object_1.png){:width="100%"}

  从图中看出, type是type的实例，type是object的子类，而object又是type的实例。也就是说type与object都是type的实例，但同时type还是object的子类。 如何理解type与object之间的这种古怪的关系，这种关系是怎么实现的

* 问题三
  指定元类与类继承的情况下用户自定义类是怎么创建的

* 问题四
  用户自定义类是怎么创建实例的
* 问题五
  内建类与内建函数按照python的世界观也应该是对象，他们又是怎么创建的

<hr />
下面我们将通过跟踪调试代码的方式来一一探求这些问题。


<hr/>
下面为以上探求的一个总结

## 基本定义
cpython中除了经典类之外的类型（内建类型、新式类）都是结构体PyTypeObject的一个实例。

需要注意的是这个结构体的几个特殊字段：

* tp_subclasses 其实每个类型 cpython维护了其所有的子类型列表。也就是说不仅有bases也有subclasses，继承关系在cpython内是双向链接的有向无环图结构。

* tp_slots 一个slots代表一个C语言层面的属性或函数。这个slots在tp_dicts中映射成python对象层面的属性与函数，而且是多对多映射，这部分在文章python中方法的执行一文中会详细讲。

* tp_flags ？？？

* tp_getset python里有描述符的概念，将属性访问映射到函数调用。getset就像是在c语言层面的描述符，当读写一个属性的时候，不是访问一个值，而是调用一个函数。

## 内建类型的创建
所有内建类型的创建都是通过[PyType_Ready()][0]这个函数初始化的，这一点可以在[_Py_ReadyTypes(void)][1]函数中看到。
这个`_Py_ReadyTypes(void)`就是cpython启动的时候过程之一。

而在此之前，首先通过创建`PyTypeObject`的实例声明一个内建类型，并填充一些关键字段，以`PyType_Type`为例,
从[PyType_Type声明的源码][2]中可以看到，创建实例的时候填充了一些字段，而有些字段则为0，意义是空指针。

`PyType_Ready()`函数接受一个`PyTypeObject`类型的指针，其主要工作流程是：
1. 设置tp_base。当然内建类型的tp_base都已经在声明时候设置好了,值的注意的是只有PyBaseObject_Type的base为null，也就是说python中最基础的那个object没有父类。
    <pre class="brush:c;">
      // Initialize tp_base (defaults to BaseObject unless that's us)
      base = type->tp_base;
      if (base == NULL && type != &PyBaseObject_Type) {
          base = type->tp_base = &PyBaseObject_Type;
          Py_INCREF(base);
      }

      // Now the only way base can still be NULL is if type is
      // &PyBaseObject_Type.
    </pre>
如果tp_base表示的类型没有初始化，则执行`PyType_Ready(tp_base)`初始化他。可以看到这里除了`PyBaseObject_Type`之外的类型其`tp_base`都被设置成了`PyBaseObject_Type`。这里有个疑问，我们知道metaclass一般是继承自type的，当metaclass创建的时候又会发生什么呢？[源码][3]
2. 初始化tp_dict。[源码][4]。
    1. 添加操作符
    2. 添加结构体预定义的methods到tp_dict。
    3. 添加结构体预定义的members到tp_dict。
    4. 添加结构体预定义的getset到tp_dict。

3. 计算mro
4. 继承一个特别方法与属性。[源码][5]。其中最重要的是tp_new的继承。
    <pre class="brush:c;">
          if (type->tp_flags & base->tp_flags & Py_TPFLAGS_HAVE_CLASS) {
              if (base != &PyBaseObject_Type ||
                  (type->tp_flags & Py_TPFLAGS_HEAPTYPE)) {
                  if (type->tp_new == NULL)
                      type->tp_new = base->tp_new;
              }
          }
    </pre>
5. 继承slots，`inherit_slots`。最重要的是`tp_init`的继承。

6. 给每个base类型的tp_subclasses列表添加当前类型引用。

至此，一个内建类型就创建完成了。

![built_in_type](/assets/resources/built_in_type.png){:width="100%"}

## 用户自定义类的创建
当cpython遇到用户自定义代码是:
<pre class="brush:python;">
class ClassA(object):
  def hi(self):
      print "Hi!"

class ClassB(ClassA):
  def hi(self):
      print "Hi!"

class ClassC(ClassB):
  def hi(self):
      print "Hi!"

class ClassD:
  def hi(self):
      print "Hi!"
</pre>
是怎么样创建这个类型的呢？我们通过跟踪cpython源码来得知这一点。
python代码被cpython读取后经过语法分析到语义执行阶段，
真正执行创建类的这个语义的地方在`ceval.c`的`build_class()`函数中。[源码][6]。
将上述代码保存到文件cls.py中。用vs打开cpython2.7源码后，在默认的启动项目python设置项目属性，调试命令参数里附上cls.py的文件路径。
那么cpython启动时将执行该文件，就像我们在命令行中执行`python cls.py`。
在`build_class`中设置断点与断点条件，然后就可以调试了。
![img](/assets/resources/cpython_build_class_b0.png)

`build_class`的逻辑非常简单，主要是确定待创建类型的metaclass:
* 如果类中指定了`__metaclass__`，那么使用它。
* 否则从传入的bases参数取出第一个base，然后**取它的`__class__`字段作为metaclass**。所以python2中要求新式类必须继承自object，新式类必不为空。
* 如果是经典类，这个bases是空，则会先查看一个全局字典里有没有`__metaclass__`字段。若没有，直接指定`metaclass = (PyObject *) &PyClass_Type;`，这个PyClass_Type就是经典类的类型。
经过上面步骤确定meteclass，注意这个metaclass必然是一个PyTypeObject的指针。然后就是`build_class()`方法的核心调用:
<pre class="brush:c;">
result = PyObject_CallFunctionObjArgs(metaclass, name, bases, methods,
                                      NULL);
</pre>
`PyObject_CallFunctionObjArgs()`函数里做一些参数检测之后，最后调用到`PyObject_Call()`[源码][7]。核心逻辑是如下两行：
<pre class="brush:c;">
call = func->ob_type->tp_call;
result = (*call)(func, arg, kw);
</pre>

注意在`build_class`逻辑中确定metaclass的时候，已经取了父类的类型，所以这里的`func`就是父类的类型，然后这里又取了该类型的`ob_type`字段。
那么对于我们的ClassB来说，其父类是ClassA，ClassA的类型为type，然后又取了type的`ob_type`字段，而type也就是`PyType_Type`在声明是指定了其类型为自身。
因此，这里的`call`函数也就是`PyType_Type`的`tp_call`字段。

同理，假如待创建的类型是ClassC，虽然看上去ClassC的继承体系深一点，然而在取ClassC的父类型ClassB的类型之后，其metaclass也变成了type。也就是说，因为所有的类型对象的类型都是type，因此无论多深的继承体系，在没指定`__metaclass__`的情况下，其metaclass一定type。

因此，创建用户自定义类型，就是把bases，methods等参数传递给`PyType_Type`的`tp_call`函数。

需要注意的是，这个tp_call并不是从python层面的调用`type.__call__()`，结构体定义看tp_call为type_call，从slotsdef中映射了`__call__`为slot_tp_call，后者才是`type.__call__`的实际映射的函数。

我们先来看`PyType_Type`的`tp_call`函数也即是[type_call()][8]做了什么?下面是简化扼要的代码:

<pre class='brush:c;'>
static PyObject *
type_call(PyTypeObject *type, PyObject *args, PyObject *kwds)
{
    PyObject *obj;
    obj = type->tp_new(type, args, kwds);
    if (obj != NULL) {
        /* Ugly exception: when the call was type(something),
           don't call tp_init on the result. */
        if (type == &PyType_Type &&
            PyTuple_Check(args) && PyTuple_GET_SIZE(args) == 1 &&
            (kwds == NULL ||
             (PyDict_Check(kwds) && PyDict_Size(kwds) == 0)))
            return obj;
        /* If the returned object is not an instance of type,
           it won't be initialized. */
        if (!PyType_IsSubtype(obj->ob_type, type))
            return obj;
        type = obj->ob_type;
        if (PyType_HasFeature(type, Py_TPFLAGS_HAVE_CLASS) &&
            type->tp_init != NULL &&
            type->tp_init(obj, args, kwds) < 0) {
            Py_DECREF(obj);
            obj = NULL;
        }
    }
    return obj;
}

</pre>
在我们的例子里，参数type就是PyType_Type。可以看到，首先调用tp_new()，根据结构体初始化的值，也即是[type_new()][9]，该函数非常长，也是最终负责分配内存创建一个PyTypeObject类型对象的代码,其主要逻辑:
1. 分配内存 `type = (PyTypeObject *)metatype->tp_alloc(metatype, nslots);` alloc函数还会将对象的类型字段ob_type设置为metatype。
2. 填充字段，特别是base字段与tp_alloc字段` type->tp_alloc = PyType_GenericAlloc;`
3. 调用PyType_Ready()，据上面可知，这个函数会从base继承tp_new与tp_init字段。

然后下面判断是否要调用tp_Init的逻辑：第一种是type自身，第二种是经典类，第三种则是自定义类与类实例，也就是我们关心的情况。

这里需要关注的是tp_new创建自定义类的时候，tp_call，tp_new，tp_init这几个字段是如何填充的，因为这关系到定义类创建的实例的行为，特别需要注意的是用户自定义类型的tp_call字段为空。那么当用户自定义类型创建实例的时候，会发生什么呢？下面会看到，其实是借助于PyObject_Call函数。只有内建类型的tp_call字段不为空。
那么一个问题是PyFunction_Type与用户自定义类型同为次生类型，为什么创建实例的时候tp_call与PyObject_Call不同的路径？


但无论怎样，至此，一个用户自定义类型创建完成了。

前面讲过，没有指定`__metaclass__`这里的参数type一定是PyType_Type。那么指定了`__metaclass__`的情况下，又如何呢？稍后分析。


[slot_tp_call()][10]代码如下：

<pre class='brush:c;'>
static PyObject *
slot_tp_call(PyObject *self, PyObject *args, PyObject *kwds)
{
    static PyObject *call_str;
    PyObject *meth = lookup_method(self, "__call__", &call_str);
    PyObject *res;

    if (meth == NULL)
        return NULL;

    res = PyObject_Call(meth, args, kwds);

    Py_DECREF(meth);
    return res;
}
</pre>

两幅总体概览图：
![user_define_type_1](/assets/resources/user_define_type_1.png){:width="100%"}
![user_define_type_2](/assets/resources/user_define_type_2.png){:width="100%"}


## 用户自定义类型实例的创建
还是以上面的python代码为例，当我们执行`ClassB()`的时候，会创建一个ClassB的实例，那么cpython层面，发生了什么呢？
在object_new()函数出打上断点附上条件如图：

![img](/assets/resources/object_new_breakpoint.png)

函数调用栈如图：

![img](/assets/resources/object_new_function_call_stack.png)

根据上一节内容，用户自定义类的tp_new继承自object，自然是object_new函数。我们的重点还是看[object_nwe][10]函数逻辑以及其中5个字段的设置。
可以看到，object_new函数主要逻辑只有` return type->tp_alloc(type, 0);`。也就是设置了object的tp_type字段。其余字段全为空。

而当用户自定义类型中定理了__call__方法的时候，执行自定义类型的实例将会发生什么呢？
修改调试的python代码为
<pre class="brush:python;">
class ClassA(object):
    def hi(self):
        print "Hi!"

class ClassB(ClassA):
    def hi(self):
        print "Hi!"

    def __call__(self):
        print "instance call"
b = ClassB()
b()
</pre>
并且在PyObject_Call中打断点如图：
![img](/assets/resources/instance_call_breakpoint.png)

可以观察到`func->ob_type`就是ClassB的PyTypeObject。其tp_call字段被设置为了slot_tp_call，而slot_tp_call则会调用__call__方法。

那么显然创建用户自定义类ClassB的时候，如果类定义中有__call__方法，那么才会添加slot_tp_call到tp_call字段。那么这一过程是在哪一步发生的呢？
通过跟踪type_new函数的过程，初步断定是在最后一步`fixup_slot_dispatchers()`中添加了slot_tp_call到tp_call字段。那么具体如何呢？

## 元类的创建

注意一个特点:type的类型还是type。
元类继承自type，根据继承创建规则，那么元类由type的类型创建，因此元类有type创建。

需要注意的是为什么type创建的元类不是次生类型？显然是因为元类继承自type，元类创建实例的时候
最终调用的是type_new。
也就是说 type创建的次生类型与元类的不同点就在于其继承的类型不同，一个是object，一个是type。

type_call(typeobj)里面一定会调用typeobj->tp_new的，是因为tp_new的不同，导致type创建类型是不是次生类型。

[0]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L4122
[1]:https://github.com/python/cpython/blob/2.7/Objects/object.c#L2073
[2]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L2879
[3]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L4152
[4]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L4191
[5]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L3810
[6]:https://github.com/python/cpython/blob/2.7/Python/ceval.c#L4981
[7]:https://github.com/python/cpython/blob/2.7/Objects/abstract.c#L2535
[8]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L737
[9]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L2093
[10]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L3001
