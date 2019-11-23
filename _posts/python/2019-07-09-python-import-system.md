---
layout: post
title: python导入系统
description: ""
category: python
tags: [python,cpython, import]
---
{% include JB/setup %}

* toc
{:toc}

### 导入系统演变历史大略

#### python1.5内建了对package的支持
从1.5开始，python内建了对package的[支持][0],或者说是基于文件系统的package系统，因为它要求文件夹下有`__init__.py`文件。从如今的cpython的代码来看，
所谓package实现原理与module一样。package要求文件夹内必须包含一个__init__.py，其实就是
package这个“模块”的源码文件（一个文件对应一个模块）。这一点也可以从python中验证，比如如下
的文件结构：
```
mod1.py
pkg/
   __init__.py
   mod2.py
```
在mod1.py所在目录打开交互式python窗口中分别加载module与package，可以看出其类型都是module，但是个别字段的值不一样，
这些字段的作用稍后会讲。
![img](/assets/resources/python_import_system_0.png)

在package系统下，模块导入有两种语法，带from的与不带from的。

<pre class="brush:python;">   

import pkg
import mod1,mod2
import pkg.mod1 
from pkg import mod1
from mod1 import foo, name
from pkg.mod1 import foo

# from import 语法前面不能有逗号，后面不能有点号
# 这是唯一的语法。下面两种错误的写法
# from pkg1,pkg2 import mod1,mod2
# from pkg1 import pkg2.mod2

</pre>

上面的`import pkg.mod1`不同于java中的语法，该语句会将`pkg,pkg.mod1`都加载到`sys.modules`中，但**只会将`pkg`这个名字引入到当前名字空间中。**

python标准文档里语言规范部分[import词条][1]详细解释了import的工作方法，表述如下：
1. 找到指定模块，若有必要初始化它。
2. 在执行import语句的名字空间定义导入的名字们。

那么对于`import mod1,mod2`里的两个模块，导入过程是对每个模块，重复上面的两个步骤。而对于`from mod1 import foo, name`这种形式则是找到模块然后重复执行步骤2，因为from后面只能有一个模块名字。

上面两个步骤中第一步是找到模块，至于如何找到模块后面会结合pep302 New Import Hook一并说明。

这里需要说明的是一种会覆盖系统模块的行为，这种行为的根本原因是原来的import语法没有给出一种访问同目录下其他模块的合适的方法，
它采用的语法是`import xxx`形式，然而这与访问顶层模块的语法形同，因此当自定义的模块名字与系统模块重合的时候，比如`import string`，
则cpython会先从当前目录下搜索模块，从而掩盖掉了系统模块，此时，没有干净简洁的方法引用同名系统模块。

这种覆盖系统模块的根本原因是语法冲突,`import xxx`有两种语法含义，因此解决之道就是给同目录下访问提供一种合适的语法。
#### python2.3实现了Pep302关于import hook的内容
#### python2.5引入了相对导入与绝对导入的概念
鉴于上面提到的覆盖系统模块的问题，[python2.5完整实现了pep328的内容][2]，引入了绝对导入与相对导入的概念。
所谓相对导入指的是相对于导入语句所在的module，语法与浏览Unix/linux文件系统的方法类似，需要注意的是**隐式相对导入所在额块本身必须处于package系统中**。所谓处于package系统指的是处于一层层的package构成树状结构里面。
所谓绝对导入就是指定模块的从`sys.path`开始的完整路径。

<pre class="brush:python;">
# .代表当前文件所在目录 ..代表上一层目录 
# .pkg ..pkg用于定位指定目录下的pkg
# （对应linux文件系统下的./pkg ../pkg的意思）
from . import string
from .pkg import string
from .. import string
from ..pkg import time

</pre>

根据新的规范，原来的`import xxx`访问了当前目录下模块的行为被称为隐式相对导入，而.符号相对导入称为显式相对导入。虽然2.5之后3.0之前仍然默许隐式相对导入行为，但是
可以通过`from __future__ import absolute_import`来关闭隐式相对导入，从而保证`import xxx`有唯一的语法含义。

#### python2.7支持main模块内的相对导入
此处的main模块是指通过-m选项运行的main模块，此时main模块在包系统之内。若直接运行包含相对导入的模块，则python不会认为模块处于包系统之内，即便
文件夹下有`__init__.py`也不行。

具体技术细节参见[pep366][11]，简单概括就是新增加`__package__`属性用于维系包系统层级。

至于-m选项的工作原理参考[pep338][12]，大致可以理解为当使用-m选项时候，[pep302][13]描述的导入机制用来定位加载模块，然后将该模块作为顶层模块来执行。
且使用-m选项的时候会将整个包系统的顶层目录加入`sys.path`，将脚本的绝对路径作为`sys.argv[1]`。而直接运行包内模块，只会将模块所在目录加入搜索路径，同时`python xxx.py`这种直接运行方式只会将`xxx.py`传个`sys.argv[1]`，也就是你写的是什么就传什么。

