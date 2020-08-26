---
layout: post
title: Python TCP/UDP编程对比

tagline: "Supporting tagline"
category : linux
tags : [python, socket, udp]

---
{% include JB/setup %}

* toc
{:toc}

<hr/>

## 操作模式
我们知道，TCP编程有一个基本的CS模式：CS端的SOCKET存在实质意义上的差别，各有其对应的操作。TCP的模式只有一种：

	S端为`create, setsockopt, bind, listen, accept,(send/recv)`。C端为`create, connect,(send,recv)`。
	是的，tcp下通常我们使用send/recv，read/write，sendmsg/recvmsg，但是不使用sendto/recvfrom。因为tcp建立连接
	的时候双方地址就已经确定了。有些平台下仍然可以使用sendto，但是系统实际上会忽略掉sendto的地址参数。

但是对于UDP来说，没有CS端概念且不止一种模式。

无论UDP还是TCP，虽然一次传输涉及两端地址，但是作为发送端只需要明确自己的目的地址，可以不设置源地址。
对于接收端只要明确自己以哪个地址来接收，接收端不需要也不能设置下一次传输的源地址。

1. 发送接收模式:只需要一边bind。 RECV端:`create, [setsockopt], bind, (recv/recvfrom)` SEND端:`create, [setsockopt], sendto` 

2. 对等模式:两边bind。 一端:`create, bind, sendto/recv/recvfrom` 另一端:`create, bind, recv/recvfrom/sendto`

3. 仿CS模式: 一边connect，另一边bind。C端: `create, connect, (send/recv/sendto/recvfrom)` S端:`create, bind, (recv/send/recvfrom/sendto)`

其实TCP也可以两边都bind，但不是对等模式，因为必然要有一端先connect，因此我们认为TCP只有一种CS模式。

注意在第1与第3中模式里，先发送的一端都没有指定源IP地址，系统会自动选择一个，有时候这个选择的IP并不是我们期望使用的。

第3个模式里，connect并不是真的建立一个链接，而是执行选择源IP、记录目的地址之类的操作。只有在这种模式下，UDP编程才可以使用send而不是sendto，就不用每次都传目的地址了。

一定要先启动接收一端，因为只要接收一端开了端口，发送一端才可能成功发送（UDP不可靠链接，就算对端没开端口也不会有任何异常显示）。

如果一个socket既要发送UDP又要接收UDP，必须先bind然后发送，先发送然后bind会出错，因为发送时实际上会将socket绑定，此时再bind肯定出错。

### UDP广播

发送广播的socket必须先设置(SOL_SOCKET,SO_BROADCAST)选项。

使用模式2不能绑定广播地址，但是模式3可以connect广播地址。

以下实验自我的macbook在所在局域网广播的情况，macbook局域网IP：192.168.31.234。发送与接收通过macbook上的两个python
窗口完成。

test:
1. 发送端不绑定：getsockname得到的是0.0.0.0，但是用tcpdump得到的实际发出去的分组源地址是192.168.31.234

2. 接收端绑定192.168.31.234, 发送端往255.255.255.255、 192.168.31.255发 接收端都收不动

3. 接收端绑定127.0.0.1  发送端往127.255.255.255 255.255.255.255发 接收端都收不到

4. 接收端绑定0.0.0.0 发送端往192.168.31.255 255.255.255.255发可以接收到，往127.255.255.255发则接收不到

可以发现，只要接收端绑定到非0.0.0.0的地址，广播分组都接收不到，这看起来有点奇怪，实际上在windows上并非如此，但在linux也一样。
关于这个的解释我只找到[developweb][0]上的相似问题的一个讨论，其大意是说使用SO_BINDTODEVICE，但我没看出有什么道理可言，且这个选项仅仅linux支持。

## 接收缓冲区工作方式

简单来说，TCP的接收缓冲区是”连续“的，而UDP的接收缓冲区是”离散“的。比如说，发送端发2个分组，其内容分别为"01234"与"56789"。同样使用recv(3)来接收，
UDP读到的是"012"与"567"，然后阻塞，而TCP读到的是"012","345","678","9",然后阻塞。由此可见，recv每次接收从缓冲区消费一个UDP分组，权威资料参考 [这里][1]。
当UDP缓冲区小于要接收的UDP分组的时候，仅仅是丢弃该UDP分组。

接收与发送缓冲区的大小可以通过SO_RCVBUFF与SO_SNDBUFF来设置，但是不能认为这个buf的大小是完全来存储UDP或TCP分组或payload的，实际上可能包含一些数据结构的大小。

发来的分组会存在缓冲区中直到缓存区满，后续的分组会直接丢弃。(TCP因为流量控制机制存在，发现接收缓冲区满了，就不在发送，但我在lo设备tcpdump抓包验证这一点没发现流量控制，只是丢弃而已)

## IO模式

关于TCP通信，我们知道recv返回0，意味着connection broken。而UDP不存在连接，当UDP下recv返回0的时候，意味着收到了一个payload为0的UDP分组，
参考自[stackoverflow][2]。

## 关闭socket

正常关闭TCP后，一段时间内该地址处于TIME_WAIT状态，再次bind会出现Address already use错误。

UDP不存在TIME_WAIT状态，但是kill -9暴力关闭也会导致上面的错误出现。原因是暴力关闭使得内核跳过关闭程序打开的文件描述符(socket)步骤，从而
导致端口处于一个“异常”状态。这时候用SO_REUSEADDR也是没有用的。因此，永远不要用kill -9关闭程序，如果一个程序总是需要kill -9来关闭，那这个程序的设计
比如有问题。

[0]:https://developerweb.net/viewtopic.php?id=5722
[1]:https://www.gnu.org/software/libc/manual/html_node/Receiving-Datagrams.html
[2]:https://stackoverflow.com/questions/12505892/under-linux-can-recv-ever-return-0-on-udp


