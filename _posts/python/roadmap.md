
虚拟机执行框架


测试\Mock


bottle web 框架

metaclass  https://blog.csdn.net/wwx890208/article/details/80644400

context manager types:https://docs.python.org/2.7/reference/datamodel.html#with-statement-context-managers


fastfunction

dictproxy


python内建模块
python除了有__builtin__中的内建函数外，很多模块都是内建模块，
`PC/config.c`中列出了这些内建模块，注意这些内建模块并不在python初始化的时候加载，而是用到的时候再去加载到当前名字空间。


500lines 那些小项目

各种文件操作库之间的关系：https://blog.csdn.net/haijiege/article/details/79849019
bottle中这行代码为什么会出错
root ='img' os.getcwd()= "F:\\web" ，结果root变为根目录"F:\\"
root = os.path.join(os.path.abspath(root), os.sep)



了解下gevent greenlet协程库

python版本管理：
pyenv与virtualenv的区别：前者管理python版本，后者创建某个python版本的虚拟干净运行空间
https://www.liaoxuefeng.com/wiki/1016959663602400/1019273143120480

https://blog.csdn.net/qq_40124617/article/details/87367873


python怪癖：
property无法继承
https://www.jianshu.com/p/ebf0e4a311c1

不定义__init__反而能默认调用父类__init__
定义了就需要手动调用
https://www.cnblogs.com/homle/p/8724125.html

http://www.voidcn.com/article/p-pksltuzw-bwo.html


python中int为什么不溢出：
https://www.cnblogs.com/ChangAn223/p/11495690.html


为什么python不需要接口？
https://www.cnblogs.com/feichengwulai/articles/3632490.html


python正则表达式：
https://www.runoob.com/python/python-reg-expressions.html

python open模式区别:
https://www.cnblogs.com/dadong616/p/6824859.html


python二维转一维的技巧：
https://blog.csdn.net/qq_44205272/article/details/105073273


python泛型？
首先，python不是弱类型语言吗？什么时候也需要泛型了
https://blog.csdn.net/weixin_36338224/article/details/109014854


一种观点：不要再使用lambda表达式：https://blog.csdn.net/sinat_38682860/article/details/83933866


