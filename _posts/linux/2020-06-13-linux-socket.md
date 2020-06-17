---
layout: post
title: Linux Socket

tagline: "Supporting tagline"
category : linux
tags : [socket]

---
{% include JB/setup %}

* toc
{:toc}

<hr/>

本篇介绍linux socket编程，更侧重于理清概念。

## socket概念
socket的英文本意是插座、插口，在操作系统中，socket是应用程序间进行通信的接口。
很多资料包括wiki将socket说成是使用IP协议为通信基础的网路套接字，在某些环境下确实是这样的，比如python。

但linux下显然不是这样，socket的函数签名如下
```
int socket(int domain, int type, int protocol);
```
按照[linux man socket(2)][0]的说法：

* The domain argument specifies a communication domain; this selects the protocol family which will be used for communication.

* The socket has the indicated type, which specifies the communication semantics.

* The protocol specifies a particular protocol to be used with the socket. Normally only a single protocol exists to support a particular socket type within a given protocol family, in which case protocol can be specified as 0. However, it is possible that many protocols may exist, in which case a particular protocol must be specified in this manner. The protocol number to use is specific to the 'communication domain' in which communication is to take place;

显然linux下的socket支持多种地址族协议族，绝不是绑定仅仅到IP协议的。

关于第三个参数可以参考[linux man protocols(5)][2]，里面提到存在一个文件`/etc/protocols`。该文件第一行为
```
ip	0	IP		# internet protocol, pseudo protocol number
```
可见0是一个假的协议号码，与上面说的一致，通常用来指代特定domain与type下唯一的那一个协议。

## 协议族vs地址族
来自[网络][1]：

我们在看Linux网络编程相关代码时会发现PF_XXX和AF_XXX会混着用，他们俩有什么区别呢？以下内容摘自《UNP》。
AF_前缀表示地址族（Address Family），而PF_前缀表示协议族（Protocol Family）。历史上曾有这样的想法：单个协议族可以支持多个地址族，PF_的值可以用来创建套接字，而AF_值用于套接字的地址结构。但实际上，支持多个地址族的协议族从来就没实现过，而头文件`<sys/socket.h>`中为一给定的协议定义的PF_值总是与此协议的AF_值相同。

## domain、type、protocal、操作方法
[linux man socket(2)][0]列出了所支持的domain、type。

关于domain，我们只关心三种：
* AF_UNIX
* AF_INET
* AF_PACKET

关于AF_UNIX，其是基于socket的框架上发展出一种IPC机制，就是UNIX Domain Socket。虽然网络socket也可用于同一台主机的进程间通讯（通过loopback地址127.0.0.1），但是UNIX Domain Socket用于IPC 更有效率及可靠 ：
* 不需要经过网络协议栈
* 不需要打包拆包、计算校验和、维护序号和应答等，可靠性更强
* UNIX Domain Socket传输效率比通过loopback地址快将近一倍

AF_INET就是IPv4协议族。当然也有AF_INET6，略过。

AF_PACKET，linux man packet(7)的描述是：Packet sockets are used to receive or send raw packets at the device driver (OSI Layer 2) level. They allow the user to implement protocol modules in user space on top of the physical layer.

如果说AF_INET是关于IP层以及其之上的协议通信的话，那AF_PACKET就是链路层以及其之上的协议通信。
但与AF_INET网络层确定是IP协议不同的是，AF_PACKET的链路层协议是不确定的，有以太网、802.2、802.3等。
SOCK_RAW对应的是原生的链路层帧。需要注意的是，链路层协议是硬件协商决定的，在只支持以太网的硬件上收发802.3
可能会出错，同样，即使使用SOCK_RAW来接收，硬件依然能正确解析得到sockaddr_ll地址。

(AF_INET, SOCK_RAW)与(AF_PACKET, SOCK_RAW, ETH_P_IP)的区别在于，后者是接收指定网卡上的所有IP包。而前者是接收给定IP地址上的IP包。

通常还有一个AF_ROUTE用来通过socket来操纵内核中的路由表，看起来有点奇怪，但确实是这样，有关资料可参考[这里][4]和[这里][5]。

但需要注意的是linux支持的type取决于你所用的domain。每种domain下支持的type可以参考[linux man socket(2)][0]。至于我们上面关系的三种domian，有

* AF_UNIX --- SOCK_STREAM SOCK_DGRAM SOCK_SEQPACKET
* AF_INET --- SOCK_STREAM SOCK_DGRAM SOCK_RAW SOCK_PACKET。通常他们对应TCP、UDP、IP、链路层帧。linux man socket(2)提到SOCK_PACKET已经被废弃，取代以AF_PACKET
* AF_PACKET --- SOCK_DGRAM SOCK_RAW 分别对应带有特定类型帧头的链路层（ARP、802等）与原生链路层


