计算机语言的基本模板

计算机语言仅仅关心程序如何组织以及如何与程序宿主环境进行交互，
其他的都是宿主环境提供的库，比如UI编程音频视频等等。遵从这个定义
一门计算机语言的基本模板我想可以看做如下5部分：值、流程控制、函数、Basic I/O、模块化。
## 值
### 左值与右值
有的语言比如SQL没有左值

有的语言比如正则表达式只有匿名左值

### 类型
结构体 数组 tuple都可以看做类型

## 流程控制
### 单流程
if else
while
for 
do until
select
### 并行控制
大部分语言的并行控制就是对操作系统进程、线程、信号量、锁等机制的简单封装。

但就并行这个模型，语言可以有自己的抽象封装，比如go语言

## 函数

对值的所有操作都可以看做函数，包括赋值比如Lisp
各种表达式也可以看做函数


当值、流程、函数综合在一起的时候，还会有命名空间的概念，但我们认为这是一个衍生概念，不属于语言的基本组成。

## 基本输出输出
键盘
磁盘
网络

## 模块化
提供将代码组织成库、模块的功能