#### python2.7实现了importlib.import_module()
python3.1引入的模块importlib，用python语言重新实现了`import`相关逻辑。2.7并未全部引入，只实现了import_module()函数。

#### python3.0开始相对导入必须遵循新语法
#### python3.1引入importlib模块用于自定义模块加载过程

### new import hook
在pep302之前，想要自定义模块加载过程就需要覆盖`__import__`方法，但是`__import__`本质是个C函数，很难做细分定制。
[pep302][13]一种开放式的模块加载方法，在这种新体系下，基于文件系统的模块加载方式只是其中一种finder而已。

python中模块的导入可以分成三部
1. 找到模块
2. 加载模块
3. 绑定名字

所谓import hook机制就是允许自由的定制前两部过程。pep302使用"导入协议"来描述这两个过程。导入协议涉及两个callable对象`finder`与`loader`。
所谓finder是任何一个实现了`find_module()`的类，所谓loader是任何一个实现了`load_module()`的类。而两个方法都实现的类称为`importer`。
其中loader是由finder返回的，自定义加载过程可以只实现finder，但是不能只实现loader。

<pre class="brush:python;">
class Importer(object):
	@classmethod
	def find_module(fullname,path=None):
		raise ImportError()

	@classmethod
	def load_module(fullname):
		return None
</pre>

find_module的两个参数:fullname是模块的全限定名，path是import语句所在的模块的path。用于限定import hook生效的范围。注意这两个参数是cpython传给你的。关于第二个参数的作用可能感觉很疑惑。下面讲cpython中import的实现的时候便一目了然了。

imp模块是python的内建模块，本质上是`import.c`的对外封装。其内部的逻辑实现了pep302的内容。

load_module的加载的模块必须现在sys.modules中然后再执行模块代码，这是为了防止执行模块代码的时候在此导入该模块从而造成递归或多次导入。

load_module加载的模块必须设置好`__name__,__file__,__path__,__loader__`属性，因为cpython的工作逻辑依赖于这几个属性。简言之,`__name__`用于确定当前模块是否`__main__`。`__file__`用于确定该模块是否内建模块，只有内建模块才没有该属性。`__path__`属性用于确定该模块是否一个package。
`__package__`属性用于维系包层次。

关于package的支持:尽管importer协议不关系package如何存储，但最好package与path直接存在明确的对应关系。因为sys.path_hooks里面的importer会使用导入语句的package的path作为参数，也就是会使用这个参数与fullname一起来确定importer。当然你也可以完全抛弃path，只是用全限定名来确认是否是要处理的目标模块。

### import的搜索顺序
import的时候首先检查sys.modules
其次将fullname扔给sys.meta_path里面的importer一一检查。
其次扔给sys.path_hooks里面的importer一一检查，当然这里有sys.path_importer_cache。
具体参见[官方文档import语句][1]

### cpython中import的实现-版本2.7为例
我们首先来看一下import语句编译之后变成了什么：

<pre class="brush:python;">
import dis
co = compile("import A.B; from ..A.B import C","demo","exec")
dis.dis(co)
</pre>

编译结果：
```
             0 LOAD_CONST               0 (-1)
              3 LOAD_CONST               1 (None)
              6 IMPORT_NAME              0 (A.B)
              9 STORE_NAME               1 (A)
             12 LOAD_CONST               2 (2)
             15 LOAD_CONST               3 (('C',))
             18 IMPORT_NAME              0 (A.B)
             21 IMPORT_FROM              2 (C)
             24 STORE_NAME               2 (C)
             27 POP_TOP
             28 LOAD_CONST               1 (None)
             31 RETURN_VALUE
```

可以看到相关的指令有三条`IMPORT_NAME,IMPORT_FROM,IMPORT_NAME`。查看`ceval.c`中的源码可知，`IMPORT_FROM`仅仅是读取模块的属性（这里是"C"）。
而`STORE_NAME`则是将名字放到当前local名字空间中（关于什么是local名字空间另有文章去讲）。
稍微复杂点的是`IMPORT_NAME`指令，其调用的是内建函数`__import__`。关于这个函数，文档有[详细说明][4]。
查看`__import__`函数文档说明可以发现，该函数需要5个参数。然后`import`语句就算是`from xx import xx`语句好了，最多是两个参数，那么这5个参数是怎么来的呢?

