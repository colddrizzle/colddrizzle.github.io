build_class函数

与PyClass_Type中的class_new的关系


当解释器遇到class关键字定义的class之后，build_class()函数开始执行。
build_class主要是寻找一个合适的metaclass，如果类定义中没有指定metaclass的话，一般是
类定义中所有基类中的第一个。
然后将解析类定义所得的所有参数传给这个metaclass，也就是执行它。而我们知道，这个metaclass必然
是已经被解析类定义的时候解析成了一个PyObject，而执行一个PyObject，也就是调用PyObject_Call
相当于调用PyObject->tp_type->tp_call.

假设有如下的类继承关系:
object <- ClassA <- ClassB <- ClassC

当build_class构建ClassC的时候，相当于执行ClassB(args***)，
```
result = PyObject_CallFunctionObjArgs(ClassB, name, bases, methods,
                                      NULL);
```
而执行ClassB，别忘了ClassB也是一个PyObject，执行相当于type(ClassB)->tp_call。而Class的B的type就是type。

```
   type->tp_call(ClassB, name, bases, methods )

```
