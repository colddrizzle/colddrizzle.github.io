---
layout: post
title: 硬件性能衡量时间尺度
description: ""
category: 硬件
tags: [hardware, perfmance, modern computer]
---
{% include JB/setup %}

——————————————————————————————————————————————

多核心 APIC 多级TLB  多级Cache 内存


————————————————————————————————————————————————————————


## 主频\外频

根据《深入理解Linux内核》定时测量一章，操作系统的视角下一般有三个时钟：
* 一个用来提供实时时间，也就是RTC。频率一般在2-8192Hz左右，也就是最高精度大约100微秒，实际上常常是秒级精度。C标准库中的time()与gettimeofday()就是指的它。
* 一个用来驱动CPU运行，也就是TSC。主频指的就是它。实际的晶振一般在100Mhz左右，无法产生Ghz的震荡。现代CPU上GHz的主频是通过晶振加电路倍频后得到的。可以通过汇编指令rdtsc来读取这个值，获得精度非常高的时间。但是由于睿频等技术，cpu的主频其实是一直在变化的，再一个如果用它来统计程序运行时间的话，是包括用户态与内核态以及之间切换的总的时间，而通常情况下我们只关心用户态的时间。
	```
	unsigned long long native_read_tsc(void)
	{
	        unsigned long long val;
	        asm volatile("rdtsc": "=A" (val));
	        printf("tsc:%lld\n",val);
	        return val;
	}
	```
	
* 一个用来驱动操作系统的运行，也就是intel SMP下的APIC，也就是常说的时钟中断。C标准库中的clock()函数就是取这个时钟节拍数，C标准库同时定义了CLOCKS_PER_SEC这个常量，一般在1K左右，也就是时间精度最高1ms。


而外频通常意义上可以理解为系统总线的频率。但是总线频率与内存频率还不一样。


## 带宽与吞吐量

内存只需要输出数据

CPU则数据与地址都要输出

数据总线的宽度
内存的单双通道


## CPU执行速度
一条指令的时间

平均指令周期数有没有可靠的数据

多级流水线


## 现代计算机各硬件访问延时

### 内存访问延迟

https://www.7-cpu.com/cpu/Skylake.html

根据aida64测试。

内存时序


## 高速缓存策略为什么能有效
参考 cpu-cache那一篇文章。

## 上下文切换的开销
https://www.quora.com/How-long-does-a-context-switch-take
下面这是上面quora的一个回答的引用  该引用的计算因为不合理被修改了
https://wiki.osdev.org/index.php?title=Context_Switching&diff=22557&oldid=21506

https://blog.tsunanet.net/2010/11/how-long-does-it-take-to-make-context.html

下面这篇文章比较重要，关于里面提到NTPL论文，O(1)调度器以及futex原理最好也看一下。
https://eli.thegreenplace.net/2018/measuring-context-switching-and-memory-overheads-for-linux-threads/

https://news.ycombinator.com/item?id=13930305

综合上面的资料可以一次上下文切换包括建立新的地址空间大约需要1μs到10μs之间。



对于一个运行着 UNIX 系统的现代 PC 来说， 进程切换通常至少需要花费 300 us 的时间。这个数据来源于https://www.zhihu.com/question/19732473/answer/241673170

## 函数调用的开销

## 时钟中断的开销


## 硬件带宽的未来趋势

GbE 100MB/s

SSD 500MB/s

modern cpu max memory bandwidth:85GB/s https://ark.intel.com/content/www/us/en/ark/products/96900/intel-xeon-processor-e7-8894-v4-60m-cache-2-40-ghz.html

The Future:https://blog.westerndigital.com/cpu-bandwidth-the-worrisome-2020-trend/

TbE 100GB/s

SSD ?


