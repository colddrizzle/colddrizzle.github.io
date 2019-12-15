---
layout: post
title: python标准库之argparse
description: ""
category: python
tags: [python, argparse]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

[argparse tutoral][0]

[argparse api reference][1]

本文是上述资料的一个简单笔记。

## 参考资料

## 两种参数

参数分为两类：位置参数与可选参数。位置参数的没有名字。可选参数有名字。

位置参数必须按顺序给出，强制要求。可选参数必要的时候通过`-`或`--`指定名字给出，然后跟上参数的值。

## 指定参数类型

两种参数都可以通过type指定类型，否则按照string处理。

## 参数指定范围

通过`choices=[...]`指定参数的值得范围。
位置参数与可选参数都可以指定范围。

## 参数指定默认值

通过default指定默认值。

## 可选参数

### 指定action

* store_true
* count

### 转化为flag

可以将可选参数转为FLAG，从而省去指定可选参数的值。转换的方式由action指定。

### 指定多个值

可选参数只有一个值，若是多个值，必须用双引号。参数类型作为string，需要自己拆分、转换类型。

### 处理冲突

https://docs.python.org/2/howto/argparse.html#conflicting-options

## 如何给应用设计参数

因为位置参数必须给出，所以首要是确定位置参数。


[0]:https://docs.python.org/2/howto/argparse.html#id1
[1]:https://docs.python.org/2/library/argparse.html