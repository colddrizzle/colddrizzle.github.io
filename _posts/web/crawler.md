---
layout: post
title: 一个简易爬虫的设计与实现
description: ""
category: web
tags: [web, crawler]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

本章不参考任何爬虫原理来自由设计并实现一个简单的爬虫，也是对《架构整洁之道》的一次实践。

# 爬虫需求

一个爬虫读入种子url，根据一定的可定制的策略，将种子url可达（依策略而定）
的url指向的页面内容（或部分内容）下载下来，并存储。

## 需求细化

上面的需求是非常简单的，同时也是我们见到的需求。但是
我们必须规范化、细化它，才能方便开发。

一定的可定制的策略：广度优先、深度优先、某一个站点、指定深度、html文件、图片链接、音频视频等等。

无论何种策略都应该避免存在环路。


下载页面内容（或部分页面内容）：页面内容已经爬取下来的，页面内容就是个文本文档。所谓的部分页面内容，应该是
指的页面内链接到的资源，而这种资源也应该是URL定位的。

这里的问题是，我们的目标可能仅仅是页面的某个div下的文本内容或者某个ul标签下的图片列表。

# 业务流程分析

分析1：种子url只是一些起点，在爬取的过程中会不断的有新的url被发现。url需要被统一的管理起来。后续访问那个url也要管理起来。

分析2：对一个确定url的爬取分析，可以称之为一个任务。一个任务启动后，必须跟踪它，若任务失败重试或放弃。

分析3；在爬取到页面，分析新的url的时候，并不是所有的url我们都会用到。

分析4：爬取到页面后，使用内容摘取器将关心的内容保存下来。有时候爬取的不是页面，比如是图片，内容摘取器负责将图片保存下来。
	也就是说，内容摘取器需要用户自己定制。

分析5：爬虫的任务都被跟踪后，如果整个状态持久化下来，就可以任意停止爬虫、重启爬虫。

# 设计

需求既然分析完了，开始设计阶段。须记住，所谓设计就是对业务流程的尽可能优化。

我们可以从业务流程中抽取出如下的实体：


1. 种子url
2. url管理：收集、分派
3. 任务分派以及跟踪
4. 目标筛选
5. 内容摘取
6. 持久化部分：url持久化：任务状态持久化：摘取内容持久化
7. 以及作为基础的-Http通信部分
8. 任务执行


根据《整洁结构之道》的分层原则：距离输入输出越远，层级越高。

可以确定1、6、7层级最低。

其次4、5。4,5都依赖于8。

内容摘取后需要持久化

层级最高2、3、8。并且3依赖于2。8依赖于3。
以为这3定义执行器的外貌。（但其实python没有没有这种编译期依赖）

4、5需要依赖于8。


# 定义边界接口 

我们要定义如下类的详细接口：

```brush:python
# 种子
class Seed(object):
	def __init__(self,urls):
		if urls 
		this.urls = urls
	@property
	def urls(self):
		return this.urls

# url管理
class URLManager(object):
	def __init__(self):
		pass 

# 任务分派以及跟踪
class TaskManager(object):
	def __init__(self, seed, strategy, picker):
		pass
	def execute(self):
		pass

# 任务执行
class Executor(object):
	def __init__(self):
		pass

	def add(worker):
		pass

# 目标筛选
class Selector(object):
	def accept(self,url):
		pass

# 内容摘取
# 由用户实现
class Picker(object):
	def feed(self, data):
		pass
	def get_result(self):
		pass

# 持久化
class Persistence(object):
	pass

# 通信
class Communication(object):
	pass

``` 
根据依赖关系，从高层到低层设计接口。

低层满足高层要求，低层依赖于高层需求。

注意，依赖关系我们已经理清了，设计边界类的时候从最重要的模块开始，也就是全局管理模块

全局管理模块不依赖于任何其他模块，相反它向其他模块提要求，其他模块依赖于其提的要求而设计。

因此我们不应该考虑其他模块如何影响全局管理模块设计实现，而应该考虑全局管理模块如何向其他模块提要求（定义边界接口）。

**Seed：**

Seed应该是一个列表，并且是http或https的url，不能为空。

**URLManager:**

按照一定的策略管理url。主要负责收集url，并向外提供后续可以访问的url。

**TaskManager：**
派发任务。跟踪任务的执行情况，必要时重启任务。

**TaskExecutor:**
下载，解析，报告。

**Selector:**

**Picker:**

**Persistence:**
名字上添加时间戳后保存到指定路径。

**Communication:**

**Main:**
用于将上面模块串起来。

经过上面的的分析，各模块直接的边界接口定义如下：
```brush:python
# 种子
class Seed(object):
	def __init__(self,urls):
		if urls 
		this.urls = urls
	@property
	def urls(self):
		return this.urls

# url管理
class URLManager(object):
	def __init__(self):
		pass 

	def put(self, urls):
		pass
	def get(self, n):
		pass

# 任务分派以及跟踪
class TaskManager(object):
	def __init__(self, seed, strategy, picker):
		pass
	def get(self):
		pass
	def complete(self, url):
		pass

# 任务执行
class Executor(object):
	def __init__(self):
		pass

	def add(worker):
		pass

# 目标筛选
class Selector(object):
	def accept(self,url):
		pass

class Picker(object):
	pass


# 内容摘取
# 由用户实现
class Picker(BasePicker):
	def feed(self, data):
		pass
	def get_result(self):
		pass

# 持久化
class Persistence(object):
	pass

# 通信
class Communication(object):
	pass

```

我们的设计没有考虑是单进场多线程或是分布式，但应该为此留下余地。我们看下我们的设计是否为此留下来余地？

?????

## 扩展到分布式


# 实现

[git 项目](https://github.com/colddrizzle/crawler)

## 测试驱动开发


## 部分实现

实现的部分难点：

任务的生命周期管理：

要求可重启，需要持久化。
使用增量日志来记录状态。

重启的时候，指定日志。指定日志后的逻辑如何？



要求状态的一致性，哪些状态的一致性？
一个任务要么未启动、要么进行中、要么已完成。
凡是进行中的下次总是重新开始。


在实现中，其中4是5的一部分。5分为内置的内容摘取与自定义的内容摘取。
内置的内置的内容摘取的一个环节就是应用selector



