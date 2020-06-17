---
layout: post
title: python标准库之socket
description: ""
category: python
tags: [python lib, socket]
---
{% include JB/setup %}

* toc
{:toc}

<hr />
本文是python标准库socket与[Socket Programming HOWTO][0]的简单笔记。

## socket
HOWTO提到socket在不同的上下文里语义存在微妙的区别。客户端socket就像是一场电话通话的一个终端。
而服务端socket更像是接线员。

## creating a Socket

创建serversocket的时候，最后调用listen指定了最大排队长度
```
serversocket.listen(5)
```

这个排队长度是什么意义呢?
参考[这里][1]和[listen man][2]，在unix系OS中这个参数被称为backlog，这些资料大意是讲该backlog的意义在不同OS、不同版本中是不同的
。但在linux2.2之后，backlog指的是complete connetction queue的长度。TCP建立连接需要三次握手，linux中存在两个队列来存储不同状态的链接。
当发起端的SYN被OS收到后，将其存放入SYN queue也就是incomplete connection queue中，而完成三次握手之后，则将其转入accept queue也就是complete connection queue中。当accept queue不为空的时候，accept调用就会立刻从中取出一个connection返回。由此可见，只要accept函数调用的频次足够快，accept queue就不会满。

这告诉我们不要在accept循环线程里处理业务逻辑，而应该将其交给其他线程。另外无法创建或者获得新线程太慢也会导致accept循环变慢，从而导致拒绝连接。

[listen man][2]还提到了修改SYN queue的方法：The maximum length of the queue for incomplete sockets can be set using /proc/sys/net/ipv4/tcp_max_syn_backlog. 

## using a socket
HOWTO提到有两组用于通信的操作：`send\recv`与`read\write`。二者的区别在于后者像读写文件那样操作socket，存在一个文件缓存区，而前者是直接读写网络缓冲区。
文件缓冲区未满之前不会真正进入消息发送阶段，因此调用`write`之后还要调用`flush`才能确保。

	网络缓冲区与文件缓冲区深挖：网络缓冲区位于哪儿？或者说网络缓冲区被网卡支配吗

因为`send\recv`是操作的网络缓冲区，因此一次读写的数据量可能跟你期望的不一样，因此需要我们自己检查读写了多少数据。

当`recv`接收到0个字节或者`send`发送了0个字节的时候，意味着连接被破坏了（connection broken）。这很好理解，`send\recv`都是阻塞操作，其二者的正常行为分别是
”一直等待直到读到点什么“和”一直发送直到发送点什么“，绝不会返回0。若返回了0，说明有错误发生。

有错误发生并不意味着不能再进行任何通信了，TCP可以单向关闭从全双工模式进入单工模式。比如客户端可以调用一个指定关闭方式`shutdown`而不是`close`。下面会再提到`shutdown`。

另外注意socket编程是面向TCP以及UDP的，其关心的是一个TCP或UDP分组的传送，每次调用`send\recv`都能保证发送或者接受几个完整的分组。但这些分组携带的信息在上层应用意义上是否完整就不关心了。用户自己有责任来处理消息完整性。
通常有如下三种方法：

* 固定长度
* 约定分隔符
* 消息开头告知消息长度

HOWTO中认为这三种方法从上往下依次变好，最好使用第三种。这里面有两点需要注意：
* 用C语言处理的时候注意字符串中间包含`\0`的情况。

	[字符'0'和'\0',及整数0的区别](https://www.jianshu.com/p/011e21a20833)

* 长度标识大于1个字节的时候，一次`recv`未必能够返回完整的长度标识（也就是recv有可能只读回来一个字节）。

## binary data
HOWTO提到了两点，第一传送二进制数据的时候要用`hton\ntoh`系列函数转换字节序。第二32位时代传送二进制可能要比传送字符串的数据长度要长。

关于第一点，我们来理解下为什么需要调用这几个函数。要理解这一点，首先需要厘清什么是二进制数据。我以为这个说法并不严格，计算机里全是二进制数据。
二进制数据的解释取决于其类型，如果是字符串类型的话，字符串是有其编码的，编码能唯一确定一串文字的字节序，也就是字符串字节序与平台无关，因此不需要调用
`hton\ntoh`系列函数。而数字数据其类型
并不能决定其字节序，比如整型只是约定其有4个字节，但并未约定其字节序，因此大小端机器上同一个二进制数字的解释会有差异。因此需要调用`hton\ntoh`系列函数来通过网络字节序来转换。由此也可以看出，调用这几个函数是面向解释的，是为了解释清楚二进制数据的正确含义。

关于第二点，我想作者混淆了字符0与数字0。在英文环境下，ascii编码的字符0确实比数字0长度短。

## disconnecting

这节主要讲tcp的协商关闭，也就是`shutdown`。关于`socket.shutdown`，标准文档如下：

	Shut down one or both halves of the connection. If how is SHUT_RD, further receives are disallowed. If how is SHUT_WR, further sends are disallowed. If how is SHUT_RDWR, further sends and receives are disallowed. Depending on the platform, shutting down one half of the connection can also close the opposite half (e.g. on Mac OS X, shutdown(SHUT_WR) does not allow further reads on the other end of the connection).

## when sockets die

当TCP的一端没有调用close而直接关闭的时候，另一端会等待很长很长时间才会放弃这个连接（多长时间？）。如果使用了线程的话，那这个线程基本上就死掉了。
这个线程并不会占用很多资源，仅仅是阻塞在一个连接上（OS端没办法关闭这个socket吗？）。不要尝试关闭这个线程，因为同一进程内线程共享内存，杀死这一个线程可能把你的整个进程数据毁掉。

TCP一端没有调用close关闭常见情景是客户端直接断电关机、异常死机等。那对一个有着成千上万连接的服务器来说，这种情况导致线程阻塞下去是无法容忍的，
服务器是怎么处理的呢？

## non-blocking sockets

在python中，可以使用`socket.setblocking(0)`来讲socket设置为非阻塞模式。设置后主要区别在于`send recv connect accept`调用后会立刻返回。

一般来讲，非阻塞模式需要配合`select`来使用。

HOWTO里提个一个事情令人费解：

One very nasty problem with select: if somewhere in those input lists of sockets is one which has died a nasty death, the select will fail. You then need to loop through every single damn socket in all those lists and do a select([sock],[],[],0) until you find the bad one. That timeout of 0 means it won’t take long, but it’s ugly.

第一个问题什么叫做a nasty death，第二个为什么select会失败，select第三个参数不就是来处理错误的吗？对于这些问题[stackoverflow上的一个问题][3]的评论里对这个HOWTO也表达了怀疑的态度。我认为HOWTO上面的逐个检查的说法不靠谱。

## 与socket相关的几个标准库

### ssl

待补充

### asyncore

待补充

### asynchat

待补充

[0]:https://docs.python.org/2.7/howto/sockets.html
[1]:http://veithen.io/2014/01/01/how-tcp-backlog-works-in-linux.html
[2]:https://linux.die.net/man/2/listen
[3]:https://stackoverflow.com/questions/19795529/python-troubles-controlling-dead-sockets-through-select