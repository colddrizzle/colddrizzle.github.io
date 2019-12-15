---
layout: post
category : 其他
tagline: "Supporting tagline"
tags : [dpi, ppi, pt, px, dot]
title : c11的内存模型
---

{% include JB/setup %}

* toc
{:toc}

<hr />

c11的内存模型与c++类似，其实是对不同架构的硬件层面内存模型的一个包装。比如可以明显看到
intel下提供的三种内存屏障的影子。

关键是理解为什么对同一个变量同一个线程的读写操作还要知道内存模型，甚至读与写不同的模型，如何理解读屏障
与写屏障的作用。

lock与读写屏障一样吗

lfence有什么用

-----------------------------
一些术语：
NT store =  Non-temporal store指的是绕过缓存直接写内存 https://blog.csdn.net/fengjingge/article/details/51813886
WB = Write buffer
WC = Write Combine
WB = Write back

一些有关这些术语的东西：
https://www.xuebuyuan.com/414789.html
https://stackoverflow.com/questions/32681826/does-sfence-prevent-the-store-buffer-hiding-changes-from-mesi

------------------------------

c11的内存模型太复杂了，先略过，先只用seq—cst。或者用原子变量，根据
https://preshing.com/20120612/an-introduction-to-lock-free-programming/
这里的说法，C++使用原子变量类似于java使用volatile

https://preshing.com/20120913/acquire-and-release-semantics/

https://en.cppreference.com/w/cpp/atomic/memory_order

https://stackoverflow.com/questions/40409297/does-lock-xchg-have-the-same-behavior-as-mfence

https://stackoverflow.com/questions/37452772/x86-64-usage-of-lfence

https://stackoverflow.com/questions/27595595/when-are-x86-lfence-sfence-and-mfence-instructions-required

https://stackoverflow.com/questions/56705436/how-can-i-experience-lfence-or-sfence-can-not-pass-earlier-read-write

https://stackoverflow.com/questions/20316124/does-it-make-any-sense-to-use-the-lfence-instruction-on-x86-x86-64-processors

https://software.intel.com/en-us/forums/intel-moderncode-for-parallel-architectures/topic/304284


https://stackoverflow.com/questions/39053600/does-standard-c11-guarantee-that-memory-order-seq-cst-prevents-storeload-reord

-----------------------------
关于C、C++下无锁编程的一些（该博客资源真不错）

https://preshing.com/20120612/an-introduction-to-lock-free-programming/

https://preshing.com/20120913/acquire-and-release-semantics/

https://preshing.com/20120522/lightweight-in-memory-logging/