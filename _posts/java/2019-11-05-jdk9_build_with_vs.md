---
layout: post
category : java
tagline: "Supporting tagline"
tags : [jdk, java, build]
title : windows下编译jdk9
---

{% include JB/setup %}

关于jdk与openjdk的关系不去关系，现在只需要知道二者有稍许不同，大部分一致。

那我们编译的是openjdk 9的源码。

[openjdk官网][0]上的开发者指导并没有给出编译的方式。但在网站左侧的groups，猜测是因为jdk项目非常大，分成了许多专门的小组来负责。
各小组的文档里有很多有趣的东西，比如hotspot、compiler、networking小组。关于的jdk构建的资料主要来源于[build小组的文档][1]。



[0]:http://openjdk.java.net/guide/
[1]:http://openjdk.java.net/groups/build/
[2]:
[3]:
[4]: