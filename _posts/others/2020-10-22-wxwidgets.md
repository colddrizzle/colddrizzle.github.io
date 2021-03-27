---
layout: post
title: 关于wxWidgets的资料与笔记
description: ""
category: 其他
tags: [wxWidgets, gui]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

# 起步

在线手册：
https://docs.wxwidgets.org/

基本概念：
https://docs.wxwidgets.org/3.1.4/page_topics.html

例子：
https://docs.wxwidgets.org/3.1.4/page_samples.html

例子的源码都附在了wxwidgets的源码包里面了，3.1.4版本下，例子的工程文件可以在vs2010中打开。

wxwidgets源码包里还有个demos目录，也是例子，比较综合复杂些，一样可以在vs2010中打开。

wxwidgets社区自己的wiki:
https://wiki.wxwidgets.org/Guides_%26_Tutorials#wxWiki_Guides

其实以上官方的文档还是不够亲民，反而下面的tutorial比较容易理解。

重要的tutorial：
http://zetcode.com/gui/wxwidgets/

实际上这个tutorial也在官方wiki：https://wiki.wxwidgets.org/Guides_%26_Tutorials#Tutorials 的列表里，**列表中还有很多其他人写的tutorials。**



国内博客资料主要参考下面这个，包括安装、编译、如何使用VS\Codeblocks起工程等等，这是一个系列博客，大概六篇，很有用。

http://www.cnzui.com/archives/942

编译用的其中命令编译的方法，非常简单，一气呵成。


下面这两个参考没有使用，但资料写的挺正经的，先放这儿。

使用VS编译的另一个参考：http://blog.sina.com.cn/s/blog_a459dcf50101h1vf.html

使用codeblocks起工程一个参考：https://www.oschina.net/translate/introduction-to-wxwidgets-gui-programming

自己在编译3.1.4版本过程中碰到一个链接失败的问题，编译动态库有这个问题，静态库没有这个问题。
最终是根据 https://blog.csdn.net/moqj_123/article/details/38322415 这里的方法，重命名掉一个旧版本的cvtres.exe解决了。

# 原理与概念相关

这篇总结的还可以，也放这儿：https://www.cnblogs.com/Long-w/p/9620147.html

## 各种窗口
wxWindow、wxFrame、wxPanel的区别

## 各种DC
https://docs.wxwidgets.org/3.0/overview_dc.html

https://wiki.wxwidgets.org/Guides_%26_Tutorials#wxWiki_Guides 下的关于DCs的guide

以上两个都很有用。


需要注意wxClient与wxClientDC没有什么关系。

需要注意的是paintdc与clientdc的限制条件。

正常来讲，绘画应该在EVT_PAINT的事件处理函数里面，但是鼠标事件处理函数里面有时候也要进行绘画，这两个
绘画处理函数的上下文不一样，在wxwidgets里要用不同的dc。paintdc要用在EVT_PAINT事件处理函数中，而非evt_paint的事件处理函数要用
clientdc。

## 擦除

## 绘图的大致原理与一般方法

onpaint与erase会自动触发吗？

erase那个例子很有用

有没有层的概念？

前景与背景如何区分？

所谓的闪烁与双缓冲区？

https://docs.wxwidgets.org/2.8.12/wx_wxpaintevent.html#wxpaintevent
wxRegionIterator GetUpdateRegion
更新区域？只更新一小部分？

https://docs.wxwidgets.org/2.8.8/wx_wxidleevent.html#wxidleevent

以鼠标划线为例，说明绘图的一般方法。

## 3D怎么玩