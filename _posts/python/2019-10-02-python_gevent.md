---
layout: post
title: 基于协程的网络并发库gevent
description: ""
category: python
tags: [python, gevent]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

gevent实在是一个功能非常复杂的python库。官方的介绍还是比较准确的，细细理解下面这段话：

	gevent is a coroutine-based Python networking library that uses greenlet to provide a high-level synchronous API on top of the libev or libuv event loop.

可以看出gevent是一个基于协程的网络并发库。我们知道，协程是基于事件循环的（大体原理类似于浏览器内支持javascript异步回调的事件循环），libev与libuv是两个非常高性能的事件循环库。

其特性大概可以从[introduce features](http://www.gevent.org/intro.html)
与[module list](http://www.gevent.org/api/index.html#module-listing)大概有个印象。

我会逐渐将所有模块大致介绍一遍，顺序单凭喜好。

## 关于协程与事件循环

[Gevent 调度流程解析](https://www.sohu.com/a/195260119_176628)

## gevent.Greenlet

greenlet就是gevent提供的协程实现了，当然python3也提供了自己的协程实现async/await与异步并发库asyncio。

但是协程库这个东西要想灵活操纵，必然要深度hack的，因此gevent自己有一套协程库也很容易理解的。

实际上，greenlet是一个单独的项目，有自己独立的[官网](https://greenlet.readthedocs.io/en/latest/)。

gevent其实依赖于上面那个项目的。


虽然gevent使用协程但gevent绝非是单线程的。所谓“gevent不使用线程”是说不使用python提供的线程，但通过任务管理器观察`downloader.py`的执行就可以知道，是多线程，而且线程很多，推测是libev与libuv事件循环库
会创建自己的线程，但因为libev与libuv是C库，这时候创建的是原生线程， 不受GIL影响，以上事件循环库会创建自己的多个线程，有待验证，或者
gevent还有其他地方也要创建自己的辅助线程，也有待验证。


## gevent.monkey

monkey是一个底层补丁。我们知道协程这东西是依赖于主动放弃CPU的。但是一些阻塞IO系统调用陷入阻塞的时候
协程库本身是没法知道陷入阻塞的，也就没有办法切换到另一个协程来运行，操作系统会认为是整个线程放弃了CPU。

因此，需要将这些阻塞系统调用包装一下，当要陷入阻塞的时候，仅仅是发起阻塞系统调用的协程放弃CPU，协程库切换到另一个
可运行协程继续执行，对于操作系统来说，线程并没有放弃CPU。

可以想见，包装的方式肯定是用非阻塞版本去替换阻塞版本（之后非阻塞版本是用轮询还是select\poll都可以）。

monkey生效的范围当然是整个python解释器实例，但应该是greenlet协程内才会发挥正常该有的作用。
毕竟，放弃CPU是协程的事情。当使用monkey而不使用greenlet的时候会发生什么呢？

另外[这里](https://www.liaoxuefeng.com/wiki/897692888725344/966405998508320)最后提到仅仅使用一个gevent.wsgi服务器，性能就会获得提升，这又是为什么呢？


使用的方式很简单：

```brush:python

#导入monkey并打补丁

from gevent import monkey; 
monkey.patch_socket()

# 然后正常的使用gevent的协程与python标准库的网络模块就可以了
import urllib2 # it's usable from multiple greenlets now

```

## gevent.socket

按照gevent.monkey的介绍，monkey既然已经为greenlet协程封装了阻塞IO调用，为什么还需要
gevent.socket呢？

我的理解是为了方便扩展现有代码，毕竟gevent.socket的接口完全兼容标准库的socket，并且额外提供了一些方法，
重点就在于尽量少侵入性地引入额外提供的这些方法。

gevent.socket的[协程安全性](http://www.mamicode.com/info-detail-651145.html)

## gevent.thread、gevent.threading

很好理解，兼容标准库接口的实现，但线程换协程。

## gevent.pool

python标准库线程因为GIL的原因没有提供线程池的必要。但是gevent作为一个基于协程的并发库，需要自己的协程池化技术。

## gevent.threadpool

区别于上面的gevent.pool，这是一个原生线程池模块。


# 其他资料

https://www.cnblogs.com/zcqdream/p/6196040.html