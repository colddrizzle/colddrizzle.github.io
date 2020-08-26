## 1
vscode 一个窗口只能打开一个工作区

一个窗口可以打开多个文件夹 所有的文件夹算作一个工作区 

但是只有进行保持到工作区之后才能再次以工作区的方式打开这些文件夹

## 2
VScode对于其支持的每种语言，有一些内建命令，通过ctrl+shift+p调出来
比如python就支持"Python:Select Interpreter"命令

## 3
vscode launch.json与code runner里的文件、路径 变量似乎是引用的当前打开的文件。

## 4
coderunner有一套自己的逻辑来选择使用哪个命令来运行当前打开文件

vscode好像也有一套配置来编译、调试当前打开文件

二者关系如何 
就python而言，coderunner提供$pythonPath来使用vscode设置的python解释器
但其他的呢比如C js java又如何



了解VSCODE

- 底部状态栏显示什么东西

- 状态栏似乎是根据当前打开的文件选择展示的信息的，比如python会有interpreter选项。但切到C文件还是由python解释器选项，
似乎是根据当前文件打开，设置完后称为整个工作区的配置项。

- 那么C\CPP的工作区配置项设置 比如vindows上想用GCC该怎么配置

- vscode开发者讲座：https://www.zhihu.com/lives/1124809477068849152

- coderunner

