---
layout: post
title: windows下网络配置
tagline: "Supporting tagline"
category : network
tags : [windows, network]

---
{% include JB/setup %}

* toc
{:toc}

<hr />


本文主要涉及Windows系统下IPv4的一些网络配置问题。

## 主机、网卡、IP、网关的对应关系

显然一个windows主机可以配置多个网卡。

![img](/assets/resources/windows-control-panel-network.png)

从windows的配置界面上来看，IP，默认网关的配置都是关联到网卡，也就是每个设备都有一套独立的配置。但是需要注意网卡是一个二层设备
，怎么会有IP、网关这些配置呢？这个就需要将整个计算机看做一个整体来看待。可以把整个计算机理解为一个路由器。网卡只是输入输出端口，
操作系统或者说驱动程序将IP、网关关联到网卡上，正如路由器将IP关联到各个输入输出端口上。

在一般的骨干路由器中，一个端口一般只能配置一个IP，但也可以使用虚拟子接口配置多个IP。windows也一样，可以为一个网卡配置多个IP。

不仅如此，windows还可以为一个网卡配置多个默认网关。多个默认网关通常是为了冗余意义而设置的，[来自微软的解释][8]：“multiple default gateways are intended to provide redundancy to a single network (such as an intranet or the Internet). They will not function properly when the gateways are on two separate, disjoint networks (such as one on your intranet and one on the Internet). ”。

就单网卡而言，多个默认网卡同时生效的只有一个。当然多个网卡有各自的默认网关，可以分别生效。

需要区分的网关与默认网关。默认网关是网关，只不过是缺省网关，`route print`查看路由表会发现每一条都有一个网关字段(有些是on-link字样，下面会讲)。
默认网关就是`0.0.0.0 0.0.0.0`开头的路由配置，意义是任意网段的任意IP，若不匹配其他路由表配置，则走默认网关。

每个网卡必须配置单独的默认网关，否则该设备不能工作，但可以有多个默认网关。

单网卡多IP有些情况下会导致问题。根据下面要讲的源IP选择策略可知，源IP的选择是根据选定路由规则后的网关来的，那么就有可能远端机器M向计算机D发送的数据时目的IP是A，但是回应机器M时
收到的D的地址为B。

## 认识路由表

如图是一个windows下的路由表配置情况：

![img](/assets/resources/windows-route-table.png)

可以看到一个路由配置包含 网络目标、网络掩码、网关、接口、跃点数5个字段。
且输出最开始包括当前主机所有适配器以及其编号的列表。这个编号在使用命令配置路由表的时候会用到。

网络目标与网络掩码不言自明。需要区分的是接口与源地址的概念，有些资料声称接口就是源IP。其实是错误的。
在下节源IP的选择中我们可以看到，源IP的选择自由一套规则，接口字段只是说该IP包从哪个接口发送出去。

在链路上的意义与配置方法: 根据[这里][5]以及自己的摸索，所谓在链路上就是不需要经过路由器转发，可以与其直接通信。又根据所谓的网关就是下一跳地址，也可以理解为下一跳地址与目的地址相同。若想在路由表中通过`route add`添加一条`on-link`字段的路由，
只需要将网关字段设置为`0.0.0.0`就可以了。

活动路由与永久路由:所谓永久路由是指在网卡上不使用DHCP后手工配置的默认网关生成的路由，以及通过`route add -p`添加的路由。
而活动路由可能每次启动计算机都会不一样。

metric的含义:metric翻译为跃点数，表面上好像指的是到目标地址需要经过的路由器跳数，然而发送端怎么可能知道这些事情呢？实际上metric代表走这个网关的代价，metric越高代表代价越高。通常这个值有windows自动给出，windows自动给出的规则参见[这里][6]。我们可以通过修改metric值应用或者抑制某一项路由配置。

关于更多路由表的理解可以参考[这里][7]。


## 网关与源IP的选择

虽然[RFC6419][4]详细描述了当前多接口网络主机的实现方法，其中包括了windows，但实验下来有些出入。以本文为准。

