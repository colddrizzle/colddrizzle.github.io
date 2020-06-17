---
layout: post
title: cpython属性查找
description: ""
category: python
tags: [python,cpython]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 什么是属性查找

所谓属性查找就是点操作符的效果。

与方括号，圆括号操作的区别如下：

点操作符a.b 相当于`type(a).__getattribute__(a, b)`
<pre class="brush:python;">
class CLS(object):
	a = 1

c = CLS()
print c.a
print CLS.__getattribute__(c,'a')

</pre>

方括号操作符a[b]相当于 `type(a).__getitem__(a, b)`
<pre class="brush:python;">
lst = [1, 2, 3]
print lst[2]
print list.__getitem__(lst, 2)
</pre>


元括号操作符a(b)相当于 `type(a).__call__(a, b)`
<pre class="brush:python;">
def foo(x):
	return x*2

print foo(2)
print type(foo).__call__(foo,2)
</pre>

## 属性查找的入口

在探究这个问题之前，让我们先看看在新式类的普通对象中进行属性查找发生了什么，我们用下面的代码做例子：

<pre class="brush:python;">
class CLS(object):
    pass	

obj = CLS()
obj.a    
</pre>
显然上述结果是找不到a属性。但是查找过程是怎么样的呢？我们把上面代码编译成字节码

<pre class="brush:python; highlight:[14,15];">
  3           0 LOAD_CONST               0 ('CLS')
              3 LOAD_NAME                0 (object)
              6 BUILD_TUPLE              1
              9 LOAD_CONST               1 (<code object CLS at 0000000002127430, file "demo.py", line 3>)
             12 MAKE_FUNCTION            0
             15 CALL_FUNCTION            0
             18 BUILD_CLASS
             19 STORE_NAME               1 (CLS)

 13          22 LOAD_NAME                1 (CLS)
             25 CALL_FUNCTION            0
             28 STORE_NAME               2 (obj)

 15          31 LOAD_NAME                2 (obj)
             34 LOAD_ATTR                3 (a)
             37 PRINT_ITEM
             38 PRINT_NEWLINE
             39 LOAD_CONST               2 (None)
             42 RETURN_VALUE
None
</pre>

注意高亮的14、15行，其意思是以obj与a为参数执行LOAD_ATTR指令。根据[源码][1]，LOAD_ATTR指令执行调用[PyObject_GetAttr()][2]函数，
该函数主要执行逻辑如下:
<pre class="brush:c;">
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

根据update_one_slot函数，tp_getattr是一个废弃字段。访问属性`a.b`等价于调用`TYPE(a)->tp_getattro(a, b)`。

<pre>
注意，在未覆盖__getattribute__与__getattr__的情况下:
	a.b 等价于 TYPE(a)->tp_getattro(a, b) 
        等价于 a.__getattribute__(b) 但又不一样。
            因为a.__getattribute__(b)翻译成字节码相当于
            attr_func = TYPE(a)->tp_getattro(a,'__getattribute__'); 
            attr_func(b)

或者说TYPE(a)->tp_getattro(a, b)一定是调用的TYPE(a)自己的方法，哪怕是个桥接方法。
而a.__getattribute__(b)中的__getattribute__方法却不一定是a自己的方法。

</pre>

所以问题是tp_getattro是什么样的函数？根据cpython中[slotdefs的定义][6]我们知道，tp_getattro永远与该字段所在类型的python层面的
`__getattribute__`与`__getattr__`方法关联。这种关联是写死的，我们知道python层面的对象方法其属性查找链上找到，因此不一定在对象本身的字典中。
在[cpython slots][7]中我们知道add_operators()函数会将`__getattribute__`与`__getattr__`方法添加到类型字典中。
因此这种关联的意义是：python层面调用`__getattribute__`与`__getattr__`方法，一定会找到tp_getattro字段，默认情况下tp_getattro字段对应的c函数
是slot_tp_getattr_hook，这是一个桥接函数，下面会将，从这个桥接函数中可以看出，一个调用`a.__getattribute__(b)`大致会先从类型及其父类型的继承链中确认`__getattribute__`合适的实现，再用这个实现去查找属性b。打个比喻的话，就是先确定车，在用这车顺着轨道（两个继承链）查找属性b。

我们还可以注意到，车总是类型创建者的车，a.b总是用TYPE(a)的`tp_getattro`字段指向的c函数作为车。[cpython slots][7]这篇文章详细讲了“车”的维护。

根据类创建那篇文章，根据`update_one_slot`方法的逻辑，只有一种情况会继承slot字段，也就是所谓的"规整情况"。显然，未定义`__getattr__`与`__getattribute__`时，这两个函数所对应的字段都是tp_getattro的默认值，也就是继承来的值。 元类型会继承自根type的`type_getattro`， 次生类型会继承自根object的`PyObject_GenericGetAttr`。因此对于任意的`a.b`，若a为类型对象（元类型与次生类型都可以），则相当于调用
`type_getattro(a, b)`。若a为非类型对象，则相当于调用`PyObject_GenericGetAttr(a, b)`。

