
---
layout: post
title: java内存模型
description: ""
category: java
tags: [jmm]
---
{% include JB/setup %}

* toc
{:toc}

java.util.concurrent分析系列

-----------------------

java的atomic是一种更好的volatile
atomic总是满足datarcefree的total order语义吗



------
几篇好文章：

加锁并不慢，慢的是锁竞争
https://preshing.com/20111118/locks-arent-slow-lock-contention-is/

永远使用轻量锁而不是内核锁
https://preshing.com/20111124/always-use-a-lightweight-mutex/


-------------
这里有几篇无锁算法的小巧实现：
https://preshing.com/archives/

https://coolshell.cn/articles/9606.html

协程
https://www.zhihu.com/question/20511233/answer/347651080