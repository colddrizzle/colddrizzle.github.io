---
layout: post
title: python中函数、方法的cpython视角
description: ""
category: python
tags: [python,cpython]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

# 1、函数与方法的根本
从cpython层面看,所有的可执行逻辑最后一定是一个c函数或者一个python字节码函数。
在cpython中，这分别由两种类型实例来实现:PyCFunction_Type与PyFunction_Type。其中PyFunction_Type定义tp_descr_get函数，因而是一个描述符，该描述符接受一个obj与一个type类型将函数绑定到实例obj上,返回一个PyMethod_Type的实例，值得注意的是这一步是在访问该方法从而触发描述符协议的时候发生的，class对象的字典里存储的仍然是一个PyFunctionObject，这个下面会细说。

由此可见所有的函数或方法的调用操作，最终都是一个PyObject的调用操作，而所有的PyObject的调用操作执行逻辑都是一样的，定义在[PyObject_Call][4]函数中，其大致逻辑相当于如下:
```
 aPyObject(args) => type(aPyObject)->tp_call(aPyObject, args)
```

在这一步执行之前，cpython会先通过aPyObject。执行一个函数或方法包括两步，获得执行对象然后执行。

类对象方法会执行描述符协议。类实例方法则不会。

注意触发描述符协议的时候，会调用描述符对象的tp_descr_get方法，而调用该方法等价于

```
# 获得tp_descr_get方法 tp_descr_get方法是本身是描述符的slot方法
 desc_get_funcobj = type(descrobj).__getattribute__(descrobj,"__get__") 

type(desc_get_funcobj)->tp_call(desc_get_funcobj,args) #执行该方法

```

当cpython执行一个类对象或类实例的方法的时候，假设对象为o，方法名为f。伪代码相当于如下：

```
    # 在没有使用metaclass的时候，type(o)就是Type
    oPyObject = type(o).tp_getattro(o,f)

    # type(aPyObject)就是各种函数或方法类型
    type(aPyObject)->tp_call(aPyObject, args)

```


# 2、细分
下面我们根据函数定义与出现的位置不同，分别从cpython层面观察一个函数是如何被执行的。

## 1、内建函数
根据[源码][0],所有的内建函数被定义成了PyMethodDef结构体的数组。需要注意的是这个函数列表与[python文档][1]中内建函数的列表并不完全一致，原因是python文档中的内建函数列表严格来讲并不都是函数，`type()`看起来是个函数，实际上是python最顶层的那个`type`类型。这个PyMethodDef函数列表在[python启动时][2]被初始化。从[初始化逻辑][3]来看，这些函数分别包装成PyCFunctionObject填充到模块`__builtin__`的字典中。

当打开python交互式窗口的时候，模块`__builtin__`就被自动导入到当前`__main__`模块中。于是当访问内建函数的时候，就会调用`PyModule_Type`的`tp_getattro`也就是`PyObject_GenericGetAttr`来访问该函数。注意PyCFunction_Type不是描述符类型。

拿到PyCFunctionObject之后，python解释器接着就是处理`()`操作符，最终以拿到的PyCFunctionObject为参数调用PyCFunction_Call()函数。

## 2、自定义函数
当python解释器遇到在模块层面定义的函数的时候，将其包装成一个PyFunctionObject设置到当前模块的`tp_dict`中。余下就跟内建函数一样了。
需要注意的是，虽然PyFunction_Type是描述符，但**描述符协议只有在通过`__getattribute__\__getattr__`访问类型属性时才会触发**，因此从模块中访问函数仍然得到的是PyFunctionObject。

## 3、类中的方法

理解本节内之前，首先要把握下面这两个方法绑定的目标要求：

* 类中类方法为类以及类的所有子类所定义。
* 类中实例方法为类实例以及类的子类的实例所定义。

如此，当调用a.b()的时候，找到b方法的时候就会检查b方法是类方法还是实例方法，并且检查a是否符合b方法的目标要求。

### 1、类型中方法的查找与执行
类型中方法调用直接首先是找到方法，下面我们考察在没有自定义`__getattr__与__getattribute__`的情况下，方法的是如何查找的。

```
假设执行any_obj.any_func(args)

会被翻译成字节码

LOAD_NAME     (any_obj)
LOAD_ATTR     (any_func)
LOAD_CONST    (args)
CALL_FUNCTION 

其中前两行可以翻译成如下伪代码:
callable_object = TYPE(any_obj)->tp_getattro(any_obj, 'any_func')

后两行可以翻译成如下伪代码：
TYPE(callable_object)->tp_call(callable_object, args)
```

