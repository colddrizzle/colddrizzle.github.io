---
layout: post
title: 分布式系列之一：分布式与一致性的建模方式与分类
description: ""
category: 分布式
tags: [分布式]
---
{% include JB/setup %}

* toc
{:toc}

本文是综合多篇分布式相关论文中建模方法的一个总结。

<hr />

## 分布式系统的分类

分布式系统内涵非常广泛，大到跨洲际的DNS服务、分布式数据中心，小到一个计算机内的多个进程，或者cpu的多个核心，都可以认为是分布式系统的范畴。
如此广泛的分布式系统的应用，没有一个统一的建模，相关理论是很难进行研究以及推广的，我们也很嫩学历其中的内容。本节参考多种资料中分布式系统分类而来。

目前读到的论文中分布式系统模型很明显有两类：
基于消息传递的与基于中央共享数据结构的。

前者见于Lamport相关的论文：
* 《Time, Clocks and the Ordering of Events in a Distributed System》
* 《The Part-Time Parliament》
分布式时钟与PAXOS算法都是基于这种模型。

该模型假设分布式系统有一组互相进行消息传递的进程组成。进程与进程直接传递消息，没有中心消息服务队列之类的东西。
进程与进程之前的消息可以是同步的也可以是异步。同步是指按顺序发送且按顺序接收。


后者多见于内存一致性模型的研究论文：
* 《Linearizability: A Correctness Condition for Concurrent Objects》
* 《How to Make a Multiprocessor Computer That Correctly Executes Multiprocess Programs》

我认识到所谓中央共享数据结构的概念来源于上面线性一致性论文。中央数据结构是一种高度的抽象。比如内存一致性模型中
的内存可以认为是一个字典：数据之间没有顺序，一个地址（key）对应一个值。
中央数据机构的实现中可能也包含一个进程，但是我们不感知其存在，自然也不对其建模，我们只关注整个中央数据结构的对外提供的接口、给出的保证，在此基础上进行研究。若是将中央数据结构的进程纳入模型，那这就不是一个分布式系统了，因为有了一个单点的中央进程。

分布性系统的特性比如一致性是受到中央数据结构的语义制约的，后面分析线性一致性与顺序一致性的时候会看到这一点。

### 分布式系统模型的层次性
同一套系统中可能有多个分布式抽象层。

比如当我们考虑计算机中内存模型的过程一致性的时候，建模的操作是各个核心的读写操作，共享数据结构是内存可以看做一个字典。
当我们考虑计算机中多个进程共享内存中同一个消息队列的时候，建模的操作是各个进程的入队、出队操作，共享数据结构是内存中的队列。
显然，后者模型是构建在前者的实现之上的。

所以当我们考虑一个实际的分布式系统时，务必要搞清楚我们关心的是哪一层。务必搞清楚三个问题：进程是什么、操作是什么、通信机制是什么（消息或者什么样的数据结构）。


## 分布式一致性模型的分类

本部分参考综述性论文[《The many faces of consistency》][0]。这篇文章偏重于概念区分，介绍了基于共享数据的分布式系统下的各种一致性的概念。

首先该文区分了两类一致性：状态一致性，操作一致性。每个分类下又各有小分类。

但在搞清楚一致性模型有哪些之前，我们先要弄清楚什么是一致性问题？为什么要保证一致性？

### 为什么要有一致性

在理解这个问题之前，我们先来理解一单个进程的执行顺序。假若在一个单核的计算机中，底层硬件的执行顺序与程序书写顺序不一致，那么显然是非常违反直觉的，然而这是可能的，
只要保证结果的一致性。显然这里面底层硬件向上层做了某种保证，使得底层硬件可以更改指令顺序但不能任意更改，前面对数据的修改必须对后面的指令可见，这是符合直觉的。

同样，并行系统中，也会存在上层用户与底层实现之间的协定，使得底层实现保证不会出现某些违反直觉的执行顺序。这种保证就是一致性模型。可以看到一致性模式是服务于上层用户习惯的
。

那么为了研究这个问题，就必须要研究上层用户看到的操作顺序与底层实现时间的执行顺序，这也就是时空图的作用了。


### 状态一致性
* 不变性（Invariants）
* 有限错误（Error bounds）
* 有限比例违规（Limits on proportion of violations）
* 重要程度（Importance）不同的数据可以有不同等级的一致（）
* 最终一致性（Eventual invariants）

