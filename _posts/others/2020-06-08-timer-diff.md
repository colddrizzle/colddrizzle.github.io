
timer的工作的方式，在不同的系统环境下是不一样的

## linux
linux posix中timer是依赖信号。
信号向指定线程发送，可以是同一个线程也可以是不同线程。

https://www.jianshu.com/p/aa96876ebabc

## java
Timer 在一个新线程里执行

## js
JS比较奇葩，依赖于event loop，在朱线程空闲时执行，也就是同一个线程。

## python
https://www.jianshu.com/p/403bcb57e5c2