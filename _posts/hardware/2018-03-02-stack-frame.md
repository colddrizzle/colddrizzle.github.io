---
layout : post
category : 编译
tags : [编译,栈帧]
title : C语言下栈帧结构与函数调用过程
---

我们知道，函数调用是通过栈来实现的，那么这个过程具体是如何呢？

以下两篇文章分别讲了c语言下x86与x86-64下的函数栈结构。其中x86使用的cdelc函数调用约定，x86-64使用了windows的64位函数调用约定
，有关函数调用约定参考[汇编基本概念][0]。

[Stack frame layout on x86-64](https://eli.thegreenplace.net/2011/02/04/where-the-top-of-the-stack-is-on-x86/)

[Where the top of the stack is on x86](https://eli.thegreenplace.net/2011/09/06/stack-frame-layout-on-x86-64/)


简而言之，函数调用之前先将参数压栈（x86-64下则先将前几个参数放入寄存器，且是采用自左向右的顺序，剩余的才以自右向左压栈），
然后将返回地址压栈，跳转到被调用函数内，被调用函数将调用函数的帧指针EBP压栈，然后将此时的栈顶（其指向上一个EBP）指针为被调用函数的帧指针，也就是
被调用函数的帧指针指向的栈中位置存放的是调用函数的帧指针。

参数压栈是调用者进行的，在被调用函数是定长参数的情况下，被调用函数指定自己该往EBP之前数几个字节、拿几个参数。

在变长参数的情况下，调用者在编译的时候其实已经确定了要传几个参数了，因此cdelc调用约定中由调用者清理栈，依次实现了对变长参数的支持。
那么被调用者是如何知道有几个参数的呢？其实被调用者不知道，但是C中规定定义可变长参数需要给出最后一个入栈的参数的名字，比如

```brush:c

int func(int param, ...){

}

```

func一般通过param直接或者间接的推算出参数列表的长度与类型。更多可变长参数原理参考[这里](https://www.cnblogs.com/pengdonglin137/p/3345911.html)。


 通常配合`stdarg.h`中的`va_start, va_end, va_arg`几个函数使用。


[资料](https://eli.thegreenplace.net/2011/09/06/stack-frame-layout-on-x86-64/
)主要讲了x86-64下的栈帧结构，与x86基本相同。提到了AMD64 ABI定义的red zone--一种叶子函数的优化。
另外提到了rbp寄存器对于编译器来讲，其实不需要，编译器可以根据rsp来推算，但rsp的随着一个函数体的执行在变化中，因而通常使用一次函数调用内不变的RBP来推算。

看完上面这篇文章要注意：一个过程的栈帧是从EBP到ESP之间的闭区间。EBP指向的当前过程的帧底里保存的内容虽然上一个过程的EBP，
但保存动作是在当前过程内发生的，或者说EBP的内容本来就是由被调用者保证不能修改的。而ESP指向栈顶元素而不是栈顶的下一个可用地址，这就是
为什么说是EBP到ESP的闭区间了。


[这儿](https://www.cnblogs.com/bangerlee/archive/2012/05/22/2508772.html)结合gdb实际验证了函数调用栈的结构。
注意该例是在x86-64体系下，叶子函数利用了`red zone`，注意leave指令的语义：恢复调用函数的rsp与rbp寄存器。


更多资料：

https://en.wikipedia.org/wiki/Call_stack

https://www.cnblogs.com/samo/articles/3092895.html

https://blog.csdn.net/Hello_Sue/article/details/79515183

[0]:/2020/06/30/asm-basic

