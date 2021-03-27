# windows下编译工具与环境  

## 使用codeblocks


setting->compiliers中的配置是全局相关的。

不同的编译器使用风格、信息的输出格式、调试器的调用方式都不一样，因此codeblocks需要一一对应的去适配。

因而这里给出了最大限度的各种编译器。

你所需要的做的就是找到自己机器上的编译器位置然后设置到对应的编译器工具配置里。

codeblocks已经自动帮你做了一部分，在toolchain executables中点击auto detect可以自动探测。自动探测出错才需要手动配置。

与项目相关的build配置在project->build options中

<br />


需要注意的是，mingw-gcc在windows下的结构体字节对齐指令使用的是VC的风格。
我们知道，本来这种指令是编译器相关的，由此可见mingw-gcc与gcc并不是gcc移植到windows那么简单，这确实是两种迥异的编译器。


## 使用vscode编译C

vscode作为一个多语言通用的IDE，自然也运行自己配置各种C编译器。