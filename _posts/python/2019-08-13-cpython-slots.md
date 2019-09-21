---
layout: post
title: cpython中slots
description: ""
category: python
tags: [python,cpython]
---
{% include JB/setup %}


<hr />
cpython中类型的内建函数与方法不少是通过slots实现的，然而slots本身比较复杂，这部分代码比较晦涩，因此本文以cpython2.7为例整理一下slots的原理与实现。

## 一、slotdefs定义
slot字面意义理解就是槽位，而type类型都是PyTypeObject结构体的一个实例，slot的作用就是给这个结构体字段绑定操作，因为slotdefs定义是固定的一组，因此不同的type类型可以共享相同的操作（当然slot大部分情况下是个代理、桥接作用）。

slotdefs本质是一个`wrapperbase`结构体的数组，见[源码][0]。而`wrapperbase`结构体字段如下:
```
struct wrapperbase {
    char *name;
    int offset;
    void *function;
    wrapperfunc wrapper;
    char *doc;
    int flags;
    PyObject *name_strobj;
};
```

name是slot在python层面的方法名
offset是slot在cpython结构体中对应字段的的偏移。
function是默认的桥接方法，该函数在update_one_slot中非规整情况下设置为对应字段的值。详见下面。
wrapper是封装offset所指向方法的，用来做一些参数检查，结果处理的事情。

slotdefs基本上就是字段对应函数的一个列表，需要注意的是函数与字段之间的四种对应关系：一对一，一对多，多对一，多对多。当一对一或一对多时候，我们不妨称该字段对应的所有函数为函数组。后面会看到函数组的一致性在slot的一致性继承中有重要作用。

**slotdefs数组的作用**
* 指定了字段与函数的对应关系
* 指定了一个函数对应多个字段时候的优先级顺序
* 废弃某些字段（开头的那些NULL条目）

那么slotdefs数组是如何发挥这三个作用的呢？
* 字段与函数的对应关系
  注意只有在add_operators()时，遍历slotdefs，如果类型结构体中相应offset的字段有定义且不为空，那么则用wrapper将该字段包装起来（实际上仅仅是组成一个PyWrapperDescrObject放入tp_dict，实际的包装过程发生在调用时），若自定义函数或者内建函数的tp_methods覆盖了这些方法，则更新tp_dict中对应的函数。从而一个字段对应的函数绝不会是slotdefs定义之外的东西。
  但是反过来也是如此，一个类型的某个函数出现在slotdefs中，那么通过tp_dict访问与通过类型内对应字段访问结果是一样的，这种一致性是cpython保证了的，下面会看到。
* 多个字段的优先级顺序
  注意只有在add_operators()阶段，会安装slotdefs顺序的添加函数，若是一个函数对应多个字段，
  那么后面的字段对应的函数就会被跳过（因此没有内建类型会同时指定一个函数的多个字段，因为这没有意义）。
* 废弃某些字段
  在add_operators()阶段根据wrapper为空，跳过这些字段。
  在fixup_slot_dispatchers阶段,因为必然找不到该字段对应的WrapperDeser函数（因为所有的WrapperDeser函数都是add_operators产生的，但这被跳过了）。从而设置对应字段为slotdef中该条目的function字段，也就是NULL。
  以上两步保证了字段的废弃。

### slotdefs数组的一些结构特点
* 一个函数名对应多个字段的函数是固定有限的，且都是对应两个字段。
```
MPSLOT("__len__", mp_length, slot_mp_length, wrap_lenfunc,
       "x.__len__() <==> len(x)"),
    ..............
SQSLOT("__len__", sq_length, slot_sq_length, wrap_lenfunc,
       "x.__len__() <==> len(x)"),
```
这些相同名字也有多处，它们是:
```
__repr__
__str__
__getattribute__
__getattr__
__setattr__
__delattr__
__len__
__add__
__mul__
__rmul__
__getitem__
__setitem__
__delitem__
__iadd__
__imul__
```
* 一个字段对应多个函数的都是在数组内前后临接的
```
TPSLOT("__setattr__", tp_setattro, slot_tp_setattro, wrap_setattr,
       "x.__setattr__('name', value) <==> x.name = value"),
TPSLOT("__delattr__", tp_setattro, slot_tp_setattro, wrap_delattr,
       "x.__delattr__('name') <==> del x.name"),
```
可以看到第二个字段都是tp_setattro，而这个字段代表offset，它们在数组中位置前后相邻，其后的代码会利用这一点。还有很多其他相同offset的地方，不一一列举。

