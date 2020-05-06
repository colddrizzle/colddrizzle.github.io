---
layout: post
title: java rmi framework notes
description: ""
category: java
tags: [rmi, java, framework]
---
{% include JB/setup %}

* toc
{:toc}

## 一个能在jdk12下跑起来的例子

[github](https://github.com/colddrizzle/deep_in_rmi/)

例子基本就是这个官方tutoral中的[例子](https://docs.oracle.com/javase/tutorial/rmi/overview.html)

需要注意的是JDK7u21对RMI的[进行了增强](https://docs.oracle.com/javase/7/docs/technotes/guides/rmi/enhancements-7.html)，需要设置
java.rmi.server.useCodebaseOnly=false属性。否则会出现[问题](https://stackoverflow.com/questions/16769729/why-rmi-registry-is-ignoring-the-java-rmi-server-codebase-property)

另外要关闭sock5等代理、关闭防火墙，否则会出现SocketIoException异常。

## 一点基本理解
要区分远程对象与非远程对象。远程对象传递一个代理，非远程对象进行值拷贝。

三个独立的JVM环境。客户端、服务器端、Registry。


结合上面例子文档以及[这里](https://www.tutorialspoint.com/java_rmi/java_rmi_quick_guide.htm)


关于codebase的理解，server端与client端都要提供一个codebase。其实这两个codebase可以认为是
给stub与skeletion共同维护的小环境提供的，他们加载类的路径被限制在codebase里面。如下图：

![img](/assets/resources/rmi_architecture_0.jpg)

上面的例子里，服务端加载客户端代码好理解，那什么时候客户端加载服务端代码呢？github demo_v2就是。

about codebase：http://www.kedwards.com/jini/codebase.html

[官方资料](https://docs.oracle.com/javase/7/docs/technotes/guides/rmi/codebase.html)也讲的很好。



## 一些注意的点
安全管理器

policy 与 codebase

本地注册

安全方面的

useCodebaseOnly很奇怪的名字

## 一些值得深挖的疑问

远程加载代码怎么使用安全的链接

registry做了什么

RMI名字只能绑定到本机的registry。在分布式环境下上面貌似还要再加一层注册中心。

RMI的并发性能

开了sock5全局代理之后，telnet仍然能够访问另一台电脑的网页。但是RMI就玩不转了，同样是tcp，
区别在哪里呢

## 一些文档

RMI调试技巧：https://www.javaworld.com/article/2077556/java-tip-56--how-to-eliminate-debugging-problems-for-rmi-based-applications.html

[官方FAQ](https://docs.oracle.com/javase/8/docs/technotes/guides/rmi/faq.html)

JAVA SE7关于RMI的资料:https://docs.oracle.com/javase/7/docs/technotes/guides/rmi/index.html
java SE9中rmi安全建议：https://docs.oracle.com/javase/9/rmi/toc.htm

两边的远程对象的类路径必须一致，但是代码不必是同一份。

客户端好像必须设置useCodebaseonly为false？ 因为客户端总要加载远程代码？

bind rebind只允许绑定到本地

