---
layout: post
title: 关于C IO库函数缓冲区刷新

tagline: "Supporting tagline"
category : c&cpp
tags : [c, printf, setbuf]

---
{% include JB/setup %}

* toc
{:toc}

<hr/>

printf以及其各种变体是基于输出缓冲区来工作的， 最终调用的是`write`函数，缓冲区是由C函数库来控制的，
并且定义在`FILE`结构体中。

C语言标准规定，缓冲区有[三种工作模式][0]：

	When a stream is unbuffered, characters are intended to appear from the source or at the destination as soon as possible. Otherwise characters may be accumulated and transmitted to or from the host environment as a block.

	When a stream is fully buffered, characters are intended to be transmitted to or from the host environment as a block when a buffer is filled.

	When a stream is line buffered, characters are intended to be transmitted to or from the host environment as a block when a new-line character is encountered. Furthermore, characters are intended to be transmitted as a block to the host environment when a buffer is filled, when input is requested on an unbuffered stream, or when input is requested on a line buffered stream that requires the transmission of characters from the host environment.

默认情况下缓冲区工作在line buffered模式，但可以通过[`setvbuf`][1]函数修改。

通常在C语言程序调用C库函数exit()关闭(main return最后也会调用exit())的时候，exit()会将输出缓冲区内的内容刷新出去。所以当用SIGTERM关闭C语言程序的时候，由于绕过了C语言库函数的exit()，
不会自动刷新输出缓冲区。

标准规定，输出缓冲区的自动刷新完全是[由实现决定的][0]，只有调用`fflush()`才能保证输出缓冲区一定会刷新。但是通常来讲，
输出缓冲区一般会在以下时机刷新：

* 缓冲区满
* 行模式下遇到"\n"。然而[windows系统提供的实现没有行模式][3]
* 调用C库函数exit或者main return
* 调用fflush()

更多参考:[这里][2]、[这里][3]。

[0]:https://stackoverflow.com/questions/39536212/what-are-the-rules-of-automatic-stdout-buffer-flushing-in-c
[1]:https://man7.org/linux/man-pages/man3/setvbuf.3.html
[2]:https://stackoverflow.com/questions/1716296/why-does-printf-not-flush-after-the-call-unless-a-newline-is-in-the-format-strin
[3]:https://stackoverflow.com/questions/61426558/why-does-printf-with-n-still-not-flush-on-windows