## 二、slot函数
  在创建类型必经的PyType_Ready（）函数的add_operator阶段，type类型的每个字段被包装成slot函数，对应的结构体是PyWrapperDescrObject，
  ```
  typedef struct {
      PyDescr_COMMON;
      struct wrapperbase *d_base;
      void *d_wrapped; /* This can be any function pointer */
  } PyWrapperDescrObject;
  ```

  其中d_base就是该字段对应的slotdef条目，d_wrapped是该类型对该字段定义的值。
  如list类型tp_richcompare字段值为list_richcompare。当add_operators阶段，遍历slotdefs，发现`__lt__`,`__gt__`等一众函数对应的字段都是tp_richcompare。因此依次为每个函数名创建一个slot函数。比如`__lt__`其d_base字段就是slotdefs中__lt__函数对应的条目，d_wrapped字段值就是list_richcompare。

## 三、slot函数访问的一致性与效率性

一个类型的字段若对应一个函数（对应关系必然跟slotdefs一致），那么访问这个函数就有两种方式，
通过tp_dict访问函数，或者通过对应字段直接访问，而有时候字段对应的函数被其他方式（methods、自定义函数）覆盖掉，因此不再是字段定义的值对应的逻辑，此时该字段的值就需要修改成slotdef的function，这个function就是一个桥接函数，其内部逻辑无外乎利用lookup_method或lookup_maybe从tp_dict中找函数。这个修改就是通过update_one_slot实现的。总而言之，cpython试图维护一种一致性，使得一个slot函数无论是从tp_dict访问还是直接访问字段都是同一段逻辑，且访问路径尽可能的短，从而使效率尽可能高。

经过add_operators与inherit_slots函数（PyType_Ready()里必经的两步），可以断言所有的内建类型若有定义一个字段的值，则必有对应的PyWrapperDescrObject函数（除了slotdefs废弃的字段）。若继承了一个字段的值，则循着__mro__必然能找到一个对应的函数（cpython的内建类型定义保证了不会继承一个废弃字段，避免了没有fixup阶段从而出现不一致情况）。

至此，内建类型避免了不一致，自定义类型利用update_one_slot维护了一致性，最终所有的cpython新式类都满足这种slot函数访问的一致性。


## 四、几个处理slot的函数的大致逻辑
在处理update_one_slot函数之前，为了方便理解上下文，需要先弄清如下的函数特点。
* add_operators()函数为类型结构体添加slot对于的函数到dict中。添加的前提
  * 该结构体有定义该字段且不为NULL
  * slotdef的wrapper不为空
  * slotdefs中同名的函数后面的会被跳过
* inherit_slots函数从bases中继承slot，继承的条件是：
 * 当前类型有定义该字段，但是为空

* slotptr函数只是根据偏移返回一个指针，并不检测是否有定义该字段或者该字段内容是否为NULL

* PyType_Lookup()函数根据mro的顺序依次从其字典中查找对应名字的条目，由于mro的第一项是当前类，因此查找的东西未必是祖先类的。

* 对于自定义类型，type_new函数中，在PyType_Ready()函数之前，并无任何继承slots的逻辑，而PyType_Ready()中，先执行
add_operators()，然后是inherit_slots()。由于自定义类的结构体是直接从内存分配的，这意味着几乎所有的字段都是NULL，
因此add_operators()几乎不会添加任何slot函数到dict中。

* reslove_slotdups()函数当前仅当类型中只有一个符合对应名字的字段被定义且不为空的时候返回该字段指针，否则存在多个或者未定义或者定义但为空都返回NULL。
比如类型中__str__对应的字段有两个tp_print与tp_str，但是只有tp_str的字段不为空，则返回tp_str的地址。

## 五、update_one_slot的一致性维护
对于自定义类型，在PyType_Ready()之后，会调用fixup_slot_dispatchers()函数，该函数最终会嗲用update_one_slot。

