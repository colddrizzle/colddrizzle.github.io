---
layout: post
title: Linux信号概述

tagline: "Supporting tagline"
category : linux
tags : [linux, signal]

---
{% include JB/setup %}

* toc
{:toc}

<hr/>

## 信号的作用

## 信号的种类

SIGTSTP SIGSTOP区别：
SIGTSTP与SIGSTOP都是使进程暂停（都使用SIGCONT让进程重新激活）。唯一的区别是SIGSTOP不可以捕获。
捕捉SIGTSTP后一般处理如下：
1）处理完额外的事
2）恢复默认处理
3）发送SIGTSTP信号给自己。（使进程进入suspend状态。）


2) SIGINT
程序终止(interrupt)信号, 在用户键入INTR字符(通常是Ctrl-C)时发出，用于通知前台进程组终止进程。
3) SIGQUIT
和SIGINT类似, 但由QUIT字符(通常是Ctrl-\)来控制. 进程在因收到SIGQUIT退出时会产生core文件, 在这个意义上类似于一个程序错误信号。
15) SIGTERM
程序结束(terminate)信号, 与SIGKILL不同的是该信号可以被阻塞和处理。通常用来要求程序自己正常退出，shell命令kill缺省产生这个信号。如果进程终止不了，我们才会尝试SIGKILL。
19) SIGSTOP
停止(stopped)进程的执行. 注意它和terminate以及interrupt的区别:该进程还未结束, 只是暂停执行. 本信号不能被阻塞, 处理或忽略.

## 信号的产生

ctrl+c terminal SIGINT
ctrl+z suspend SIGTSTP

ctrl+d exit //not signal

ctrl+\ sigquit

```mermaid
graph LR;
A-->B
```

## 信号的投递

## 信号的处理

## 两套API

## 信号与进程、线程



https://blog.csdn.net/whatday/article/details/90136670 