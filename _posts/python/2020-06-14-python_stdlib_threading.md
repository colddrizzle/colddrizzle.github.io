---
layout: post
title: python标准库之threading
description: ""
category: python
tags: [python lib, threading]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

本篇只是Python标准文档的简单笔记。

## thread\threading
python标准库里提供了thread与threading两个lib，threading是thread的上层封装，
一般情况下我们应该使用threading模块。

## 个别方法
threading.settrace():threading模块创建的每个线程都会调用sys.settrace()

threading.setprofile():threading模块创建的每个线程都会调用sys.setprofile()

sys.setrace()与sys.setprofile()都是线程之间独立的。所以需要给每个线程都安装相应的方法。
也因此，sys.setprofile()没有办法捕捉多线程之间上下文切换信息，所以多线程分析时不要用sys.setprofile()

那如何分析多线程上下文切换次数呢

