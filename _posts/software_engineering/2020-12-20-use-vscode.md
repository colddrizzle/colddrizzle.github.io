---
layout: post
title: vscode相关概念与使用经验

tagline: "Supporting tagline"
category : 软件工程
tags : [vs code]

---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 基本概念

### 界面与组件

可参考：https://zhuanlan.zhihu.com/p/140487447

注意，状态栏是根据当前打开的文件选择展示的信息的，比如python会有interpreter选项，但切到C文件还是由python解释器选项，
因此，状态栏会根据当前打开文件类型展示不同的信息与工具。


### 工作区

工作区类似于我们熟悉的IDE中的项目的概念，一个工作区可以包含多个文件夹，但vscode一个窗口只能打开一个工作区。
没有工作区创建的按钮，通常情况下把一个窗口打开多个文件夹算作一个工作区，但是只有进行保持到工作区之后才能再次以工作区的方式打开这些文件夹。

更多关于工作区可参考：https://www.cnblogs.com/mouseleo/p/12658924.html


### 命令面板

以下摘自：https://zhuanlan.zhihu.com/p/140487447

VS Code作为一个代码编辑器，它本身有两个比较极客的设计思想。一个是基于文本（命令）的交互界面，另一个是基于文本的系统设置。基于文本的交互界面就是这里提到的命令面板。

当你按下 `shift+command+p` 时，命令面板的输入框会自动出现一个 > 它意味着此时命令面板认为你想要搜索相关命令并执行。

![img](/assets/resources/vscode/cmd_plate.jpg){:width="100%"}

当删除 `>` 后会看到命令面板切换到了「访问最近文件」状态。如果你想在调用命令面板时直接访问最近文件，快捷键是 `command+p`。

![img](/assets/resources/vscode/recent_files.jpg){:width="100%"}

如果此时输入 ? 会触发命令面板的「帮助」功能，我们可以看到支持哪些操作。下图中显示的切换文件、>执行命令、@符号跳转等我们在后续的应用场景中都会提及。其他单词缩写也代表了对应的操作，例如edt接空格可以管理打开的编辑器，term接空格可以打开或管理终端。

![img](/assets/resources/vscode/cp_help.jpg){:width="100%"}


VScode对于其支持的每种语言，通过插件提供内建命令，通过`command+shift+p`调出来选择使用。

### 插件

命令是插件提供的，所以一定要安装插件。以下是一些语言必须安装的插件：

* c/cpp:ms-vscode.cpptools
* python:ms-python.python
* java:Language Support for Java(TM) by Red Hatredhat

### intelliSense

即所谓的智能提示，通过插件实现，上面提到的各语言插件就是各语言下智能提示的支持工具。

## intelliSense原理相关

GotoDefination是怎么实现的以及语言服务协议：

https://zhuanlan.zhihu.com/p/100438617

https://docs.microsoft.com/en-us/visualstudio/extensibility/language-server-protocol?view=vs-2019

理解了语言服务协议才能理解vscode中的一些插件是怎么工作的

## java
管理java项目
https://code.visualstudio.com/docs/java/java-project
当使用里面的添加文件夹作为源码为文件夹功能时，相关配置并未保存在当前工作区的workspace下面
而是保存在一个影子项目下：

![img](/assets/resources/vscode/java_project_config_save_location.png)

这个影子项目保存在Users/your-name/AppData下的某个子文件夹中，之所以这样貌似是因为这个java插件是基于
eclipse-jdt来开发的。

影子项目这种方式意味着你不能干净地在不同电脑之间拷贝vscode的java项目。


案例：在vscode中调试ant源码
	添加好源文件夹后，创建launch.json文件会自动把源文件夹下的所有的包含main方法的类作为Main_Class添加到launch.json中。
但是这样是不能直接跑的。因为vscode并不知道怎么编译ant



vscode windows平台下编译使用coderunner运行java

