---
layout: post
title: python虚拟机框架与运行环境初始化
description: ""
category: python
tags: [python,cpython]
---
{% include JB/setup %}

* toc
{:toc}

</hr>

本篇文章关注的重点是python代码是如何跑起来的，或者详细点说，python虚拟机本身的大致结构以及是如何处理python代码的。
本质上是《Python源码剖析》的读书笔记。

也许你注意到了标题“虚拟机”这个词，是的，python并不是一门通常意义上的解释型语言，python更像是一门编译型语言。cpython会首先把
python代码编译成字节码，再扔到虚拟机里去执行。如果拿真实机器来对应，字节码就是汇编代码，虚拟机就是CPU与内存构成的裸机。

### python代码的编译与运行
python源码py文件会先编译成pyc文件。py文件是python代码无疑，而pyc文件其实是整个源文件对应的PyCodeObject对象的2进制存储，或者说是用C语言
层面的逻辑把python代码重新组织了一边，毕竟将python代码结构化才能处理。
#### 将python代码编译成PyCodeObject对象

#### PyCodeObject对象与pyc文件直接互相转化

#### 执行PyCodeObject对象

### 虚拟机框架

#### 基础组成部分

#### 源码编译过程的一些细节
如何对应code与代码

如何确定globals


#### 运行环境初始化


#### 宏观图

### 作用域规则与命名空间

#### 词法作用域规则

#### globals与locals作用域

#### 命名空间与属性引用

#### LEGB名字查找规则