LOAD_ATTR最终执行如下函数：
<pre class="brush:c;">

        //ceval.c
        TARGET(LOAD_ATTR)
        {
            w = GETITEM(names, oparg);
            v = TOP();
            x = PyObject_GetAttr(v, w);
            Py_DECREF(v);
            SET_TOP(x);
            if (x != NULL) DISPATCH();
            break;
        }
 /****************************************/
 //PyObject_GetAttr简化后如下：

PyObject *
PyObject_GetAttr(PyObject *v, PyObject *name)
{
    PyTypeObject *tp = Py_TYPE(v);

    if (tp->tp_getattro != NULL)
        return (*tp->tp_getattro)(v, name);
    if (tp->tp_getattr != NULL)
        return (*tp->tp_getattr)(v, PyString_AS_STRING(name));
    return NULL;
}

</pre>


所有的类方法都是以描述符对象的方式存储在类对象的字典中的。当查找到类方法any_func的时候，会触发描述符协议（只要是从类型中访问属性就会触发描述符协议），执行该描述符对象的
`tp_descr_get`也就是`__get__`方法。因为不同类型的类方法对应的描述符对象不同，转换为callable_object的方式也不同。后面我们会分情况讨论。

上面的any_obj可以是任意对象。但是类型与类型实例的tp_getattro不同。下面我们先根据any_obj是类型还是类型实例来讨论不同的tp_getattro()方法，讨论的前提都是没有覆盖任何默认的
`__getattr__`与`__getattribute__`的情况，若有覆盖的情况，请参考cpython属性查找一文。

#### 1. 通过类型来访问
若`isinstance(any_obj,type) == True`，则tp_getattro为[type_getattro(type, func_name)][12]方法。
假如我们执行的是`type_obj.any_func`，`type_getattro`将先后在type_obj的mro以及type(type_obj)的mro中寻找any_func。
假若找到了且是描述符则触发描述符协议，注意，不同的mro最后调用`descr->tp_descr_get`时传递的参数不一样，如下图：

![img](/assets/resources/cpython_func_type_bind.PNG){:width="100%"}

至于`descr->tp_descr_get`如何处理这些参数，我们将在下面分情况讨论。

#### 2. 通过类型实例来访问
若`isinstance(any_obj,type) == False`，则tp_getattro为[PyObject_GenericGetAttr(obj, func_name)][13]方法。
假如我们执行的是`obj.any_func`，`type_getattro`将先后在obj的字典中寻找any_func，假若找到了就原样返回。

否则在type(obj)的mro中寻找any_func描述符，假若找到了就触发描述符协议，注意调用`tp_descr_get`时传递的参数。如下图：

![img](/assets/resources/cpython_func_obj_bind.PNG){:width="100%"}

不同的描述符的`descr->tp_descr_get`处理参数的方法也不同，我们将在下面分情况讨论，下面讨论的基本方法是：首先弄清楚各种方法最终包装成了什么样的描述符。
然后看上面讨论的4种情况下描述符协议触发时是如何执行的。


### 2、类型中的内建方法
内建方法可以分为两类：一类通过slots，一类为c函数。slots与c函数的区别在于，slots最终的函数逻辑不一定是c语言实现的，大部分仅仅是一个桥接作用。

#### 1、slots原理
所有的类型共用一套slots定义，在类创建完执行PyType_Ready()的[add_operators()][5]方法时，将类型定义了值的字段包装成一个`PyWrapperDescrObject`对象，该对象是一个描述符。
当访问该函数触发描述符协议后，执行

<pre class="brush:c;">

static PyObject *
wrapperdescr_get(PyWrapperDescrObject *descr, PyObject *obj, PyObject *type)
{
    PyObject *res;

    if (descr_check((PyDescrObject *)descr, obj, &res))
        return res;
    return PyWrapper_New((PyObject *)descr, obj);
}

</pre>

上述代码返回一个callable对象wrapperobject，其self指向obj。

##### 1. 通过类型来调用slots方法

下面我们考察在没有自定义`__getattr__与__getattribute__`的情况下，若是通过类型来调用slots方法的情况，也就是执行
`type_obj.slot_func`的情况。

###### 1.slot_func定义在type_obj以及其基类中

