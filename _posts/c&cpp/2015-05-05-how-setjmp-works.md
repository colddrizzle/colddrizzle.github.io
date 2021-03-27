---
layout: post
title: setjmp/longjmp原理

tagline: "Supporting tagline"
category : c&cpp
tags : [setjmp, longjmp]

---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 原理
我们使用的是x86-64架构上的源码，因此了解setjmp与longjmp源码之前需要对x86-64上的函数调用约定以及函数栈结构略有了解。

[setjmp][1]: 简单来说，将setjmp()函数的返回地址以及其他一些寄存器存到jmp_buf中

[longjmp][2]: 简单来说：将jmp_buf中保存的"setjmp()函数的返回地址"作为longjmp()函数自己的返回地址。于是执行ret指令之后，longjmp()函数返回到“调用setjmp()函数”处（准确来说是“调用setjmp()函数”的下一条指令的地址），并通过eax传回返回值。

注意setjmp并不会保存栈内容，也不允许自定义栈，这点不同于ucontext系列函数。虽然getcontext也不会保存栈内容，但是makecontext却允许自定义栈并制定入口函数。
这就给自定义用户级线程、带栈协程留下了空间。

## 其他资料

[here][3]

[here][4]

## 与goto的区别

goto是局部跳转，即仅能在一个函数内跳转。而setjmp和longjmp 可以在栈上跳过若干调用桢，返回到当前函数调用路径上的一个函数中。

无论goto还是longjmp，都是糟糕的编程实现，非迫不得已不要使用。

## 在信号处理函数中使用longjmp

https://blog.csdn.net/lishanmin11/article/details/77800850


[1]:https://github.com/bminor/glibc/blob/master/sysdeps/x86_64/setjmp.S
[2]:https://github.com/bminor/glibc/blob/master/sysdeps/x86_64/__longjmp.S
[3]:https://www.cnblogs.com/maowen/p/5070002.html
[4]:https://blog.csdn.net/stillvxx/article/details/17993645
