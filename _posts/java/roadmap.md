一阶段路线图（一个月）
------------------------------------------------------------
操作系统相关 同步原语 基本同步问题


缓存一致性与指令重排序 等等细节不再考虑

volatile只是保证可见性

(把python的尾收掉)

java内存模型 主要通过java语言规范 理解语言规范里volatile i++ j++那个例子
		long  double的同步性

java中没有内存屏障的概念，确切的说内存屏障是CPU相关的硬件概念，CPU提供的一些平台相关的指令。
在java内存模型层面 抽象为各种order。我们只需要理解编译器、CPU以及高速缓存系统系统会带来一些列的指令重排序
。而java的内存模型就是来限制这种重排序的规则。


java多线程编程

java.util.concurrent包 全部搞懂

无锁结构 这里https://www.imooc.com/article/5619 提到的disruptor





------------------------------------------------------------
通过jvm了解nio

了解多线程普遍问题

了解jvm多线程处理

了解lucene









-------------------------------------------- 开放式路线图 ----------------------------

分布式系统
	远程过程调用

HTTP相关

Netty

TCP/IP相关以及Google等对TCP/IP的改进

网络硬件相关

Spring