如果`slot_func`包装成的描述符对象`PyWrapperDescrObject`最终在`type_obj`的`mro`类列表中找到，根据2.3.1.1节，触发描述符协议时执行
`wrapperdescr_get(slot_func_descr, NULL, type_obj)`。

可以看到[wrapperdescr_get][14]最终传入的obj为NULL。在[descr_check][15]阶段，返回一个描述符对象本身。

例子: 

![img](/assets/resources/cpython_func_slots_type_bind.PNG)

上图中slot-wrapper就是`PyWrapperDescrObject`。

###### 2.slot_func定义在TYPE(type_obj)以及其基类中

如果`slot_func`包装成的描述符PyWrapperDescrObject最终在`TYPE(type_obj)`的`mro`类列表中找到，且`type_obj`的`mro`类列表中没有覆盖`slot_func`，根据2.3.1.1节，触发描述符协议时执行`wrapperdescr_get(slot_func_descr, type_obj, type(type_obj))`。

根据[PyWrapper_new][16]方法，最终返回一个绑定了type_obj的`wrapperobject` callable对象。这种情况就是在自定义metaclass中定义方法的情况，自定义类的`__call__\__new__`方法以及一些内建对象的`__call__`方法。

例子：

![img](/assets/resources/cpython_func_slots_type_bind_1.PNG)

上图中method_wrapper就是wrapperobject对象。

以上面知识的分析：
https://docs.python.org/2.7/reference/datamodel.html#customizing-attribute-access

##### 2. 通过类型实例来调用slots方法

若是通过类型的实例来调用，执行`obj.slot_func`，我们根据2.3.1.2节的内容讨论分别发生的情况。

###### 1.若slot_func在obj的字典找到

根据2.3.1.2节，若slots方法在类实例字典中找到，则原样返回。类实例字典中一般不会有slots方法，但我们可以构造一个。但是调用会出错，为什么呢？

<pre class="brush:python;">
class Cls(object):
    pass


c = Cls()

c.a = 1
d = object.__dict__['__getattribute__']
print d
c.__getattribute__ = d
print c.__dict__
print c.__getattribute('a') # error
#print c.__getattribute__(c, 'a') #虽然通过c调用但原样返回并不绑定c，因此参数里还要再传一次。

</pre>


因为从实例中原样返回的是一个`PyWrapperDescrObject`，对其调用最终走到`PyObject_Call(PyWrapperDescrObject, args)`，也就是
`PyWrapperDescr_Type.tp_call(PyWrapperDescrObject,args)`，`tp_call为wrapperdescr_call方法`。我们只需要填充上合适的参数就可以了。根据`wrapperdescr_call`，其作用将描述符对象转为`wrapperobject`对象并调用之。因此与触发描述符协议并调用是一致的。所需的参数就是`wrapperobject`的待绑定对象以及`__getattribute__`的参数，也就是注释中部分。

###### 2.若slot_func在TYPE(obj)以及其基类字典找到

如果`slot_func`包装成的描述符`PyWrapperDescrObject`最终在`TYPE(obj)`的`mro`类列表中找到，且`obj`的字典中没有覆盖`slot_func`，根据2.3.1.2节，触发描述符协议时执行`wrapperdescr_get(slot_func_descr, obj, type(obj))`。

根据[PyWrapper_new][16]方法，最终返回一个绑定了obj的`wrapperobject` callable对象。

例子：

![img](/assets/resources/cpython_func_slots_obj_bind_0.PNG)

##### 3. 类中slot方法调用绑定结果总结

slots方法本质上是实例方法，无论是通过类型还是实例调用`a.slot_func`，若方法最终type(a)及其基类中找到，则绑定到a对象。

若slots方法通过类型调用且在a或a的基类中找到，显然是通过类引用未绑定方法。

##### 4. wrapperobject的执行

PyWrapper_New函数将PyWrapperDescrObject与当前self包装成一个`wrappertype`也就是`method-wrapper`对象，然后调用该对象，也就是以之为参数调用PyObject_Call，最终执行wrappertype的tp_call函数，也就是wrapper_call。

