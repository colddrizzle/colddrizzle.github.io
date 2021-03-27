---
layout: post
title: python标准库之struct
description: ""
category: python
tags: [struct]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

[doc: struct](https://docs.python.org/zh-cn/3/library/struct.html)基本足够。

这里说下对齐方式与填充字节。

有疑问的主要是`@`字节顺序的按原字节对齐方式。其实这里是中文翻译的问题，英文文档用的
词是“native”，意味着原生的，只不过指的是原生C风格，而不是原字节，原字节是毫无意义的，原字节是既定字节串，不存在
对齐方式。

类型的大小与对齐是俩概念，但在struct模块中是相关的。


使用标准大小，是没有对齐的，使用native（只有`@`才会使用native大小）则会有C语言原生的对齐。

所谓C编译器原生大小指的是编译Cpython的C编译器的大小风格。

但struct模块中定义的类型标准大小基本上与32位机器上的C原生大小一致，为了清晰起见，最好不要使用`@`。当遇到填充字节的时候使用`x`来补位。
一个`x`代表一个字节，`10x`就是10个字节。

```
import struct

# 会有对齐
struct.calcsize("hi")
8

# 没有对齐
struct.calcsize("=hi")
6

# 填充字节
struct.calcsize(=h2xi)
```