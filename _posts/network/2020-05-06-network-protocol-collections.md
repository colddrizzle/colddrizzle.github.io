---
layout: post
title: 网络协议汇总

tagline: "Supporting tagline"
category : network
tags : [mac address]

---
{% include JB/setup %}

* toc
{:toc}

<hr />

各种协议、分层。每个协议的wiki至少看一遍。

比如应用层协议有哪些

SSL是哪一层的

sock5是哪一层的

IEEE802为局域网规定的标准对应OSI参考模型哪几层？似乎802不是对应某一个层。
可能还要扯到OSI与IEEE的关系？


## 协议分层


## ARP与RARP协议
Address Resolve Protocol与Reverse Address Resolve Protocol是将IP地址与MAC地址进行互相查找的协议。
需要注意，ARP与RARP协议工作在以太网上，非以太网根本就没有MAC地址。以太网一般应用在局域网中，网络上路由器之间
如果构建在以太网上的话自然也需要MAC地址。

### ARP与RARP工作流程
ARP工作原理：当主机A向目的主机B发送IP分组的时候，发现本地ARP缓存中没有主机B的MAC地址，于是发起ARP询问广播，
广播报文包含主机A的IP与MAC地址以及主机B的IP以及MAC广播地址FF:FF:FF:FF:FF:FF。主机B收到询问后记录主机A的IP与
MAC地址的关系然后相应自己的MAC地址，从而主机A获得主机B的MAC地址。

RARP工作原理：

### ARP代理

### ARP欺骗

## ICMP

ICMP重定向
https://blog.csdn.net/dgj8300/article/details/51192576
https://blog.51cto.com/692344/992976
https://www.cnblogs.com/KevinGeorge/p/7866840.html

## DHCP
### DHCP过程

### DHCP为什么采用广播

### DHCP如何避免重复

## NAT
wiki:https://en.wanweibaike.com/wiki-Network_address_translation

nat穿透导致的奇怪问题
https://stackoverflow.com/questions/15349958/why-would-closing-a-dead-tcp-socket-affect-another-open-tcp-socket#