<pre class="brush:c;">
static PyObject *
wrapper_call(wrapperobject *wp, PyObject *args, PyObject *kwds)
{
    wrapperfunc wrapper = wp->descr->d_base->wrapper;
    PyObject *self = wp->self;

    if (wp->descr->d_base->flags & PyWrapperFlag_KEYWORDS) {
        wrapperfunc_kwds wk = (wrapperfunc_kwds)wrapper;
        return (*wk)(self, args, wp->descr->d_wrapped, kwds);
    }

    if (kwds != NULL && (!PyDict_Check(kwds) || PyDict_Size(kwds) != 0)) {
        PyErr_Format(PyExc_TypeError,
                     "wrapper %s doesn't take keyword arguments",
                     wp->descr->d_base->name);
        return NULL;
    }
    return (*wrapper)(self, args, wp->descr->d_wrapped);
}
</pre>

如上图，wrapper是定义于slotdef的检测参数与返回值的包装函数，d_wrapped是实际执行的c函数。` (*wrapper)(self, args, wp->descr->d_wrapped)`可以近似看做是
`check_args(); wp->descr->d_wrapped(self, args); check_results();`

#### 2、c函数实现原理
以list对象的append方法为例，在listobject.c中定义了[PyMethodDef数组][6]，
类型创建的PyType_Ready()方法中[add_methods][7]方法分别被包装成静态方法、类方法、与实例方法。我们重点关注实例方法。c函数实现的实例方法被包装成`PyMethodDescrObject`，该对象是一个描述符。其`tp_descr_get`方法为:

<pre class="brush:c;">
method_get(PyMethodDescrObject *descr, PyObject *obj, PyObject *type)
{
    PyObject *res;

    if (descr_check((PyDescrObject *)descr, obj, &res))
        return res;
    return PyCFunction_New(descr->d_method, obj);
}
</pre>

##### 1. 通过类型调用类中C函数方法
我们只讨论C函数方法在类型的mro中找到的情况，也就是`list.append`的情况。

当执行`list.append`的时候等价于执行`type(list).__getattribute__(list,"append")`，触发描述符协议:

根据2.3.1.1节内容，触发描述符协议执行`method_get(descr, NULL, type(list))`。在`descr_check`阶段原样返回。

![img](/assets/resources/cpython_c_method_type_bind.png)


##### 2. 通过实例调用类中C函数方法

我们还是只讨论C函数方法在实例的类型及其mro找的情况，也就是`[1,2,3].append`的情况。

根据2.3.1.2节内容，触发描述符协议时执行`method_get(descr, obj, type(obj))`， 其中obj为`[1,2,3]`这个list实例，最终执行的是`PyCFunction_NewEx`，返回一个绑定了对象`[1,2,3]`的`PyCFunctionObject`对象。

![img](/assets/resources/cpython_c_method_obj_bind.png)

### 3、类型中的自定义方法

类型中自定义方法可以分为静态方法、类方法与普通方法。在编译阶段的分别包装成`PyStaticMethodObject`、`PyClassmethodObject`与`PyFunctionObject`。

触发描述符协议后其`tp_descr_get`方法分别如下:

<pre class="brush:c;">

// StaticMethodType.tp_descr_get
static PyObject *
sm_descr_get(PyObject *self, PyObject *obj, PyObject *type)
{
    staticmethod *sm = (staticmethod *)self;

    if (sm->sm_callable == NULL) {
        PyErr_SetString(PyExc_RuntimeError,
                        "uninitialized staticmethod object");
        return NULL;
    }
    Py_INCREF(sm->sm_callable);
    return sm->sm_callable;
}

//ClassMethodType.tp_descr_get
static PyObject *
cm_descr_get(PyObject *self, PyObject *obj, PyObject *type)
{
    classmethod *cm = (classmethod *)self;

    if (cm->cm_callable == NULL) {
        PyErr_SetString(PyExc_RuntimeError,
                        "uninitialized classmethod object");
        return NULL;
    }
    if (type == NULL)
        type = (PyObject *)(Py_TYPE(obj));
    return PyMethod_New(cm->cm_callable,
                        type, (PyObject *)(Py_TYPE(type)));
}

//PyFunctionType.tp_descr_get
/* Bind a function to an object */
static PyObject *
func_descr_get(PyObject *func, PyObject *obj, PyObject *type)
{
    if (obj == Py_None)
        obj = NULL;
    return PyMethod_New(func, obj, type);
}
</pre>  

下面我们以下面的例子，分析三种方法在2.3.1节的4中情况下的描述符协议执行情况。
<pre class="brush:python;">
class Meta(type):
    @staticmethod
    def m_sfoo():
        pass

    @classmethod
    def m_clsfoo(cls):
        pass

    def m_foo(self):
        pass


