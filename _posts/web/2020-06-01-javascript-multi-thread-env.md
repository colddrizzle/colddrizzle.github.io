---
layout: post
title: javascript多线程环境
description: ""
category: web
tags: [javascript,language]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

纯解释器

浏览器

nodejs


关于event loop：

https://stackoverflow.com/questions/7575589/how-does-javascript-handle-ajax-responses-in-the-background/7575649#7575649

https://developer.mozilla.org/en-US/docs/Glossary/Main_thread

https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/EventLoop

https://html.spec.whatwg.org/multipage/webappapis.html#event-loops

值得一提的是html5规范与js规范里都提到了event loop，实际上在实现中它俩是同一个loop。

html规范：https://html.spec.whatwg.org/multipage/index.html

dom规范：https://www.w3.org/TR/dom41/

关于任务、微任务：
https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules/?utm_source=html5weekly

https://juejin.im/post/5b498d245188251b193d4059#heading-8

https://html.spec.whatwg.org/multipage/webappapis.html#event-loops


关于多个script标签：
https://segmentfault.com/q/1010000019212260 
这里一个答案提到单个script存在变量提升而多个script之间不存在变量提升，以及多个script之间共享全局变量。
答主认为js线程，ui线程两个线程导致的。我不认同这种观点，可以肯定的是只有一个线程。一个线程多次解析script块，
解析时传入同一个外部命名空间也可以做到。

关于UI线程与JS线程：
https://www.zhihu.com/question/264253488
这里提到用css验证存在俩线程，评论里给出了反对意见。我依然认为不存在JS线程这个东西。一个网页就是一个线程，负责UI、网络、JS、交互等所有事情。
JS要么是UI的一部分，要么是交互的一部分，不存在单独的JS线程。JS线程与UI线程都是网页主线程（当然不考虑webworker的情况下）。