所有类型在更新属性、设置基类时也会最终调用到update_one_slot。
前面提到，update_one_slot会维护slot函数的一致性，那么update_one_slot函数是如何维护这种一致性的呢？

首先讲update_one_slot函数的可读性真的是差的极致，但是有一种比较简单的解读方法：
我们注意到函数最后的仅仅是给ptr指针赋值，而仅仅有一种情况下ptr会被赋值成specific。
我们称这种情况为规整情况，该情况满足如下条件：
1.当前类型继承了字段的值，且当前类型并未覆盖该字段对应的任何一个函数。
2.该字段的对应的所有函数都是来自祖先类的slot函数。
3.这些slot函数的d_base->wrapper字段与slotdefs中的wrapper一一对应，且其wrapped字段都一样，也就是说这些slot函数的真正实现逻辑是同一个函数。这个函数就是specfic。

除了这种规整情况，其余情况下都是使用p->functions。

其实，不管是不是规整情况，其字段都可以设置成P->function，毕竟p->function是个桥接方法，其从__mro__中一定能找到正确的函数，但是函数访问路径变长了必然效率低下。

## 六、几个例子
下面以继承list的一个类型为例，探究update_one_slot的逻辑。我们分别考察几个slot方法是如何继承、修正以及内外部一致的进行访问的。
```
class ulist(list):
  pass
```

**`__str__` 废弃tp_print后，相当于一对一的情况**

list定义类tp_print 但没有tp_str。

list的add_operator函数阶段跳过了tp_print，因为slotdefs中为NULL。

list继承了tp_str，但是tp_print字段仍然在。

此时list的__str__函数来自object对应tp_str字段,tp_print没有对应的函数。

ulist继承了两个字段。

fixup阶段 slotdefs开头NULL定义了清空了ulist的tp_print字段。

此时ulist的tp_str字段对应的函数组与对应的wrapper一致，将tp_str字段设置为wrapped函数。

**`__len__` 相当于一对多的情况 一个函数对应多个字段**

list的tp_as_sequence和tp_as_mapping分别定义了__len__函数对应的sq_length和mp_length 不过填充的是同一个函数list_length。

add_operators函数根据slotdefs的顺序包装字段，mp_length在sq_length之前，后者被跳过，base为mp_length对应的slotdef条目。

ulsit函数继承了tp_as_sequence与tp_as_mapping字段。

fixup的时候由于mp_length与sq_length的wrapper都一样，虽然只有一个继承自list的__len__函数，但是都满足字段对应函数组一致这种情况，分别设置为wrapped函数，但因为warpped都是一样的函数list_length，因而ulist的mp_length与sq_length都是list_length字段。

**`__lt__` 相当于多对一的情况 多个函数对应一个字段**

list定义了tp_richcompare字段为list_richcompare。

add_operators阶段添加__lt__函数。

ulist的tp_richcompare函数集成自list_richcompare。

fixup阶段发现tp_richcompare字段对应函数组为规整情况，设置为list_richcompare字段。

**`__setitem__` 相当于多对多的情况**

list定义了set_item的对应的sq_ass_item与mp_ass_subscript字段，值分别为list_ass_item与list_ass_subscript。

add_operator阶段跳过sq_ass_item字段对应的函数__setitem__与__delitem__。

ulist继承了两个字段。

fixup阶段发现mp_ass_subscript字段满足规整条件，设置为list_ass_subscript条件。

而sq_ass_subscript字段由于wrapper不一样，而被设置为p->functions

**自定义方法覆盖后**
对于函数与字段一对一 一对多的情况 直接查到的函数就不是WrapperDescrObject，因而走p->function。对于函数与字段多对一、多对多的情况 因为破坏了函数组，因而走p->function。