class CLS(object):
    __metaclass__ = Meta
    @staticmethod
    def sfoo():
        pass

    @classmethod
    def clsfoo(cls):
        pass

    def foo(self):
        pass

#CASE 1
print CLS.m_sfoo
print CLS.m_clsfoo
print CLS.m_foo

#CASE_2
print CLS.sfoo
print CLS.clsfoo
print CLS.foo

#CASE_3
cls = CLS()
print cls.sfoo
print cls.clsfoo
print cls.foo

#CASE 4
cls.local_foo = lambda :1
print cls.local_foo

#CASE 5
print cls.m_foo
</pre>>

#### 1.通过类型type_obj访问且方法定义于TYPE(type_obj)或其MRO中
上面例子中的CASE1。根据2.3.1.1节，执行`tp_descr_get(descr, type_obj, type(type_obj))`。对照静态方法、类方法、普通方法的描述符对象的`tp_descr_get`方法。
可以看出：

静态方法返回描述符里面的callable对象，也就是一个`PyFunctionObject`对象。

类方法返回一个绑定了TYPE(type_obj)的`PyMethodObject`对象。

普通方法返回一个绑定了type_obj的`PyMethodObject`对象。

#### 2.通过类型type_obj访问且方法定义于type_obj或其MRO中

上面例子中的CASE2。根据2.3.1.1节，执行`tp_descr_get(descr, NULL, type_obj)`。对照静态方法、类方法、普通方法的描述符对象的`tp_descr_get`方法。
可以看出：

静态方法返回描述符里面的callable对象，也就是一个`PyFunctionObject`对象。

类方法返回一个绑定了type_obj的`PyMethodObject`对象。

普通方法返回一个未绑定的`PyMethodObject`对象。

#### 3.通过实例obj访问且方法定义于TYPE(obj)或其MRO中
上面例子中的CASE3。根据2.3.1.2节，执行`tp_descr_get(descr, obj, type(obj))`。对照静态方法、类方法、普通方法的描述符对象的`tp_descr_get`方法。
可以看出：

静态方法返回描述符里面的callable对象，也就是一个`PyFunctionObject`对象。

类方法返回一个绑定了type(obj)的`PyMethodObject`对象。

普通方法返回一个绑定了obj的`PyMethodObject`对象。

#### 4.通过实例obj访问其方法定义于obj的字典中
上面例子中的CASE4。根据2.3.1.2节，原样返回各自的描述符对象。注意除了`PyFunctionObject`是callable对象外，其余俩都不是callable对象。


可以看出类方法绝对不会出现unbound的情况，而普通方法通过类型来调用是会出现unbound的情况的。

上面python例子的结果:
```
Traceback (most recent call last):
  File "G:/pycharm_projects/compile_source/attr_lookup2.py", line 48, in <module>
    print cls.m_foo
AttributeError: 'CLS' object has no attribute 'm_foo'
<function m_sfoo at 0x0000000002338588>
<bound method type.m_clsfoo of <class '__main__.Meta'>>
<bound method Meta.m_foo of <class '__main__.CLS'>>
<function sfoo at 0x00000000023386D8>
<bound method Meta.clsfoo of <class '__main__.CLS'>>
<unbound method CLS.foo>
<function sfoo at 0x00000000023386D8>
<bound method Meta.clsfoo of <class '__main__.CLS'>>
<bound method CLS.foo of <__main__.CLS object at 0x000000000232FCC0>>
<function <lambda> at 0x0000000001DD35F8>
```

# 3、总结

总结一下类型中各种方法cpython内部对象的对应关系：

--|dict存储对象类型|dict存储对象名字| dict存储对象repr |描述符转换后对象类型|描述符转换后对象名字 |描述符转换后对象repr
-|-|-|-|-|-|
slots方法|PyWrapperDescr_Type|wrapper_descriptor|slot wrapper|wrappertype|method-wrapper|method-wrapper
c函数|PyMethodDescr_Type|method_descriptor|method|PyCFunction_Type|builtin_function_or_method|built-in function/built-in method(根据self=None?)
自定义普通方法|PyFunction_Type|function|function|PyMethod_Type|instancemethod|bound method/unbound method(根据obj=None?)
自定义静态方法|PyStaticMethod_Type|staticmethod|未定义|PyFunction_Type|function|function
自定义类方法|PyClassMethod_Type|classmethod|未定义|PyMethod_Type|instancemethod|bound method

