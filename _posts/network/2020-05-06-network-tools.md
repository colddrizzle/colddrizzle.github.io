https://serverfault.com/questions/312221/can-a-single-network-card-have-2-ip-addresses

## DNS相关
### nslookup

### dig

## traceroute

## ping

### 使用ping来确定MTU
方法：使用`ping  -f -l size ip`来反复探测。-f字段禁止分片。-l字段字段指定缓冲区长度也就是ICMP报文的除去头部之后负载长度。
应用场景：测试到指定地址的链路上的最小MTU。
原理：ping是使用ICMP类型为0的回显回答报文来实现的。而ICMP报文包含8字节的头部和任意长度的数据部分。ICMP报文本身又是承载在IP报文
上最后交付链路层的。
所以探测出合适的size之后，需要加上8+20字节才是链路层的MTU。通常情况下，运输层使用TCP协议时最大数据不应超过MTU-20-20-12个字节，使用UDP协议
不应超过MTU-8-20字节。
	
ping是如何禁止分片的呢？IP报文分片控制部分有3bit的标志位，中间一位DF位用来控制是否分片。如果发送禁止分片的数据报，并且数据报本身长度已经超出MTU的很制，则向发送方发一个icmp出错报文，报文类型为目的不可达(3)，代码为需要进行分片但被设置了不允许分片的位。（能否用抓包验证一下？）


更多：https://zhuanlan.zhihu.com/p/30020463

更多：https://blog.51cto.com/xjsunjie/705205

## ifconfig
需要注意的是windows系统叫ipconfig，而linux系统是ifconfig。

## netsh


## netstat

netstat -nr

## route

## tcpdump

### 使用tcpdump来看谁在ping我

https://serverfault.com/questions/448541/how-to-know-who-ping-my-computer

比如在我的mac上就是`sudo tcpdump -i en0 "icmp and icmp[icmptype]=icmp-echo"`


## 网络问题checklist

1.检查dns与hosts设置

2.检查网卡设置：几个网卡，几个接口

3.检查转发表设置

4.检查arp缓存

5.检查防火墙设置