若是定义了`__getattr__`与`__getattribute__`中至少一个之后，tp_getattro字段仍然要保持指向这两个方法的约束，但是一个字段如何同时指向两个不同的方法呢？答案就是桥接函数[slot_tp_getattr_hook][5]。这个函数可以简化成如下的伪代码:

<pre class="brush:c;">
slot_tp_getattr_hook(self, name){
	type = TYPE(self);

	res = NULL;

	getattr = lookup_in_mro_dict(type, "__getattr__");

	if(getattr == NULL){
		//找到可以绑定到当前self的__getattribute__方法
		type->tp_getattro = lookup_in_mro_dict(type, "__getattribute__")

		return type->tp_getattro(self, name)
	}

	getattribute = lookup_in_mro_dict(type, "__getattribute__");

	if(getattribute == NULL || is_descr_wrapper_of(getattribute, PyObject_GenericGetAttr)){

		res = PyObject_GenericGetAttr(self, name);
	}else{
		//获得绑定到self的getattribute 方法
		descr_get = TYPE(getattribute)->tp_descr_get(getattribute, self);

		res = descr_get(name);
	}

	if (res == NULL|| res == Any_Exception){
		//获得绑定到self的getattr 方法
		descr_get =  TYPE(getattr)->tp_descr_get(getattr, self);

		res = descr_get(name);
	}

	return res;
}
</pre>

可以看到，当a.b执行的时候，需要使用`type(a)->tp_getattro`字段，而这个字段被替换成了从type(a)及其MRO查找的`__getattribute__`与`__getattr__`函数。


## `__`getattr`__`、`__`getattribute`__`与tp_getattro字段的关系

这三个都是定义在类型中的方法，目的是给该类型是实例使用。
无论何时，tp_getattro字段与这两个函数都保持一致性。

默认情况下，`__getattr__`函数在新式类中是未定义的。
`__getattribute__`与tp_getattro字段保持一致。当自定义了`__getattr__`与`__getattribute__`后，
tp_getattro字段就变成了一个包装`__getattr__`与`__getattribute__`访问的桥接方法。

注意：这时候在单独显示调用`__getattribute__`或者`__getattr__`方法得到的结果就与直接通过点操作符不一样了。如下面的例子：

<pre class="brush:python;">
class C(object):
	def __getattr__(self, item):
		if(item == 'a'):
			return 1

c = C()
print c.a
print c.__getattribute__(a) # Exception 

</pre>

因此，在新式类中，最佳实践是不要定义`__getattr__`方法。定义了`__getattribute__`之后，`__getattribute__`内部要再调用
`super(self).__getattribute__(self, name)`。

下面我们分情况讨论，记住，无论在哪儿定义这两个方法，都需要记住这两个是实例方法，是定义给该类型实例使用的。


### 在元类型中自定义`__getattr__`与`__getattribute__`

元类型创建次生类型，因此元类型中覆盖这些方法影响其创建的次生类型的属性查找。
<pre class="brush:python;">
class Meta(type):
	def __getattr__(self, name):
		if name == 'a':
			return 1
class Cls(object):
	__metaclass__ = Meta

print Cls.a
</pre>


### 在次生类型中自定义`__getattr__`与`__getattribute__`

影响继承该次生类型的其他次生类型。所有这些此生类型的子类若是找到这些定义的方法，便会使用之。

画一画继承的情况

### 在非类型对象中自定义`__getattr__`与`__getattribute__`

在非类型对象a中定义这两个方法，若是通过a.b来访问，则不会有任何影响。
因为属性访问会先从TYPE(a)以及其MRO中寻找属性访问方法。

## 默认的“车”
前面讲过，属性查找先确定查找该属性的车。以下就是类型对象以及普通对象默认的“车”，所谓默认就是
没有自定义`__getattr__`与`__getattribute__`函数。

### 元类型tp_getattro字段
根据[type_getattro()][3]源码，可以抽象出如下伪代码：

<pre class="brush:c;">
type_getattro(type, name){

	meta_get = NULL;

	metatype = TYPE(type);

	meta_attr = lookup_in_mro_dict(metatype, name);

	//如果从meta类型及其mro中找到且是数据描述符，直接返回
	//从而达到覆盖type及其mro中同名属性的目的
	if( meta_attr && is_datadescriptor(meta_attr)){
		meta_get = TYPE(meta_attr)->tp_descr_get;
		return meta_get(meta_attr, type, metatype);
	}

	attr = lookup_in_mro_dict(type, name);

	//从type及其mro中找到属性，则无条件返回
	if(attr){
		local_get = TYPE(attr)->tp_descr_get;
		if(local_get){
			return local_get(attr, NULL, type);
		}
		return attr;
	}

	//若果type及其mro找没有找到，则考虑type
	//的类型及其基类中的属性

	//是描述符先拆解描述符
	if(meta_get){
		return meta_get(meta_attr, type, metatype);
	}
	//不是描述符直接返回
	if(meta_attr){
		return meta_attr;
	}

	return no_such_attr_error;
}