因为java会根据当前的系统设置选择以GBK编码来输出编译信息，当编译错误的时候，这些信息就在vocode的窗口中变成了乱码。
这是因为vscode有两个terminal：右下方有4个terminal——problems、output、debug console、terminal。其中output就是vscode自己内嵌的terminal，
而最后那个terminal才是系统的terminal。内嵌的terminal仅支持UTF-8，java的GBK输出就变成了乱码。所以解决方法应该有两个，第一个是将java以为自己的
locale中编码是UTF-8,这个我没找到可行的方法，第二个就是让coderunner使用外部的terminal，
也就是在setting中配置`    "code-runner.runInTerminal": true`


## c&cpp

### c_cpp_properties, launch, tasks三个配置文件的各自作用

c_cpp_properties.json中的设置内容只跟intelliSense相关，launch.json与tasks.json则与生成调试相关，二者其实是不相干的，很多时候intelliSense没有配置好导致
vscode界面上告诉你头文件等找不到，但只要launch与tasks正确配置了，一样可以正常调试。

intelliSense作为智能提示，很多功能是通过编译源代码到抽象语法树来完成，而编译就需要编译器与相应的头文件，
你可以在c_cpp_properties.json中看到相关的配置。

如果vscode界面上有黄色波浪线告诉你某某类型、变量找不到定义，就是缺少头文件，一般是缺少第三方头文件或者用户自定义头文件地址，因为标准库的头文件位置是编译器本身知道的。

launch则定义程序debug的启动方式，包括使用哪款gdb，启动命令与参数，是否只调试自己的代码等等。
launch运行前要求程序已经编译好，为此launch中通过`preLaunchTask`来关联运行前的动作，这个动作定义在tasks.json中，通常是一个编译动作。

在安装了插件ms-vscode.cpptools后，上述三个文件的设置可以变得相当自动化，该工具甚至会自动探测你安装的各种c/cpp编译调试工具，包括windows下的MinGW也能探测到，
非常智能。

vscode为不同的操作系统适配了c_cpp_properties文件内容，默认内容选择了各平台最亲近的编译器，通常是windows上的vc、mac上的clang、linux上的gcc，
可以通过`command+shift+p`调出命令面板，选择`C\C++:编辑配置（UI）`来查看或配置这个文件的内容。

通常，当我们在launch、tasks中配置了与平台下最亲近编译调试工具不同的编译器与调试器之后，就需要更改c_cpp_properties中的内容使得intelliSense指出的问题与我们编译的一致。

因为编译工具知道自己配套的标准库位置，实际上并不需要像[这里](https://www.jb51.net/article/186531.htm)说的那样用`gcc -v -E -x c++ -`来获得
编译器搜索路径。	

launch、tasks中的内容也通常是自动生成的，生成方法：`command+shift+p`调出命令面板 --> C\C++:生成和调试活动文件 --> 选择一个vscode自动探测到编译器工具
--> 确定后生成launch.json与tasks.json文件。

注意上述操作必须在打开一个c或cpp源文件的情况下才能使用，
因为自动生成的配置文件里会使用`${fileDirname}`等变量关联当前打开的文件。

生成launch与tasks之后就可以在vscode左侧RunAndDebug Tab里选择相应的配置来调试了。

若是使用了自定义的头文件或第三方头文件，就需要在tasks.json生成任务的`args`中配置进去。

有关c_cpp_properties.json更多配置项具体信息，可以参考[官方文档](https://code.visualstudio.com/docs/cpp/customize-default-settings-cpp)。


### watch表达式： 

可以在watch表达式中查看寄存器或是某个内存地址处的值，如下图：

![img](/assets/resources/vscode/watch_expr.png){:width="80%"}

## python



## 部分插件

### coderunner

coderunner是比较独立的一个插件，与各语言的支持插件不相干。

coderunner本质上是为当前打开的文件提供一个简易的运行命令，其命令可以在settings->coderunner->executorMap里配置。

就python而言，coderunner提供$pythonPath来设置使用的python解释器，但其他的呢？比如C、js、java又如何？？？？

因为是简易运行单个文件，像C或C++、java这种如果依赖了自定义的头文件或第三方库，或者是需要多个文件联合编译的情况下，
coderunner就不适用了。




