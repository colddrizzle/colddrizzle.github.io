什么是工作区：
https://www.cnblogs.com/mouseleo/p/12658924.html


GotoDefination是怎么实现的以及语言服务协议：
https://zhuanlan.zhihu.com/p/100438617
https://docs.microsoft.com/en-us/visualstudio/extensibility/language-server-protocol?view=vs-2019
理解了语言服务协议才能理解vscode中的一些插件是怎么工作的
理解插件的配置项的含义

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
locale中编码是UTF-8,这个我没找到可行的方法，第二个就是让coderunner使用外部的terminal，也就是在setting中配置`    "code-runner.runInTerminal": true`