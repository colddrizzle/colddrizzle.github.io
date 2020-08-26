---
layout: post
title: Linux进程、线程组织关系

tagline: "Supporting tagline"
category : linux
tags : [linux, process, thread]

---
{% include JB/setup %}

* toc
{:toc}

<hr/>

## 进程线程关系
linux中的pthread线程实现以1比1于内核线程的，又被称为轻量级进程（LWP）。

在内核源码中，线程id被命名为pid，线程组id被命名为tgid。

对外暴露的系统调用中，getpid()实际获得是内核中的tgid，gettid()实际获得是内核中的pid。

这看起来就像是linux原来不支持线程，而后加上的线程概念，如果将内核中pid改成tid，一切就清晰的多了。

## 进程关系

### 父子关系
系统初始化进程init或systemd没有父进程，其PPID为0。此外，我的ubuntu上kthreadd进程也没有对应的父进程，
由此可见并非所有的进程都有对应的父进程。

fork创建的进程自动建立父子关系。父子关系建立后除非进程退出，否则不可更改。所谓退出，是指父进程退出，子进程
自动被系统初始化进程收养，其PPID变为系统初始化进程ID。


### 进程组与session

每个进程都属于一个会话和一个进程组。会话ID与进程组ID都是pid_t类型。

通过fork创建的进程继承其父进程的会话ID与进程组ID。进程的会话ID与进程组ID在调用execve后依然保持不变。


会话与进程组被抽象设计出来用于支持Shell Job控制。一个进程组（有时候称之为一个Job）是相同组ID的一组进程。shell会为单个执行的命令或者管道命令组（比如`ls|wc -l`）创建一个新的进程组。组ID与自身ID的相等的进程是这个组的group leader进程。

group leader进程退出，进程组仍然存在，并不会自动选举新的leader，仍然可以向该进程组发消息（比如kill -sig -pgid）

会话是相同会话ID的进程集合。一个进程组的所有成员必然拥有相同的会话ID（也就说一个进程组所有成员只会属于一个会话，会话与进程组构成一个严格的二级层级关系）。
进程调用setsid来创建一个新会话，新会话的ID与其进程ID相同，创建成功后调用者成为该会话的session leader。无论如何，一个session leader总是一个group leader。

session leader进程退出，会话仍然存在，并不会自动选举新的leader。

会话中的所有进程共享同一个控制终端。当session leader第一次打开一个终端文件的时候建立起与控制终端的联系（除非调用open时设置了O_NOCTTY选项）。一个终端最多是一个会话的控制终端。调用setsid创建新会话后并不会自动关联控制终端。

会话中最多有一个Job可以成为foreground job（前台job，最多一个，可以没有）。只有foreground job可以从控制终端读取输入。当后台进程试图读取控制终端的时候，其进程组就会收到一个SIGTTIN信号，该信号挂起这个进程组。如果终端设置了TOSTOP标志（查看 termios(3)），那么只有foreground job可以向终端输出。后台进程组试图写终端将会导致一个SIGTTOU信号，该信号挂起该job。当控制终端收到一个按键产生的信号（比如
中断信号ctrl-C），这个信号就会被送到foreground job.

终端里运行的shell是bash的情况下，bash本身是session leader，当然也是group leader。但在bash中运行的命令会有一个新的group，也就是foreground group。

简单理解就是：支持进程组是为了运行管道命令组，支持会话是为了管理控制终端输入输出。

注意此处的会话与http中的session没有太大的关系，http中的session用来保持身份认证信息，而linux中登录的身份认证信息是通过连接来保持的，也就是通过终端来保持的。

### job与进程组的关系
progress gounp与job本质上是同一个东西，只是命名不同，应用的场合略有不同，在内核环境中，通常称进程组，在shell层面或者用户操作层面，称之为job。并且同一个进程组或Job，其进程组ID与JobID不是相同数字。

不要因为使用作业控制命令jobs无法查看系统中所有的进程组而误认为job与进程组不同。之所以无法查看仅仅是因为shell所在的terminal只能是当前session的控制终端，系统中其他session没有控制终端或者有其他的控制终端。

有博客声称job中进程创建的子进程不属于该job。确实使用`jobs -l`查看job状态看到其子进程的PID，但是使用`kill -sig_num %job_id`向job发送信号其子进程依然能收到信号。因此，job中创建的进程依然属于该job，如同man credentials中所讲的那样，进程组与job是同一个东西不同的命名，既然进程组中进程创建的子进程属于该进程组，job也理应如此。

### 进程组、会话与父子关系

父子进程可以分别属于不同的会话或不同的进程组。

父进程可以加入子进程的进程组，只要保证子进程先创建进程组，然后父进程调用setpgid加入该进程组就可以。

