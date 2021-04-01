---
layout: post
title: python标准库之multiprocessing
description: ""
category: python
tags: [python lib, multiprocessing]
---
{% include JB/setup %}

* toc
{:toc}

我们知道python提供有subprocess模块用于取代os.system、os.spawn等模块功能。

multiprocessing模块里也有Process对象，不过并不是取代subprocess。

subprocess正如其名所说，创建的进程只能是子进程，而process则是更一般的对操作系统的进程的抽象，更像Linux中的fork。
与之相比，subprocess更像是进程功能特化的一个模块：我有一个任务需要外部进程执行，我只需要等待结果就可以，没有其他复杂的交互。
而multiprocessing是为多进程协作而生的。

自然可以创建所谓守护进程，这点从multiprocessing.Process的接口文档可以看出来：

```
class multiprocessing.Process(group=None, target=None, name=None, args=(), kwargs={}, *, daemon=None)

```