需要注意的是该文中的状态一致性，全是基于共享数据的一致性，或者更偏重于不变性这个概念。
与分布式PASOX、RAFT等共识算法是两类问题，共识问题是基于消息传递的。

### 操作一致性
* 顺序等价（Sequential equivalence）
* 引用等价（Reference equivalence）其中提到的快照隔离（Snapshot isolation）可能是一个有趣的话题，数据库相关的文章再分析。
* 面向读写操作的

该文还根据领域区分了不同的一致性概念，也非常有参考价值，不再细说。

## 操作一致性问题中表示方法与基本概念
这部分内容主要取自于论文《Linearizability: A Correctness Condition for Concurrent Objects》
与PPT[《Sequential Consistency,Linearizability, and Serializability》][1]。

### 如何”观察“分布式系统的操作
考虑一个基于共享数据结构的分布式系统，其中每个进程都可以对共享数据进行操作，进程明确的知道自己进行的操作，但是并不知道其他进程的操作，
除非通过”观察“。

比如有共享内存的两个进程，进程A将计数器odd从1开始，每隔一秒加2，产生所有的正奇数。进程B将计数器Even从0开始每隔一秒加2产生所有的正偶数。
两个进程各自拥有自己的时钟，而时钟会产生偏差，因此通过时间来计算另一个进程的进度是不可靠的，唯一的办法是去读那个进程的计数器。

再比如共享同一变量x的两个进程，x的初始值为0.进程A在某一个时刻向x写入1，进程B在某一个时刻向x写入2。那么怎么判断这两个操作谁先谁后呢，只能通过”观察“x的值。若x的值为1，说明进程的写操作
发生在进程B的写操作之后。若x为2，则说明进程B的写操作发生在进程A的写操作之后。
在这个例子中，我们隐含了如下的假设：进程的先执行的写操作对其随后的读操作可见。进程对内存的修改立刻对所有的进程可见。有关内存一致性模型里我们会看到，前一个假设叫program order。
后一个假设在java中为volatile。

通过上面两个例子可以看到，一个进程必须通过”观察“才能感知另个一个进程中的操作相对于当前进程在观察那一时刻的先后顺序。然而，是否观察是由程序来决定的，进程之间的互相观察看到的也不一样，
因此分布式操作一致性的研究往往采用一种”全局视角“来建模，也就是时空图。

### 时空图、操作、事件、基本概念
结合前面为什么要有一致性的那一小节，可以认识到，假如我们要研究这一问题，需要一个有一种合适的描述手段，该手段能刻画两个关键：全局的操作在进程视角看起来如何，操作实际上发生的时间点又如何。

时空图，就是这样一种工具。

但在基于消息传递的分布式系统中与基于共享数据结构的分布式系统中，时空图略有不同。
一种是Lamport的全局时钟的论文中的时空图，这种时空图是对“事件”建模。

另一种就是上面提到的线性一致性的那篇论文中的时空图（尽管作者没有把他叫做时空图）。
这种时空图区分了事件与操作，对两者进行都进行了刻画。这种时空图也适用于Lamport提出顺序一致性的那篇小短文。

![img](/assets/resources/consistency_model_1.png)

如上图,图片来自[资料][1]第12页。

中间的实线是全局视角下的绝对时间，红蓝短竖线是两个进程中的操作的实际发生的时间在全局时间下的映射。
可以看到全局视角下，上层用户看到的两个进程的操作顺序可能有多种执行顺序。

另外有一些概念全部来自于上面提到的线性一致性的论文，不再细表。
* Operation
* Event
* History
* pending
* complete(H)
* sequential history
* concurrent history
* process subhistory
* object subhistory
* equivalent
* well-formed history
* prefix-closed
* sequential specification
* total and partial operation

## 状态一致性问题的建模表示方法

尚不明晰，待补充。但至少上文中基于共享数据与基于消息传递的两种要区分开，因为显然不同。

## 数据库系统中事务的建模

事务的建模似乎要比上面的模型更复杂一些，因为一个事务中包含多个operation，涉及多个object。
尚不明晰，具体有待补充，参考《Linearizability: A Correctness Condition for Concurrent Objects》论文3.3节后半部分中所涉及的资料。


[0]:https://pdfs.semanticscholar.org/8d67/a8f90586e3c074a60a871a210785ee61c43e.pdf
[1]:https://pdfs.semanticscholar.org/e436/d7f10aafb0eb83ced1229e32ac2e5f0f64a4.pdf
[2]:http://lamport.azurewebsites.net/pubs/pubs.html#multi