原来python代码经过编译，import语句被处理分解了。globals与locals代表执行import语句所在的frame的环境。至于`fromlist`不要被名字所误导，指的是`from ..A.B import C,D`中后半部分也就是`C,D`。至于`level`若是正数指的的是`from`语句中`.`的数目，若是0指的是绝对导入，若是-1则先执行相对导入再执行相对导入，也就是`import xxx`发生隐式相对导入的情况。cpython中会先根据globals与level确定出`A.B`。然后依次加载A，然后以A为父目录加载B，依次类推。加载完毕后会通过ensure_fromlist()函数将fromlist中的模块也加载进来。注意到目前为止所有的都是指的是加载，而不是名字绑定。

整个导入过程的伪码如下：

<pre class="brush:python;">

#结合level与global找到待搜索模块的父目录
#父目录的名字返回在buf中
def get_parent(globals, buf, level):
	#顶层包之外或是非包目录中发生相对导入的错误也是这里判定的
	pass
#从parent中加载name中的第一层，并返回它
#比如说name是C.D buf是A.B
#那么返回后name变成D，buf变成A.B.C
#并返回C模块
#altmod或者与parent相同，或者为None
#当parent为None的时候，无论level为多少altmod都是None,执行绝对导入
#当parent不为None且level为-1，则若parent下找不到（相对导入找不到）则执行绝对导入
#当parent不为None且level==0的时候不存在，此时parent一定为None。
#当parent不为None且level>0的时候，仅执行相对导入。

#对于import xxx语句，from __future__ import absolute_import之后level编译为0 。引入之前编译为-1。
#而当level=0的时候，get_parent里有一个!level的条件判断一定为返回None。
#于是就可以很清晰的看到为什么absolute_import会关掉隐式相对导入。

def load_next(parent, altmod, name, buf):
	p = get_first_left_part_by_dot(name)
	name = delete(name,p)
	buf = concat(buf,p)
	module = import_submodule(mod, p, buf)
	if(module==None且altmod!=mod){
		module = import_submodule(altmod, p, p)
	}
	return module

def import_submodule(mod, subname, fullname):
	if sys.modules.contain(fullname):
		return sys.modules[fullname]
	if mod == None:
		path = Null
	else
		path = mod.__path__ #mod是parent，一定是一个package，因此一定有path属性

	buf = ""
	loader = NOne
	file = find_module(fullname, subname, path, buf, loader)


	module = load_module(fullname, file, buf, loadder)

	add_module_to_sys_modules()
	return module

# name是import xxx中的xxx from ...xxx import yyyy中的xxx
# fromlist是yyyy level是...xxx中的.的数量
# globals与locals是import语句调用时的frame
def import_module_level(name,globals,locals,fromlist,level):
	buf = "" #buf用来存储当前待搜索的模块所在的包（文件系统中所在的文件夹）

	parent = get_parent(globals, buf, level}
	head = load_next(parent, level < 0 ? Py_None : parent, name, buf)
	tail = head
	while(name){
		head = load_next(parent, level < 0 ? Py_None : parent, name, buf)
    }

</pre>


### importlib imp 等模块的关系

imp模块是`import.c`的简单封装，importlib是3.1引入的python实现的`import.c`逻辑。
其他可以参考[官方文档][5]
### PyModuleType的`__name__、__file__、__path__、__package__`属性
这块于2.7的文档并没有找到专门统一将这些属性的官方文档，但是在3.0以上的官方文档中专门有一节讲述导入系统，且专门讲了[这几个属性][10]。
* `__name__`属性**一定**会被设置为package或module的全限定名
* `__file__`属性**一定**会被设置为对应源文件地址,package为`__init__.py`的地址
* `__path__`属性 package必须设置但可以为空,非package的模块则没有这个属性
* `__package__`属性 [pep366][11]引入，必须由loader设置但可以为空，等到相对导入语句出现的时候再计算。

其中原来`__name__`属性是用来维系package系统的层级关系的，但[Pep366][11]提出-m下package系统内的被当成main module的模块内相对导入的问题，
此时，main module虽然处于package系统内，但是其`__name__`属性被设置为`__main__`，无法用于package系统的索引，因此新增`__package__`属性。
pep366解决的问题如图:
![img](/assets/resources/pep366_0.png)

[0]:https://www.python.org/doc/essays/packages/
[1]:https://docs.python.org/2/reference/simple_stmts.html#the-import-statement
[2]:https://docs.python.org/2/whatsnew/2.5.html#pep-328-absolute-and-relative-imports
[3]:https://docs.python.org/2/library/sys.html#sys.path
[4]:https://docs.python.org/2/library/functions.html?highlight=__import__#__import__
[5]:https://docs.python.org/2/library/modules.html
[10]:https://docs.python.org/3/reference/import.html?highlight=__package__#import-related-module-attributes
[11]:https://www.python.org/dev/peps/pep-0366/
[12]:https://www.python.org/dev/peps/pep-0338/
[13]:https://www.python.org/dev/peps/pep-0302/