设置进程组的时候，进程只能更改自己或自己子进程的组ID，且目标组ID只能是相同session下的组，参见man setpgid。

创建新会话的时候，会同时创建进程组，调用setsid的进程同时成为group leader与session leader。

一个已经存在的进程加入一个已经存在的进程组可以通过setpgid而来，而一个已经存在的进程没有办法加入一个已经存在的会话，setsid只会创建新会话。

### 进程组织与信号

#### 父子

子进程退出的时候会像父进程发送SIGCHLD信号。

#### 进程组
可以使用kill命令或函数向进程组发信号，所谓向进程组发信号，其实是轮流向进程组中每一个进程发信号。

可以使用`kill -sig_num %job_id`向job发送信号。

在终端中，Ctrl+Z产生的信号SIGTSP会发送给foreground job中的每一个进程，其他也如此。

#### session

如果session有关联的控制终端，当该控制终端关闭的时候，会向session中的所有进程发送SIGHUP信号。

## 守护进程

首先我们有必要区分守护进程与后台进程。

后台进程或者后台进程组是在控制终端的环境下 相对于前台进程来讲的，后台进程无法读取终端的输入，终端按键产生的信号（Ctrl-C,Ctrl-Z）等也不会发往后台进程。
当关闭终端的时候，后台进程是会被杀掉的。除非使用nohup忽略掉关闭终端时产生的SIGHUP信号。

守护进程是指脱离了任何控制终端的进程，任何控制终端的关闭都不会导致该守护进程停止运行。因此，该进程不会随着用户的注销而注销。

将一个现有的非守护进程以守护进程的方式运行的方法有:
1. nohup命令+&
2. setsid命令

而编写一个守护进程的方法有：

1. setsid函数+fork函数+直接运行
2. setsid函数+&后台运行

以上几种创建方式并无本质性的区别，最后的结果都是得到一个有独立session且不关联任何终端的进程。

关于使用程序创建守护进程大致可以参考[资料1][10]和[资料2][11]，这些资料中都讲到要改变工作路径、修改文件掩码、以及关闭不必要的文件。
但这些都是使用fork也就是上面第一种方式的情况下。如果不使用fork自然也不需要这些操作。总而言之，创建守护进程的核心方法就是一个setsid。

[这里][12]还有一个python下守护进程的讨论，其实是借着python聊linux下的守护进程，因为大部分时候python只是在宿主系统上的一层简单的封装。

## job管理
参考下面俩连接内容足够了。

https://www.cnblogs.com/harrymore/p/8794944.html

https://blog.csdn.net/qingsong3333/article/details/77418104

## 扩展：内核级线程、用户级线程
线程实现只有两种，用户级线程与内核级线程。

要区分两个概念，用户级线程库与用户线程。用户线程就是用户直接看到和操作的线程，用户线程未必是由用户级线程库实现的。

一般来讲，用户线程（而不是用户级线程库中的用户线程）与内核线程的对应关系存在三种：
1. 一个内核线程对应一个用户线程
2. 一个内核线程对应多个用户线程
3. M个内核线程对应N个用户线程（M<N）

通常来讲，用户级线程库是一对多的，也就是一个内核级进程或线程对应多个用户级线程。用户级线程实现不必依赖内核级线程。

而内核级线程只是线程实现更深的一种方式，其上一般就不会再使用用户级线程库（当然也可以使用）。

linux遵循pthread接口的线程实现是一对一的，也因此被叫做LWP。其实LWP本身是内核级线程，因为LWP的创建、调度等都是内核直接参与的，之所以叫LWP是因为一对一。

以上还可参考[这里](https://stackoverflow.com/questions/8639150/is-pthread-library-actually-a-user-thread-solution/)

## 更多资料：
https://www.cnblogs.com/sparkdev/p/12146305.html

https://www.cnblogs.com/wangfengju/archive/2013/05/12/6173072.html

shell并非是与登录完全相关的概念。登录确实会创建一个session,但是
不登录有时候也会创建session，从根本上讲，session只是进程管理方式。
https://unix.stackexchange.com/questions/385110/do-all-the-jobs-in-a-bash-shell-exactly-form-a-session

https://stackoverflow.com/questions/11120202/when-is-setsid-useful-or-why-do-we-need-to-group-processes-in-linux

https://unix.stackexchange.com/questions/240646/why-we-use-setsid-while-daemonizing-a-process

[10]:https://www.cnblogs.com/mickole/p/3188321.html
[11]:https://blog.csdn.net/kwinway/article/details/80141242
[12]:https://www.ibm.com/developerworks/cn/linux/1702_zhangym_demo/

