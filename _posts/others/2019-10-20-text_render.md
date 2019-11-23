---
layout: post
title: 字体渲染相关
description: ""
category: 其他
tags: [text render]
---
{% include JB/setup %}

关于这方面最好的资料其实在[harfbuzz官网][0]上，本文就是对官网上的一些资料的简单笔记。
大致了解下字体渲染的问题就好了。

## 渲染的大致过程

一般情况下，应用程序并不直接渲染字体,而是将文本的codepoint数组交给GUI框架，GUI框架也不拆分codepoint序列，将其交给渲染引擎
，渲染引擎决定哪些字节构成一个字符，然后从字体文件中以codepoint、粗体、斜体等作为条件查出字模，然后应用间距等设置进行渲染。GUI框架之所以不拆分codepoint，因为组合字存在，gui框架根本无法确定哪些codepoint构成一个字符。


## 组合字导致字体渲染复杂

字体渲染是一个很复杂的[东西][1]，组合字只是其中之一。
unicode里有所谓的组合字的概念，也就是多个codepoint对应一个组合起来的字模，那这个组合字模各个部分的位置
就要由渲染引擎来确定。


## 工具链
字体渲染有一天完整但是互相重叠的工具，harfbuzz处于最顶层。关于工具链参考[这儿][2]a
我只了解过两个：
FreeType用来读取字体文件。
HarfBuzz用来进行渲染。此外，harfbuzz还提供了两个小工具，[hb-view与hb-shape][3]，其实工具的help文档要比网页文档清晰的多。hb-view可以直接将文本甚至直接指定codepoint序列渲染成图片来查看渲染效果。

关于pango与harfbuzz的区别参见[这里][4]

[0]:https://www.freedesktop.org/wiki/Software/HarfBuzz/
[1]:https://docs.google.com/presentation/d/1x97pfbB1gbD53Yhz6-_yBUozQMVJ_5yMqqR_D-R7b7I/present
[2]:http://behdad.org/text/
[3]:https://harfbuzz.github.io/utilities.html#utilities-command-line-tools
[4]:http://mces.blogspot.com/2009/11/pango-vs-harfbuzz.html