指定domain后所对应的地址也不一样。
* AF_UNIX
```
// un指unix
struct sockaddr_un {
    sa_family_t sun_family;               /* AF_UNIX */
    char        sun_path[UNIX_PATH_MAX];  /* pathname */
};
```

* AF_INET
```
// in指inet
struct sockaddr_in {
    sa_family_t    sin_family; /* address family: AF_INET */
    in_port_t      sin_port;   /* port in network byte order */
    struct in_addr sin_addr;   /* internet address */
};
```

* AF_PACKET
```
// ll指link layer
struct sockaddr_ll {
    unsigned short sll_family;   /* Always AF_PACKET */
    unsigned short sll_protocol; /* Physical layer protocol */
    int            sll_ifindex;  /* Interface number */
    unsigned short sll_hatype;   /* ARP hardware type */
    unsigned char  sll_pkttype;  /* Packet type */
    unsigned char  sll_halen;    /* Length of address */
    unsigned char  sll_addr[8];  /* Physical layer address */
};
```

另外操作方法取决于你所用的domain与type。[linux man socket(2)][0]提到：

Sockets of type SOCK_STREAM are full-duplex byte streams, similar to pipes. They do not preserve record boundaries. A stream socket must be in a connected state before any data may be sent or received on it. A connection to another socket is created with a connect(2) call. Once connected, data may be transferred using read(2) and write(2) calls or some variant of the send(2) and recv(2) calls. When a session has been completed a close(2) may be performed. Out-of-band data may also be transmitted as described in send(2) and received as described in recv(2).

SOCK_STREAM类型必须先调用connect建立连接。

SOCK_DGRAM and SOCK_RAW sockets allow sending of datagrams to correspondents named in sendto(2) calls. Datagrams are generally received 
with recvfrom(2), which returns the next datagram along with the address of its sender.

数据报与原生类型需要使用sendto与recvfrom。

关于send\sendto\sendmsg的区别还可以参考[linux man send(2)][3]。

上面只是一般性的描述，具体支持或不支持的方法还要从linux man socket(2)中查阅具体domain。我们关心的三种如下：

* AF_UNIX 不支持 send\recv，支持sendmsg\recvmsg\sendto\recvfrom
* AF_INET 几乎支持所有方法，但根据type有区别。
* AF_PACKET sendto\sendmsg

bind()绑定地址方法：
* 指定IP，任意端口 将端口设置为htons(0)
* 指定端口，任意IP 将地址设置为htonl(INADDR_ANY)
* 绑定到任意地址 将上面结合起来

## setsockopt函数

socket是面向多种协议多种地址族的，所以很容易理解socket选项的设置是分层（分类）来进行的，所以setsockopt有个参数level。
各种选项并非都是布尔型，因此需要传入参数确定其值。

通常对Socket本身设置选项level为SOL_SOCKET。对其他任意协议设置选项level为协议号码。具体参考[linux man setoptsock][6]。

    关于缩写：   SOL_* 指的是Socket Option Level
                SO_*  指的是Socket Option

SOL_SOCKET级别常见的有：https://blog.csdn.net/u010144805/article/details/78579771

TCP编程常见的有

IPSec相关

TLS相关

## 疑问
### Q1
按照linux man packet(7)的说法，SOCK_RAW packets are passed to and from the device driver without any changes in the packet data. When receiving a packet, the address is still parsed and passed in a standard sockaddr_ll address structure. When transmitting a packet, the user supplied buffer should contain the physical layer header.

上面提到物理层头，不是链路层头吗？

AF_PACKET中SOCK_RAW既然允许构建原生以太帧的话（用户需要自己提供物理层头）,上面提到接收端还是将其解析到标准sockaddr_ll结构中，既然帧机构自定义的话，
这个解析怎么能正确进行呢？

## 例子
AF_PACKET：

https://www.cnblogs.com/dapaitou2006/p/6502195.html

https://www.programcreek.com/python/example/50987/socket.AF_PACKET

AF_UNIX:

https://blog.csdn.net/sandware/article/details/40923491

https://blog.csdn.net/weixin_39258979/article/details/80931464


[0]:https://linux.die.net/man/2/socket
[1]:https://www.cnblogs.com/developing/articles/10979088.html
[2]:https://linux.die.net/man/5/protocols
[3]:https://linux.die.net/man/2/send
[4]:https://www.linuxjournal.com/article/7356?page=0,0
[5]:https://www.cs.cmu.edu/~srini/15-441/F01.full/www/assignments/P2/htmlsim_split/node20.html
[6]:https://linux.die.net/man/2/setsockopt
