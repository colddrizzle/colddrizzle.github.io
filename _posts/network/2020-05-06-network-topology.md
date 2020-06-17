
网关 路由 下一跳 三个概念各不相同，但是各有重叠，可能实现在同一个设备上 https://www.zhihu.com/question/50458692 

但这个概念区分并不严格：在rfc1009 1.1.2中明确提到 网关 指的就是 IP路由。但wiki也提到，一般意义上的网关可能出现在OSI模型的任意一层，
出现在网络层的我们称之为IP路由，或是一般意义上我们指的路由器。

Multihoming 

nat

子网未必是局域网，未必是电脑组成，多个路由器接口也可以组成局域网。
局域网内不需要路由，只需要链路层。

路由子网的默认网关是什么

网关 默认网关 跃点数

流量穿透

冲突域 广播域 管理域 自治域

广播域与mac:
1. 相同网段，MAC不能相同，否则，这两个电脑不能互访，网速变慢；
2. 即使是同一网络，但不同网段间，MAC相同毫无关系，因为有网关隔离的；

局域网 城域网 广域网

一般校园 公司的网络拓扑结构（随便找几个图）


路由器隔开的就像一个个小水池，广播风暴在水池内进行，找个描绘这个概念的图。


https://zhuanlan.zhihu.com/p/65226634 两个不同的子网通过交换机连接在一起真的不能相互通信吗，不是有mac地址就行了吗

子网：
https://serverfault.com/questions/331424/are-same-ip-address-with-different-submask-unique
On a fundamental level, subnets are there to separate broadcast domains and improve efficiency. They're not for sharing IP addresses.

