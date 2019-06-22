Python中一切皆对象。
最基础的对象就是PyObject
```
#define PyObject_HEAD                   \
    _PyObject_HEAD_EXTRA                \
    Py_ssize_t ob_refcnt;               \
    struct _typeobject *ob_type;

typedef struct _object {
    PyObject_HEAD
} PyObject;
```

然而这个PyObject并不是python中最基础的那个object，那个object是PyBaseObject_Type，是的，
在CPython层面是一个Type。
也就是说CPython层面，最基础的两个结构体是PyObject与PyTypeObject。而python语言层面最基础的type与
object只是PyTypeObject的两个实例。

而每一个PyObject都包含有一个指向其类型的指针 ob_type。ob_type本身类型是PyTypeObject。
PyTypeObject与PyObject拥有相同的结构体头部：PyObject_HEAD。（这里是c语言中常见的结构体嵌套共用地址那套把戏）

从PyObject_HEAD的定义可以看出，PyTypeObject包含了对自身的引用。

而其他的object与类型分别是PyObject的扩展类型与PyTypeObject的实例。

比如PyFunctionObject的结构体定义头部是PyObject,这相当于类的继承。
而PyFunction_Type是PyTypeObject的实例。
