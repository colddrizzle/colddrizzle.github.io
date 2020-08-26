---
layout: post
title: 使用vscode调试ant源码
description: ""
category: 软件工程
tags: [vscode, ide]
---
{% include JB/setup %}

* toc
{:toc}

<br />

* 1. 安装java extension pack 6件套

* 2. 下载ant源代码并且按照一个ant二进制包

这里用到版本是1.10.8

因为ant的源码也是用ant来构建的，因此要调试ant源码要先装一个ant。

* 3. 在vscode中打开解压后的ant源码

比如打开文件夹`D:/apache-ant-1.10.8`

* 4. 检测java extension pack正常启动

Language support for Java ™ for Visual Studio Code--也就是6件套里的第一个--语言支持，将会在你第一次访问
一个java源文件的时候自动启动，启动成功后会看到vscode右下角的向上大拇指标志。

VSCODE支持各种语言的高亮、提示、构建、编译等是通过[语言服务协议](https://docs.microsoft.com/en-us/visualstudio/extensibility/language-server-protocol?view=vs-2019)来实现的。该协议工作需要一边一个client也就是我们的vscode编辑器，一边一个server来提供语言支持，上述链接中有个图很直观。

java语言支持扩展则是基于[Eclipse JDT](https://github.com/redhat-developer/vscode-java)实现的。EclipseJDT包括4个部分，其中LSP4J已经支持了
LSP。

了解了这个java语言扩展包的大致原理之后有助于我们理解java语言扩展包的配置与后面出现的问题。


* 5. 添加源文件夹

vscode本身定位是一个轻量级的IDE，其原本的风格是打开一个文件夹，文件夹里就是源码顶级目录。但是对于真正的项目来说，其文件结构比较复杂。ant
项目不算复杂，但源文件也藏在apache-ant-1.10.8的顶级目录之下。如果上一步java语言支持扩展顺利启动的话，我们在左侧文件浏览窗口的main目录上应该可以右键“添加文件夹作为源文件夹”选项。

由于java语言支持服务早就已经启动了，为了提供各种语言静态分析服务，在添加源文件夹后，该服务会立刻编译源文件到java语言服务的workspace中，
注意这个workspace不是当前vscode的workspace。比如我的计算机上其位置在：
`C:\Users\Administrator\AppData\Roaming\Code\User\workspaceStorage\70ee9c002f57df1fb556abd84dc428bf\redhat.java\jdt_ws\apache-ant-1.10.8_a6d8d60f`。

我们添加的源文件夹作为一个设置并没有落地在vscode的setting.json中，而是这个语言服务的workspace中，这实质形成了项目文件夹之外的影子文件夹，当我们将项目文件拷贝到另一个一样配置的电脑时就会发现原来的某些设置丢失了，从这点来看，java语言扩展与vscode的结合是不够深的。

由于ant的build.xml文件在编译时会根据classpath中能否找到某些类库来选择性编译，而vscode也好java扩展包也好并没有支持ant，因此build.xml的内容是不知情的，这就会造成java语言服务编译源文件时发现大量的错误，各种类找不到，不要担心，这毫无影响，后面会看到，我们最后还是用ant来编译的，对本文来说，vscode只是一个作为一个带图形界面的调试工具。

* 6. 编译

java extension pack会自动探测你所用的java版本，但是你也可以通过vs命令`java:configure java runtime`来配置自己的版本。

确定了java版本，也确定了源码顶级目录，剩下一个就是jar包依赖了。java语言扩展基于eclipse jdt，后者本身支持maven与gradle构建工具，但是不支持ant，偏偏ant源码使用ant构建的。
这并没有关系，我们还是使用ant来构建ant源码，如果你喜欢，也可以配置一个task.json，其type当然是shell。

在terminal中输出`ant`构建，大约半分钟构建完成。生成的class文件都输出到`build/classes`文件夹下了。

* 7. 调试

然后在左侧调试tab中创建基本的launch.json，由于这个创建launch.json我们没有使用maven或者gradle，其会将源码顶级目录下所有包含一个main方法的
类都添加到launch.json中，而我们要的是mainClass为`"mainClass": "org.apache.tools.ant.Main"`的那一个配置，其他大可删掉。

然后左侧debug的tab中选择`Debug (Launch)-Main<apache-ant-1.10.8_a6d8d60f>`开始调试，

调试会报错说编译失败，当然会编译失败，但者不影响运行，根据[vscode java debug](https://github.com/Microsoft/vscode-java-debug/blob/master/Troubleshooting.md#build-failed-do-you-want-to-continue)，我们的编译失败是肯定是以为project有问题而不是源码有问题，project之所以有问题是因为它不支持ant，不按照ant的build.xml来构建当然有问题。配置当前工作区下的vscode java debug扩展，添加`"java.debug.settings.forceBuildBeforeLaunch": false`。
然后将我们的ant编译配置成task，作为launch中我们的配置的preLaunchTask就可以了。

在`G:\apache-ant-1.10.8\src\main\org\apache\tools\ant\Main.java`中的main方法打上断点，启动调试就可以了。

右下terminal中会看到调试的完整命令，比如：

```
cd g:\apache-ant-1.10.8 && c:\Users\Administrator\.vscode\extensions\vscjava.vscode-java-debug-0.26.0\scripts\launcher.bat D:\Applications\jdk-13\bin\java.exe -agentlib:jdwp=transport=dt_socket,server=n,suspend=y,address=localhost:63547 -Dfile.encoding=UTF-8 -cp build/classes org.apache.tools.ant.Main
```

可以看到调试会先进入ant源文件下，而这个文件夹下有个build.xml，调试启动的ant没有参数，把当前目录下的build.xml作为输入，刚好又自己再编译一边。


似乎很顺利。但是等等，java扩展包既然不支持ant，怎么知道ant的编译的输出目录呢？其实java扩展包确实不知道，这仅仅是一个巧合而已，默认情况下，
java扩展包会把工作区下的src文件作为源码的顶级目录，build文件作为classes输出，这刚好与ant的build.xml中配置一致了。

那照这么说，如果我们修改下build.xml中的`  <property name="build.dir" value="build"/>`为`  <property name="build.dir" value="my_build"/>`。
调试应该无法启动才是。修改一下再跑，会发现还能运行？这不科学！果然，查看terminal中的命令会发现其`-cp`后面的值自动换成了java语言支持工作区里面的那份class文件了。

但我认为，java语言扩展自动更换classpath这么做是不对的。

很显然，ant的构建过程是通过build.xml来进行的，这里面可能会有一些依赖的版本限制或者编译时候的条件选择，而java语言工作区里的class文件是java语言扩展自己编译的，它肯定不知道build.xml中的这些配置限制之类的，由此它编译的东西大概率是有问题的，作为语言支持提供服务可以，作为调试目标启动，不行。

那既然是个巧合，有没有办法自定义调试启动时候的classpath呢？当然有，配置“classpaths”：

```
        {
            "type": "java",
            "name": "Debug (Launch)-Main<apache-ant-1.10.8_a6d8d60f>",
            "request": "launch",
            "mainClass": "org.apache.tools.ant.Main",
            "projectName": "apache-ant-1.10.8_a6d8d60f",
            "classPaths": ["my_build/classes"]
        }
```

再启动调试，从terminal看到的启动命令里我们的配置生效了。