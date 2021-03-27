---
layout: post
title: http三方库之requests
description: ""
category: python
tags: [requests]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

https://www.cnblogs.com/lanyinhao/p/9634742.html

requests是使用Apache2 licensed 许可证的HTTP库。

用python编写。

比urllib2模块更简洁。

Request支持HTTP连接保持和连接池，支持使用cookie保持会话，支持文件上传，支持自动响应内容的编码，支持国际化的URL和POST数据自动编码。

在python内置模块的基础上进行了高度的封装，从而使得python进行网络请求时，变得人性化，使用Requests可以轻而易举的完成浏览器可有的任何操作。

现代，国际化，友好。


-------------------------------------
python中处理http的库有：

标准库有：
http.client

urllib

urllib2

其中urllib2简化了urllib。在python3里面urllib2取代了urllib。
http.client最底层。

三方库有：

requests地位等同于urllib2。