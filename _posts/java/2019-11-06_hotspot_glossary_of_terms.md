---
layout: post
title: java concurrent
description: ""
category: 其他
tags: [console, windows, unicode]
---
{% include JB/setup %}

http://openjdk.java.net/groups/hotspot/docs/HotSpotGlossary.html
对上面的术语基本理解 

### 自适应自旋

自适应自旋显然是在自旋与挂起之间提供了一种权衡。那么我们就要理解自旋与挂起
的开销的差异性，才能理解哪些情况下自旋好，哪些情况下挂起好。

首先我们需要意识到CPU与内核做各种动作的时间数量级的差异。


挂起线程的开销：立刻进行一次上下文切换，这个时候时间片大概率没有用完。若是自旋的时间很短，在时间片用完之前（时间片一般几百毫秒左右，相对于指令执行时间来说，非常长）

