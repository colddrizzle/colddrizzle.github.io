---
layout: post
title: windows下主机网路拓扑例子

tagline: "Supporting tagline"
category : network
tags : [windows, network, config]

---
{% include JB/setup %}

* toc
{:toc}


# 主机，网卡，IP、网关、网段的对应关系

这里的IP指的是源IP，网段指的是目的地址网段。

一台主机可以有多个网卡。

windows上一个网卡可以配置多个IP，多个默认网关。但是下面分类中提到的多IP、多网关是现对于主机而言的，对于网卡，仍然是一个IP，这是为了避免分类中重复情况出现。

一台主机可以同时接入多个网段。比如可以认为连接家用路由器的一台电脑，可以访问局域网以及Internet两个网段（把整个Internet当成一个网段不严谨
但不影响理解）。

一般一个IP可以属于多个网段，只要这个IP只绑定在一个设备上。

一个源IP只能属于一个网卡，多个网卡不允许有相同的源IP。

一个网关只能通向一个网段。

一般而言一个源IP只能使用该网卡上的网关，若该网卡不通，则会报错。

# Multihoming 与 IP alias
IP alias在windows就是单网卡多IP，在linux下是子接口吗？

multihoming是指一台主机接入多个网络，而IP alias指的是一个网卡绑定多个IP。

multihoming是为了增加可靠性。而IP alias通常是为了避免冲突或者使得一台电脑看起来像是多台电脑。

multihoming一般通过多地址来实现。当用单网卡多地址来实现的时候，multihoming就与IP alias结合起来了。

更多可参考各自wiki词条[Multihoming][]和[IP aliasing][]。

# 场景枚举
首先这个问题要细分，根据单多网卡、单多IP、单多网关、单多网段可以分成16种情况。

这里的多网段指的是目的地址网段。一个局域网中多个局域网IP地址属于一个网段，因此多个目的IP并不意味着多网段，需加以区分。


## 1 单网卡 单IP 单网关 单网段
最普通形式，不再细说。

## 2 单网卡 单IP 单网关 多网段

不可能

## 3 单网卡 单IP 多网关 单网段

![img](/assets/resources/windows-topology/one-ip-two-subnet.png)

冗余链接。

## 4 单网卡 单IP 多网关 多网段
与下面的例子完全一致。
https://zhuanlan.zhihu.com/p/101801125

## 5 单网卡 多IP 单网关 单网段

多个源地址，源地址选择问题，选择完源IP地址后等同情况1.

## 6 单网卡 多IP 单网关 多网段

不可能。

## 7 单网卡 多IP 多网关 单网段

![img](/assets/resources/windows-topology/one-nic-two-ip-two-gw-one-net.png)

两个广域网可以认为是相同网段。因为是多网关接入单独网段，可以认为是一种冗余配置。路由表配置如下：

```
destination mask	 gateway 	 inteface  		metric
0.0.0.0 	0.0.0.0	 192.168.1.1  192.168.1.3	 20
0.0.0.0 	0.0.0.0	 172.20.10.1  172.20.10.10	 30
```
这时候两条路由只有一条会生效，也就是metric较小的那条。

## 8 单网卡 多IP 多网关 多网段

![img](/assets/resources/windows-topology/one-nic-two-ip-two-gw-two-net.png)

路由表配置如下：
```
destination mask	 gateway 	 inteface  		metric
11.11.11.0 	255.255.255.0	 192.168.1.1  192.168.1.3	 20
12.12.12.0 	255.255.255.0	 172.20.10.1  172.20.10.10	 30
```
这时候两条路由都会生效，根据目的地址不同各自走各自的网关。

## 9 多网卡 单IP 单网关 单网段 

桥接虚拟网卡，等同情况1

## 10 多网卡 单IP 单网关 多网段

不可能。

## 11 多网卡 单IP 多网关 单网段 

桥接虚拟网卡后 等同情况3

## 12 多网卡 单IP 多网关 多网段

桥接虚拟网卡后 等同情况4

## 13 多网卡 多IP 单网关 单网段

![img](/assets/resources/windows-topology/two-nic-two-ip-one-gw-one-net.png)

## 14 多网卡 多IP 单网关 多网段

不可能。

## 15 多网卡 多IP 多网关 单网段

冗余连接，等同情况3

## 16 多网卡 多IP 多网关 多网段

大约等同于情况4

## 总结
去掉2、6、10、14不可能的情况，去掉11,12,15,16重复的情况，还剩下实际上有意义的
8种情况。

# 特殊拓扑
## case 1 
![img](/assets/resources/windows-topology/special-case-1.png)

注意两台电脑不经过交换机直连构成单独的子网。若是按照图中配置，则该子网与主机所在局域网网段冲突。
因此需要为192.168.1.6单独配置一条路由：

```
192.168.1.6 255.255.255.255 0.0.0.0 192.168.1.5 20
```

而且要关闭DHCP以免把IP192.168.1.6分配给局域网内的电脑。

这种情况还可以参考[这里][https://networkengineering.stackexchange.com/questions/59765/two-nics-ip-address-conflict-between-2-networks
]

# 一些例子

https://www.jianshu.com/p/305279aacc42

# 原则

## 一个计算机可以接入的多个子网的IP范围不可以冲突。要保证IP的唯一性。


# 问题

1. 单网卡多IP是否可以设置负载均衡？