首先需要注意的是没有"默认网关选择"这个问题，只有“网关选择”这个问题。默认网关是相对网卡配置的而言的，不管配置多少个，都会在路由表中生效。
就路由表来说，默认网关都变成了一条条配置中的网关。

指定源IP的情况下，使用该源IP所在的网卡（通常情况下网卡不允许存在相同的IP，不同掩码也不行，参见[这里][0]和[RFC5889][1]）设备发送数据。
一般而言，该网卡会配置有几个默认网关，并在路由表中生成相应的配置，路由表中还会有一些手动配置的。指定源IP的情况下，也就是确定了网卡设备，
进一步的确定了接口IP范围（注意源IP与接口的区别），网关范围，加上目标网段范围，使用这三个范围从路由表选出**最佳路由**，如果有多个再根据metric判断（如果metric相同怎么办？尽量不要让它相同）

未指定源IP的情况下，windows会从路由表配置中选择**最佳路由**项，从而确定了使用的网关、接口，也就确定了网卡，然后从该网卡的多个IP中选出源IP。
选择方法是选取与网关二进制前缀最长的源IP，详细见[这里][2]（有个不一样的[资料][3]说是根据数字最小的IP作为源IP， 但我在Win7实验下来最长前缀是正确的），根据这种规整选出来的IP有时候并不是我们想要的IP。
此时可以用SkipAsSource字段将该IP过滤掉，详细见[这里][2]。

注意，虽然单个网卡会有多个网关，但是未指定IP的情况下网关的选择与网卡是否配置多个网关是没有直接关系的，因为是直接根据路由表选取的。我们应该关心的是，
配置默认网关会如何影响路由表。实际上默认网关配好后会自定生成一条对应的目的地址与掩码都为`0.0.0.0`的路由项，每个默认网关都会生成，他们之间再用metric区分优先级。

### 多个网卡的默认网关之间的关系
未指定源IP的情况下，若根据路由表，一个目标地址可以被多个默认网关路由到，那么根据metric选择最优的。

若指定了源IP的情况，使用该源IP所在网卡的默认网关。

## DNS、路由、MAC地址

每个网卡都有自己的DNS服务器配置，可以在相应的网络适配器IPv4配置中查看。

使用`route print`查看路由。更多用`route`配置路由表的信息可以参考[这里][10]

使用`arp -a`查看mac地址缓存。

如何修改mac地址？查看[这里][9]

## 一些问题
1. windows如何判断一个目标IP是否与自己同网段呢？
	windows是可以同时接入多个网段的。那么判断目标IP是否与自己同网段，要看选择了哪一个源IP。


## 网络拓扑

参见另一篇。

## 问题
这篇文章留下了两个问题：
1. windows如何从路由表中选择出到指定地址的最佳路由？
目前猜测是根据普通路由器相同的选取规则。待到路由篇我们再解决这个问题。
我们可以根据最佳路由选择策略做一些事情，比如https://segmentfault.com/q/1010000000362228

2. 家庭网关为何不路由局域网内数据而要求直接互联？



[0]:https://superuser.com/questions/336854/can-a-computer-with-2-network-cards-have-the-same-ip-address-for-both
[1]:https://tools.ietf.org/html/rfc5889#section-6.2
[2]:https://www.bigbrus.com/2014/09/16/set-static-source-ip-address-in-windows/
[3]:http://www.confusedamused.com/notebook/source-ip-address-preference-with-multiple-ips-on-a-nic
[4]:https://tools.ietf.org/html/rfc6419#section-3.2
[5]:https://superuser.com/questions/59996/what-does-on-link-mean-on-the-result-of-route-print-command
[6]:https://support.microsoft.com/en-us/help/299540/an-explanation-of-the-automatic-metric-feature-for-ipv4-routes
[7]:https://www.zhihu.com/question/22343916
[8]:[1]:https://answers.microsoft.com/en-us/windows/forum/windows_7-networking/warning-multiple-default-gateways-are-intended-to/5a023e4e-c6a5-4d9d-bfef-edaa83333c36
[9]:https://blog.csdn.net/zp357252539/article/details/51819726
[10]:https://www.jianshu.com/p/1db08a1d6e1b
