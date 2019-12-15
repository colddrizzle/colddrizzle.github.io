
## java

mac下允许安装多个jdk，那个mac是怎么确定使用哪一个jdk的呢？

在/System/Library/Frameworks/JavaVM.framework/Version/Current中
mac将java将java命令都包装了一遍，当运行一个java命令的时候，实际上是运行的这个
目录下Current中的java命令，可以通过查看软连接来确认这一点。
当这里的java命令运行时，首先查看当前用户的JAVA_HOME环境变量，如果没有设置的话，那么就用
/usr/libexec/java_home工具来确认当前默认java版本，java_home工具的原理大概就是遍历
/Library/Java/JavaVirtualMachines/下所有的jdk版本下的Info.plist文件，根据其中的
JvmVersion字段将最新的jdk版本作为默认的jdk版本。（所以如果把Info.plist中的JvmVersion版本改小，
就可以改变jdk顺序，但实际上没必要这么做，因为被mac包装的java命令会首先检查JAVA_HOME环境变量，所以
一般设置JAVA_HOME环境变量就可以选择我们使用jdk版本）

java_home其实mac提供的一个java版本管理工具，参见：https://medium.com/notes-for-geeks/java-home-and-java-home-on-macos-f246cab643bd


## xcode

xcode-select 是个开发环境路径选择工具

xcode-build是个打包工具

xcode commandline tool下的gcc其实是clang的链接（所以用gcc -version你看不到gcc版本） 只安装commandline tool 默认没有gcc
xcode真是唯恐天下不乱 占用了gcc的名字，还误导了我一段时间 然后独立安装gcc的话只能用另外的名字来调用


## c

我理解的c下各种库的层级

![img](/assets/resources/c-lib-hierarchy.png)

关于libgcc：http://gccint.cding.org/Libgcc.html

libc是以前linux上的运行时库，后来被glibc代替

还有个非常相似glib，是gtk+的实现

关于c运行时库：https://www.internalpointers.com/post/c-c-standard-library

brew install 安装的gcc链接的是mac自己提供的运行时库，可以通过`gcc -print-sysroot`来验证。有些c11的头文件mac上没有，但mac上多半有了自己的实现

关于gcc对于c11的支持可以看这儿：https://gcc.gnu.org/wiki/C11Status
