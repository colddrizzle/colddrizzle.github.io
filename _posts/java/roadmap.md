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
通过jvm了解nio 搭建环境的：https://www.cnblogs.com/coldridgeValley/p/7795297.html  https://cloud.tencent.com/developer/article/1391180

了解多线程普遍问题

了解jvm多线程处理 要包括多线程如何调试 一些框架中的多线程模型 

了解lucene




--------------------------------------------------------

数据库相关

什么切分、快照隔离
主重备份啊 所有的实用性、理论性的



-------------------------------------------- 开放式路线图 ----------------------------

阿里巴巴java编码规范
java se安全编码指导：https://www.oracle.com/technetwork/java/seccodeguide-139067.html

分布式系统
	远程过程调用

HTTP相关

Netty

TCP/IP相关以及Google等对TCP/IP的改进

网络硬件相关

Spring

------------------------- 工程相关 -----------------------------
ant
mylyn
maven

6月之前走到这一步
----------------------------------------------------------------
网站框架研究



----------------------JAVA 语言及平台基础

一个java对象至少占用内存的大小 C++里的RALL

https://docs.oracle.com/en/java/javase/13/index.html

https://docs.oracle.com/javase/7/docs/technotes/guides/rmi/index.html

https://docs.oracle.com/javase/9/rmi/toc.htm



2015系列 基于1.8的tutoral写个笔记系列吧

 java平台roadmap参考如下：
https://docs.oracle.com/javase/8/docs/technotes/guides/
https://docs.oracle.com/javase/tutorial/tutorialLearningPaths.html

transient关键字

-----------------------
阅读java源码时应关注的问题：
用到的设计模式
extends 与 implement的使用 抽象类 抽象方法的使用
final的使用 理解那个场景下为什么做这样的设计选择


----------------------------
??? 记一次Event Storming实战经历 DDD 微服务 serverless
DDD:https://medium.com/hackernoon/how-to-decompose-a-system-into-modules-796bd941f036


java为什么要有线程组

java有没有类似linux kprobe这样的东西


一篇博文：被人遗忘的java8的8个功能

https://blog.csdn.net/weter_drop/article/details/84636826

https://www.zhihu.com/question/27720523

https://www.marcobehler.com/2014/12/27/marco-behlers-2014-ultimate-java-developer-library-tool-people-list

https://www.v2ex.com/t/624059 lombok不足之处

java :enclosing scope
https://www.quora.com/What-is-enclosing-scope-in-Java
https://stackoverflow.com/questions/33799800/java-local-variable-mi-defined-in-an-enclosing-scope-must-be-final-or-effective


虚拟机与类加载器的文章关系：

虚拟机系列应该有个文章
其中一章是类与接口的生命周期
而类加载器是这个生命周期中加载那一个环节的事情。
类加载器注重描述几种类加载器的默认行为
委托模型、类查找与连接错误


java中record有没有对齐需求


java中重载

java冷知识：https://segmentfault.com/a/1190000021101318?utm_source=tag-newest
其中有关string存储与gc的内容，值得注意



java版本相关：
https://www.zhihu.com/question/360985479