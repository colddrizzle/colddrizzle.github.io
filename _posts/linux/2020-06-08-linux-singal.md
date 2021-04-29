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

# 基本

## 信号的作用

信号是进程间通信机制中唯一的异步通信机制,一个进程不必通过任何操作来等待信号的到达，事实上，进程也不知道信号到底什么时候到达。进程之间可以互相通过系统调用kill发送软中断信号。内核也可以因为内部事件而给进程发送信号，通知进程发生了某个事件。信号机制除了基本通知功能外，还可以传递附加信息。


## 信号的种类

可靠信号与非可靠信号

	Linux supports both POSIX reliable signals (hereinafter "standard signals") and POSIX real-time signals.

一个验证可靠信号与不可靠信号[小程序][0]，通过该程序我们可以知道：

	一：SIGINT是不可靠信号。发送了3次父进程只接收到1次，SIGRTMIN是可靠信号，发送了3次父进程接收到3次信号。
	二：对于可靠信号，Linux内核会缓存可靠信号，Linux内核可以缓存8192（各个Linux版本不同）条可靠信号；对于不可靠信号，Linux只能缓存一条不可靠信号。
	三：执行命令行： ulimit -a
	   查看Linux支持的信号性能参数
	四：发送信号的数量超过系统上限，将会发送失败


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

# 内部原理
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


## 信号竞态

## 两套API
可靠非可靠： signal-kill sigaction-sigqueue

进程信号与线程信号

## 信号与进程、线程


### 多线程下

随着Linux的内核版本不断提升，Linux的信号现在已经可以按照线程级别的触发了，换句话说就是，每个线程可以关注自己的信号了，并且可以区别性对待了。那我们需要注意什么呢？

在多线程应用中，我们应当使用sigaction来代替singal函数，因为按POSIX的说法singal函数并没有明确定义自己在多线程应用中的行为。

可以使用pthread_sigmask来为每个线程设置独立的信号掩码。同时在多线程应用中应当避免使用sigprocmask这个函数，原因也是POSIX中该函数并没有明确定义自己在多线程应用中的行为。

这个时候，有人会产生疑问了，那么多线程下kill发出的进程级别的信号A怎么办？Linux是这样解决的，它会把这个信号交付给任意一个没有屏蔽信号A的线程。如果这信号没有被任何线程设置handler进行处理，就会触发POSIX规定的默认动作。

接着有人就会问，我怎么向某个线程发消息呢，POSIX为我们准备了pthread_kill函数，我们可以直接向特定的线程发送消息。那么如果一个线程收到信号A，但是自己没有安装handler会发生什么？其实和进程级别的信号处理方法一样，直接触发默认动作，同样会结束整个进程。


# 其他

SIGSEGV与分布式内存

# FAQ





https://blog.csdn.net/whatday/article/details/90136670 


[0]:/assets/resources/source/signal_kinds.c









sleep()过程中接受到哪些信号会唤醒进程