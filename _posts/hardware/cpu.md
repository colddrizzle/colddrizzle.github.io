什么是Instruction Retired
https://software.intel.com/en-us/forums/intel-vtune-amplifier/topic/311170

MIPS
http://scottsoapbox.com/2015/08/15/how-far-weve-come-40-years-of-processing-power/
https://www.cisco.com/c/dam/global/da_dk/assets/docs/presentations/vBootcamp_Performance_Benchmark.pdf
https://gamicus.gamepedia.com/Instructions_per_second

MIPS与CPI直接的关系
CPI指的是每个逻辑核（每个线程而言）
假若一个N核双线程CPU的CPI为c，主频为p，那么MIPS约为
MIPS=2Np/c
比如下面资料最后一个I7
http://scottsoapbox.com/2015/08/15/how-far-weve-come-40-years-of-processing-power/
根据上述公式计算c约为
c=2Np/MIPS=2x4x4G/160G=0.2
与官方资料https://software.intel.com/en-us/vtune-help-cpi-rate大致相符合

CPI rate：
https://software.intel.com/en-us/vtune-help-cpi-rate

cache bandwidth:
是否最低一级缓存决定了CPU的最大内存带宽
如何理解内存延时与带宽的关系
如何理解内存越高级 延时越高 同时带宽越大
https://www.overclock.net/forum/297-general-processor-discussions/1541624-how-much-bandwidth-cpu-cache-how-calculated.html
https://software.intel.com/en-us/forums/intel-moderncode-for-parallel-architectures/topic/608964



多核与多CPU
https://zhuanlan.zhihu.com/p/85819786


关于一个安全漏洞的理解
https://www.redhat.com/en/blog/understanding-l1-terminal-fault-aka-foreshadow-what-you-need-know


Cache带宽与TLB大小可以从Intel® 64 and IA-32 Architectures
Optimization Reference Manual查的。比如其中的
Table 2-19.  TLB Parameters of the Broadwell Microarchitecture 
与Table 2-25.  Lookup Order and Load Latency

TLB多级组相连结构:
https://www.realworldtech.com/haswell-cpu/5/
https://stackoverflow.com/questions/40649655/how-is-the-size-of-tlb-in-intels-sandy-bridge-cpu-determined