python中没有函数重载，查找过程甚至不区分函数类型（类函数、静态函数、普通函数）


类型访问类型类型的普通方法 与 实例访问实例类型的普通方法 是一致的。也就是：
```
__mro__['foo']表示方法定义其mro类列表的任意一个字典中。

若TYPE(type_obj).__mro__['foo'] = any_func
则type_obj.any_func  绑定到 type_obj

与下面情况一致:

若TYPE(obj).__mro__['foo'] = any_func
则obj.any_func 绑定到obj

```

待续：各种描述符的__get__方法


# 4、场景分析

## 问题1：属性的无穷级联查找?

上面讲list.append等同于`type(list).__getattribute__(list,"append")`，但是`__getattribute__`本身又是一次属性访问，
所以相当于`type(type(list)).__getattribute__(type(list),"__getattribute__")(list,"append")`，如此无穷级联下去吗？

从逻辑上讲是这样的，但是python的类型系统里面类型链的根是个死循环`type(type) = type`，所以无论级联调用多少次，最后都是
`type_getattro`的嵌套调用而已，最后变成了`type.__getattribute__ = type.__getattribute__(type,"__getattribute__") = type.__getattribute(type,"__getattribute")(type,"__getattribute__")`。

![img](/assets/resources/cpython_function_call_0.png)

况且上面的的级联推导只是python层面，于cpython的层面，当编译器遇到`list.append`的时候，内部第一步翻译确实相当于`type(list).__getattribute__(list,"append")`，
但已经是C代码了，其实是`TYPE(list)->tp_getattro(list,"append")`已经可以执行出结果了。

## 问题2：无穷`__call__`?

类似的问题，我们知道对于callable对象，'()'操作相当于执行`__call__()`。那么`func()`相当于`func.__call__()`，相当于`func.__call__.__call__()`，相当于执行`func.__call__.__call__.__call__()`，那最终是如何执行的呢？

执行一个方法首先是通过`__getattribute__`找到这个方法,假设上例中是一个`PyFunction_Type`对象。
那么`func.__call__()`相当于`type(func).__getattribute__(func,'__call__')()`。

![img](/assets/resources/cpython_function_call_1.png)

我们知道`__call__`方法是个`slot_wrapper`,也就是
`PyWrapperDescrObject`对象，触发描述符协议后返回的是`wrappertype`。然后就是再对`wrappertype`的`__call__`属性的调用。
也就是`type(wrappertype).__getattribute__(wrappertype,'__call__')()`，然后`type(wrappertype) == type`，等价于`type.__getattribute__(wrappertype,'__call__')()`。`wrappertype`的`__call__`属性自然也是一个`slot_wrapper`，触发描述符协议后返回的还是`wrappertype`。所以最后变成了`wrappertype`的`__call__`属性还是`wrappertype`的这样一个循环中。
注意下图中的`wappertype`的地址不同，因为每次触发描述符协议都会新创建一个`wrappertype`。



[0]:https://github.com/python/cpython/blob/2.7/Python/bltinmodule.c#L2626
[1]:https://docs.python.org/2/library/functions.html
[2]:https://github.com/python/cpython/blob/2.7/Python/bltinmodule.c#L2689
[3]:https://github.com/python/cpython/blob/2.7/Python/modsupport.c#L31
[4]:https://github.com/python/cpython/blob/2.7/Objects/abstract.c#L2536
[5]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L6566
[6]:https://github.com/python/cpython/blob/2.7/Objects/listobject.c#L2510
[7]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L3726
[8]:https://github.com/python/cpython/blob/2.7/Objects/object.c#L1176
[9]:https://github.com/python/cpython/blob/2.7/Objects/funcobject.c#L535
[10]:https://github.com/python/cpython/blob/2.7/Objects/object.c#L1331
[11]:https://github.com/python/cpython/blob/2.7/Objects/classobject.c#L2414

[12]:https://github.com/python/cpython/blob/3.8/Objects/typeobject.c#L3187
[13]:https://github.com/python/cpython/blob/2.7/Objects/object.c#L1463
[14]:https://github.com/python/cpython/blob/2.7/Objects/descrobject.c#L154
[15]:https://github.com/python/cpython/blob/2.7/Objects/descrobject.c#L59
[16]:https://github.com/python/cpython/blob/2.7/Objects/descrobject.c#L1094