## 附：update_one_slot注释
```
static slotdef *
update_one_slot(PyTypeObject *type, slotdef *p)
{
    PyObject *descr;
    PyWrapperDescrObject *d;
    void *generic = NULL, *specific = NULL;
    int use_generic = 0;
    int offset = p->offset;
    void **ptr = slotptr(type, offset);
    //若ptr为空说明该类型没有定义该字段，跳过
    //但此时其实并未检查该字段的值，值可以为空，如ulist例子的__cmp__字段
    if (ptr == NULL) {
        do {
            ++p;
        } while (p->offset == offset);
        return p;
    }
    do {
        //循__mro__从tp_dict中找到同名函数
        descr = _PyType_Lookup(type, p->name_strobj);
        //该字段不存在函数，也就无所谓访问一致性，若该字段就对应这一个函数名，那最后*ptr=generic，也就是NULL
        //若对应多个函数名，自然依照另个函数名的情况设置ptr的值
        if (descr == NULL) {
            if (ptr == (void**)&type->tp_iternext) {
                specific = _PyObject_NextNotImplemented;
            }
            continue;
        }
        //descr为slot函数的情况。注意，update_one_slot有多个调用路径，若是从fixup_slot_dispatchers来，那么fixup_slot_dispatchers
        //函数只会发生在自定义类型初始化的时候，而自定义类型的所有slotdefs射击的字段都是空的，也就是add_operators阶段不会添加任何slot函数。
        //也就是说自定义类型初始化的情况下，这里的descr必然来自祖先类。
        if (Py_TYPE(descr) == &PyWrapperDescr_Type &&
            ((PyWrapperDescrObject *)descr)->d_base->name_strobj == p->name_strobj) {
            //查找同名函数，若有多个已定义的值或是没有该字段则返回NULL，只有有唯一一个定义了值的字段，则返回字段指针
            //有趣的是有唯一一个并不代表者,tptr一定等于ptr。考虑ulist中的__getattribute__函数，若当前p为(__getattribute__,tp_getattr)对应的slotdef
            //那么根据名字找到的tptr实际上是(__getattribute__,tp_getattro__)对应的slotdef，因为只有tp_getattro__才不为NULL.
            void **tptr = resolve_slotdups(type, p->name_strobj);
            //注意下面的判断：有唯一一个定义了值，且相等的或者没有定义，或者定义了多个值的情况都是使用p->functions。
            //否则generic保持NULL，slotdef废弃字段的作用就是用的这里的逻辑。
            if (tptr == NULL || tptr == ptr)
                generic = p->function;
            d = (PyWrapperDescrObject *)descr;

            //判断是否规整情况，这里的PyType_IsSubType仅仅在非fixup_slot_dispatchers调用路径下生效。
            if (d->d_base->wrapper == p->wrapper &&
                PyType_IsSubtype(type, d->d_type))
            {
                if (specific == NULL ||
                    specific == d->d_wrapped)
                    specific = d->d_wrapped;
                else
                    use_generic = 1;
            }
        }
        else if (Py_TYPE(descr) == &PyCFunction_Type &&
                 PyCFunction_GET_FUNCTION(descr) ==
                 (PyCFunction)tp_new_wrapper &&
                 ptr == (void**)&type->tp_new)
        {
            /* The __new__ wrapper is not a wrapper descriptor,
               so must be special-cased differently.
               If we don't do this, creating an instance will
               always use slot_tp_new which will look up
               __new__ in the MRO which will call tp_new_wrapper
               which will look through the base classes looking
               for a static base and call its tp_new (usually
               PyType_GenericNew), after performing various
               sanity checks and constructing a new argument
               list.  Cut all that nonsense short -- this speeds
               up instance creation tremendously. */
            //注意上面的逻辑，ptr==(void**)&type->tp_new已经判断ptr为type->tp_new了，那
            //下面的赋值仅仅是为了保证specific不为NULL,因为函数最后会给ptr赋值
            specific = (void *)type->tp_new;
            /* XXX I'm not 100% sure that there isn't a hole
               in this reasoning that requires additional
               sanity checks.  I'll buy the first person to
               point out a bug in this reasoning a beer. */
        }
        else if (descr == Py_None &&
                 ptr == (void**)&type->tp_hash) {
            /* We specifically allow __hash__ to be set to None
               to prevent inheritance of the default
               implementation from object.__hash__ */
            specific = PyObject_HashNotImplemented;
        }
        else {
           //自定义函数也即是PyFunctionObject覆盖的情况
            use_generic = 1;
            generic = p->function;
        }
    } while ((++p)->offset == offset);
    if (specific && !use_generic)
        *ptr = specific;
    else
        *ptr = generic;
    return p;
}
```


[0]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L6037
