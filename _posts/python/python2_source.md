从PyTypeObject看起
object.h中定义了PyTypeObject的结构体

当Python需要一种新类型的时候，注意一个类型也是一个对象
初始化这个结构体就可以了。
比如在stringobject.c中初始化该结构体因而定义了StringType

需要注意的是这些方法
```
struct PyMethodDef *tp_methods;
struct PyMemberDef *tp_members;
struct PyGetSetDef *tp_getset;
struct _typeobject *tp_base;
PyObject *tp_dict;
descrgetfunc tp_descr_get;
descrsetfunc tp_descr_set;

initproc tp_init;
newfunc tp_new;

```
tp_methods定了该类型的方法
而tp_members与tp_getset定了该类型的属性。其间区别可以参考
https://llllllllll.github.io/c-extension-tutorial/member-vs-getset.html
http://www.xefan.com/archives/84093.html

tp_descr_get与tp_descr_set则是描述符协议，问题是del去哪里了

而tp_init与tp_new则定了该类型的实例化的方法，注意这些方法不在method之中。

当python程序初始化的时候，会调用PyType_Ready()去真正初始化各个类型，前面的初始化结构体仅仅
是准备好材料。详见object.c中_Py_ReadyTypes()函数。

--------------------
method_descriptor    ---->方法
wrapper_descriptor   ---->操作符
    slot_wrapper
    method_wrapper
--------------------

PyType_Ready()初始化methods的时候便会创建一个个的method_descriptor方法，参加add_methods

初始化operator的时候便会创建一个个wrapper_descriptor。

执行`list.append`会告诉你<method ‘append’ of list objects>
其来源是
method_repr() -> PyMethodDescr_Type与PyClassMethodDescr_Type
->PyDescr_NewMethod() -> add_methods()


执行`list.__add__` 会告诉你<slot wrapper '__add__' of 'list' objects>
其来源是
wrapperdescr_repr() -> PyWrapperDescr_Type的tp_repr字段 -> PyDescr_NewWrapper() -> add_operators()

执行`object.__eq__`会告诉你<method-wrapper '__eq__' of type object at 0x7fffa61ae310>
其来源是
wrapper_repr() -> static PyTypeObject wrappertype -> PyWrapper_New() ->
wrapperdescr_get()与wrapperdescr_call() -> PyTypeObject PyWrapperDescr_Type的tp_descr_get字段
->PyDescr_NewWrapper() ->add_operators()

----------------------
原始类型type的初始化
PyType_Type
typeobject.c中slotdefs变量定义了所有的操作符操作。

原始对象object的创建
PyBaseObject_Type

原始对象super的创建
PySuper_Type



python对象与内建对象 如何属性查找

python函数与内建函数 如何执行
ceval.c中的call_function() 语法树解析的第一个入口

其实python函数在解释器执行的时候也会被包装成c语言下的对象PyFunction