</pre>
从上面代码可以看出，一般情况下type以及mro中的属性覆盖metatype及其mro中的属性，除非metatype中该属性是数据描述符。

### 次生类型tp_getattro字段
根据[PyObject_GenericGetAttr][4]源码，可以抽象出如下伪代码：

<pre class="brush:c;">
PyObject_GenericGetAttr(obj, name){
	_get = NULL:
	type = TYPE(obj);

	attr = lookup_in_mro_dict(type, name);

	//源码中Py_TPFLAGS_HAVE_CLASS的解释见
	//https://docs.python.org/2/c-api/typeobj.html#Py_TPFLAGS_HAVE_CLASS

	//obj及其mro中如果找到该属性且是数据描述符
	//则直接返回，从而覆盖obj自己字典中的同名属性
	if(attr){ 
		_get = attr->ob_type->tp_descr_get;
		if(_get && is_datadescriptor(attr)){
			return _get(attr, obj, name);
		}
	}

	//type及其mro中没有找到同名数据描述符的情况下
	//若obj字典中找到，无条件原样返回
	if(obj->dict){
		res = dict_getitem(obj->dict, name);

		if(res){
			return res;
		}
	}

	//obj中没找到，type及其mro中找到了且不是数据描述符
	//执行描述符协议
	if(_get){
		return _get(attr, obj, type)
	}

	//obj中没找到，type及其mro中找到了且不是描述符
	//原样返回
	if(attr){
		return attr;
	}

	return no_such_attr_error;
}

</pre>
从上面代码可以看出，一般情况下obj字典中的属性覆盖type及其mro中的属性，除非type中该属性是数据描述符。

## 属性查找与描述符协议

通过tp_getattro访问类型的属性时，触发描述符协议。

反例:

https://stackoverflow.com/questions/41921255/staticmethod-object-is-not-callable


## 属性查找的自启动

属性访问方法是实例方法，这意味着，若类型A定义了属性访问方法，则该方法是给自己的实例使用的。若不然，
就会陷入查找类型A的属性访问方法需要先找到类型A的属性访问方法这样一个悖论中。

该类型A本身的属性访问方法则由TYPE(A)以及MRO来定义，又会导致要求无穷多的更高一层的类型来定义属性访问方法。
但是，python的类型系统中，`type(type)=type`。也就是说，type类型自己定义了自己属性的查找方法。

也因此，`type.__getattribute__(type, "__getattribute__")`不会造成死循环。因为在cpython看来，其实是

```
getattribute_func = type(type)->type_getattr(type, '__getattribute__');

getattribute_func(type, "__getattribute__");

```


## 特殊方法的查找

这部分是[官方文档的说明](https://docs.python.org/2.7/reference/datamodel.html#special-method-lookup-for-new-style-classes)

对于老式类，特殊方法的隐式调用等同于下划线调用，且从调用对象字典开始查找，与普通方法或属性一样，也就是
```
special_method(o) 等价于o.__special_method__()

o.__special_method__()从o开始查找方法，无论o是什么对象

与

o.general_attribute 从o开始查找一样，无论o是什么对象

```

对于新式类对象来说，在类型对象上，特殊方法的隐式调用等价于从其类中找该方法并以该对象为参数调用。与普通方法一样。

```
special_method(o) 等价于 type(o).__special_method__(o)

与普通方法一样，也就是

o.general_attribute 等价于 type(o).__general_attribute__() 

```
而在普通对象上，特殊方法的隐式调用等价于从对象的类中找该方法并以该对象为参数调用。只是不再通过getattribute手段，而是在cpython层面直接调用对应的slots方法。

## 例子

python [doc](https://docs.python.org/2.7/reference/datamodel.html#customizing-attribute-access)
最下面那个例子的示意图如下：

![img](/assets/resources/cpython_attr_lookup_example.png)

属性查找链就像是路，而属性查找方法就像是车。a.b的属性查找就是先确定适合a的车，然后这车就根据自己的路线来查找。

## 关于属性查找的其他文章

https://www.cnblogs.com/xybaby/p/6270551.html


[0]:https://docs.python.org/2.7/reference/datamodel.html#customizing-attribute-accesss
[1]:https://github.com/python/cpython/blob/2.7/Python/ceval.c#L2555
[2]:https://github.com/python/cpython/blob/2.7/Objects/object.c#L1176
[3]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L2606
[4]:https://github.com/python/cpython/blob/2.7/Objects/object.c#L1463
[5]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L5652
[6]:https://github.com/python/cpython/blob/2.7/Objects/typeobject.c#L6054
[7]:/2019/08/13/cpython-slots