---
layout: post
title: 内存模型介绍
description: ""
category: 硬件
tags: [hardware, ddr, modern computer]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 简介

当我们写程序、推演程序运行的时候，程序在我们眼中是自上而下、逐条指令（上一条执行执行结果对下一条指令可见）执行的。
随着硬件与编译技术发展，指令重排序（编译器、硬件重排序与storebuffer）与指令优化使得程序实际上可能并不是按照我们想象的那样顺序执行的。然而程序员又不太可能
顾及硬件实现的方方面面，因此需要一个接口或协议一样的东西来保证：程序员按照自上而下、逐条执行的观念来写程序，编译器与硬件
尽可能去优化，但是这种优化不能被程序观察到。也就说，程序员按照程序顺序推演程序的结果不能与实际执行不符合。

内存模型理论应该是伴随着多处理器技术发展起来的，但是内存模型在单处理器上一样存在，也就是所谓的要保证program order一致性。但是单处理器的内存模型比较简单
，内存模型理论主要是基于多处理器共享内存的模型。


指令重排序与优化包括两个层面：其一是编译器把程序翻译为机器语言的时候，会进行指令消除、重排序等优化，优化手段本文不涉及，因为这是一个庞大的主题。其二是硬件（cpu与内存）
也会进行重排序。这种重排序可以理解为两个方面：一是cpu预取指令可能让后面的指令先执行，二是storebuffer的存在可能使得先发送的写指令后执行。cpu重排序也是一个非常大的主题。
我们只需要知道指令重排序在编译、硬件两层都存在即可。

关于这一方面的入门文章可以参考：

[Memory Consistency Models: A Tutorial][0]

[Memory Consistency Models for Programming Languages][1]

[Memory Ordering At Compile Time][102]

[Memory Reordering Caught in the Act][103]

## 内存模型理论

最早关于内存模型的理论当属[Lamport的顺序一致性理论][2]，顺序一致性理论非常重要也是一个非常直观的理论，顺序一致性内存模型下的程序推演与我们的直觉相符合。
实际上之后发展的所有的内存模型理论都离不开顺序一致性理论。

关于各种内存模型的介绍可以参考[David Mosberge的Memory Consistency Models][3]与[A Unified Theory of Shared Memory Consistency][4]。

实际上各种内存模型之间存在内在关联，最强的内存模型为原子一致性，但是原子性几乎等价于单线程顺序执行，因而不具有实际意义，一般而言，多处理器内存模型最强模型
值得是顺序一致性。

关于内存模型之间内在联系与统一理论的论文可以参考[Sarita V.Adve&Mark D.Hill的A Unified Formalization of Four Shared-Memory Models][5]与[A Unified Theory of Shared Memory Consistency][4]

描述一个内存模型的术语有多种，互相之间往往是互相等价的。

### 单线程的内存模型
虽然单线程的内存模型非常简单，但却是理解内存模型的一个基础。下面我们用不同层次的术语来描述：

执行历史层面：执行历史是一种“宏观”的描述方法，有了这个层面的认识，才有了其他层面的认识，虽然它们是等价的。
对于单线程内存模型，指的是程序的执行结果与程序按照顺序执行的结果相同。


逻辑顺序层面：不能违反程序顺序与因果依赖顺序（关于这个顺序参见文章：分布式系列之二：线性一致性与顺序一致性）

硬件层面：cpu按照程序顺序发送读写请求，内存对同一地址的读写请求按照请求顺序执行。

读写指令层面：这方面可参考intel手册描述内存模型的方式，单线程暂时没有想到怎么描述比较简洁。

程序员层面：程序按照程序顺序执行，且前一条指令的执行结果对后面的指令可见。




### 原子一致性
原子一致性模型基本不具有实际应用价值，然而该模型实际上线性一致性理论在内存模型上应用。
该模型等价于内存模块有一个唯一队列，所有的线程都按照各自的program order向该队列发送内存读写请求，内存按照请求发送顺序执行各个请求。
也就说，该内存模型就是将多线程程序变成了单线程程序，因而在多处理器技术上，几乎没有实际应用价值。

### 顺序一致性

顺序一致性的概念出自Lamport的[一篇短文][2]。该模型等价于内存模型每个地址都有一个请求队列，所有的线程都按照各自的program order向该队列发送内存读写请求，内存按照请求发送顺序执行各个请求。

我们考虑顺序一致性的必要条件：对于某个进程A，进程内可以任意排序，只要不违反结果与program order的一致性就可以。那么对外，只要其他进程观察到进程是按照program order在执行的就可以了。那么其他进程怎么观察呢？通过检查进程A与其他进程的共享内存的修改行为，也就是写操作，注意进程A的读操作是对其他进程的观察没有任何影响的，且进程A
不知道其他进程会观察进程A的哪些写操作，所以进程A必须保证自己所有的写操作按照program order依次对外暴露可见性。

## 实际中内存模型

不同的硬件使用的内存模型不一样，但几乎没有顺序一致性，具体可以参考[这儿][6]。

虚拟机作为对硬件的模拟，也需要向上层程序提供一个内存模型，下面我们会讲到java虚拟机的内存模型。

同样，作为跨平台的各种高级语言，一般也会提供一个内存模型，语言层面提供的内存模型比较偏重程序语义，这点
在下面讲C/C++内存模型就可以看到。

### intel内存模型

intel软件开发手册第三卷8.2节详细描述了intel系列cpu的内存模型，并给出了例子。
对比intel手册中的内存模型与sc模型，可以发现intel内存模型非常强，在单处理器上，与sc几乎只差了半点：允许读指令与先前的不同位置的写指令重排序。
甚至在处理核心直接也提供了非常强的保证，除了两个处理核心间的两个写操作在互相看起来不一致（但这两个写操作在其他处理核心看了都是同样的顺序）。
不少资料都称intel的内存模型为Total Store Order，也就是TSO。但是intel的内存模型显然不是TSO，参考手册8.2.3.5 Intra-Processor Forwarding Is Allowed
一节，两个不同进程的写操作在执行他们两个进程之间看起来顺序是相反的，但是intel又保证了这两个写操作在其他进程看起来是顺序一致的。

实际上intel手册里从来没有承认自己是TSO内存模型，在手册8.2.2 Memory Ordering in P6 and More Recent Processor Families节中，关于比较新的cpu架构，内存模式的描述是：The Intel Core 2 Duo, Intel Atom, Intel Core Duo, Pentium 4, and P6 family processors also use a processor-ordered memory-ordering model that can be further defined as “write ordered with store-buffer forwarding.”

8.2.5节还描述了如何增强甚至减弱内存模型，由此可见intel内存模型又一定灵活度的。

8.1.1 Guaranteed Atomic Operations描述了intel保证了原子性的读写操作。

8.1.4 Effects of a LOCK Operation on Internal Processor Caches描述了lock指令的作用。

手册中还描述了sfence，lfence，mfence三个内存屏障，然后这三个内存屏障的实际语义并不像它们的名字看起来那么规整对称。下面内存屏障一节会详细讲。

### java内存模型

关于java内存模型的可以参考论文[The Java Memory Model][7]，该论文描述了java内存模型的修订以及新的内存模型以及其构建方法（面向编译器与虚拟机开发者），文中还给出了完整的java内存模型进化与新内存模型描述的参考资料，关于这篇论文我已经写了一个前半部分的文章。文中讲述java5.0修订了之前的内存模型，新的java内存模型基于的理论是
[Weak Ordering - A New Definition And Some Implications][8]。在Weak Ordering这篇论文中，Adve等提出来一种面向程序员理解的方法，
这种方法基于一个弱的内存模型，用来尽可能减少硬件与编译器优化的限制，同时顾及易于理解，程序员只要遵循一定的编程模式，该模型就能保证程序的顺序一致性。要理解这种神奇的方法，作为程序员，这篇论文只需参考前3节就可以了。

在论文中，Adve先基于先前其他人的研究工作，定义了一种weak order：

	Definition 2: A system is weakly ordered with respect to a synchronization model if and only if it
appears sequentially consistent to all executions of a program that obey the synchronization model.

该定义要求一个synchronization model，然后论文中又给出了一个模型DFR--Data-Race-Free：

	Definition 3: A program obeys the synchronization model Data-Race-Free (DRF), if and only if
(1) all synchronization operations are recognizable by the hardware, and
(2) for any execution on the idealized system (where all memory accesses are executed atomically
and in program order), all conflicting accesses are ordered by the happens-before relation corresponding to the execution.


定义2讲的是 如果一个系统在一个同步模型下是弱指令排序的，等价于 遵循该模型后系统上的程序看起来是顺序一致性的。

定义2指出了一个弱排序内存模型的唯一限制，只要它遵循同步模型后是顺序一致性的就可以了。那么程序员只需要遵循同步模型，不用关系内存模型。
定义3提出了这样的一个同步模型DFR。

论文附录部分的引理Appendix A: A necessary and sufficient condition for weak ordering w.r.t. DRF. 证明了遵循DFR的内存模型总是顺序一致性的。
关于这个证明的理解：所谓存在happens-before关系其实指的是共享变量的操作序列在全局视角上有一个一致认同的先后关系。**顺序一致性从来要求的都是共享变量的操作顺序
从各线程看起来是一致的，而不是要求这个操作顺序是某一个确定的顺序的，后者的要求是线性一致性的要求**。

相比于java语言规范JLS中的描述，论文的描述要清晰的多，但论文比较偏重原理，论及全面不如JLS，因此完整的理解java内存模型，应该是先看论文，再读JLS。
[java9的JLS中内存模型的链接][9]。

因此，当java中所有的共享变量用volatile修饰之后，就变成了DFR。注意，顺序一致性模型并不意味着上层逻辑之间不再需要同步，因为cpu根本无法感知上层多个内存变量之间的
依赖关系，比如`i++`依然需要加锁或者使用原子变量的原子操作。
。

注意区分如下的两个例子：

```
//example 1
volatile int a = 0;
a++;

//exampel2
AtomicInteger aint = new AtomicInteger(0);

aint.getAndIncrement()

```

valatile指的是该关键字修饰的变量的写操作是原子的（硬件未必保证读写操作是原子的，甚至java9语言规范[JLS 9-17.7][10]也不保证double与long的读写原子性，因此volatile的原子性保证是有意义的），且写操作完成后修改立刻对所有线程可见，volitale同时保证了原子性与可见性。而`a++`包含读a，加1，写a三部操作，volatile只能保证最后一步是原子的。
也就是volatile的原子性保证其他线程要么读不到修改，要么读到一个修改后的值，而不会读到修改了一半的值。

#### 两个例子
结合JLS上的定义，java是严格遵循program order的，在JLS Happens-before Order一节：
	
	If x and y are actions of the same thread and x comes before y in program order, then hb(x, y).

因此，如下的生产者消费者是不需要加锁的：
```
//shared variables 不需要volatile也不需要加锁

int prepared = 0;

//producer

do_produce();

prepared = 1;


//comsumer

while( prepared != 1 ){

}

do_comsume();

```

而,如下的mutex是需要加volatile的,不仅仅在于原子性，更重要的是可见性保证了两个线程不会同时进入临界区
（代码简陋，这个例子会发生活锁，但与我们现在要讲的东西无关）
```
//thread 1
volatile int a_is_running = 1;

if(b_is_running != 1){
	do_critical();
}


//thread 2

volatile int b_is_running = 1;

if(a_is_running != 1){
	do_critical();
}

```

关于java内存模型的理解比较好的两篇文章：
* [Data Race Free 的前世今生][https://blog.csdn.net/on_1y/article/details/38644639]
* [对Data Race Free的理解][https://blog.csdn.net/on_1y/article/details/38644463]
当然一切还是以论文与官方资料为准。

### c\c++内存模型
C11开始才规范化了c语言的内存模型，基本上与C++一致。
C++的内存模型可以参考[这里][11].

C++的内存模型看着很多，实际上只有三类：relaxed，acquire&release语义，seq_cst。
consume模型被C++规范[暂时劝止使用了][11]。

C++里面的内存屏障与同步操作使用的是用一套枚举定义。
然而release operation与release fence之间有些微妙的差别。两者都会阻止某些重排序，关键在于界限：

```
//example 1
ptr.store(p, std::memory_order_release); //以该操作为界，不许前后指令重排序

//example 2
data[v0] = computation(v0);
data[v1] = computation(v1);
data[v2] = computation(v2);
std::atomic_thread_fence(std::memory_order_release);//以该屏障为界，不许指令重排序

```

关于C++内存屏障与同步操作更多可参考[这里][12]，[这里][13]，[这里][14]和如下的链接：

http://ericnode.info/post/atomic_in_c11/

https://www.cnblogs.com/catch/p/4158495.html

https://www.zhihu.com/question/24301047


## 内存屏障
上面讲到实际的硬件往往不是顺序一致性的，但是程序大多是是按照顺序一致性的模型来编写的，因而硬件层面一般会提供各种手段来增强自己的内存模型，
其中一种方式就是内存屏障。

同样，在不同的层次，内存屏障也有不同的概念。据笔者理解，至少可以分为具体硬件的内存屏障，综合各种硬件的抽象的内存屏障，以及程序语言语义上的内存屏障三种。


硬件层面以intel为例，提供了lfence、sfence、mfence三个内存屏障。

由于intel是一种非常强的内存模型，普通的存取操作保证了线程内的读-读，写-写不可重排序，因此一般情况下是[不需要lfence与sfence的][15]。

LFENCE等同于下面要讲的loadload，但是一般情况下intel架构下用不到lfence。
而SFENCE不等同于下面要讲到的StoreStore。因为StoreStore要求前一个Store的全局可见性。

LFENCE与SFENCE也不具有下面要讲的acquire与release语义。因为这两个语义分别依附于读操作与写操作，而[不能是单独的内存屏障][16]。

LFECE+SFENCE也[不等于MFENCE][17]。显然的，LFENCE与SFENCE都是单线程内的排序，且无涉于acquire、release，因此一般用不到。

LFENCE与SFENCE的使用场景可以参考[这里][18]，[这里][19]还有[这里][100]。

关于intel提供的内存屏障的更多理解可以参考[这里][20]，[这里][21]与[这里][22]。

值得一提的是，[java内存模型里面有三个内存屏障][23]loadFence，storeFence，fullFence，容易误认为是intel下的三个内存屏障的包装，
然而其实是[不同的][24]。

硬件抽象层面可以参考[The JSR-133 Cookbook for Compiler Writers][25]。根据该cookbook，内存屏障抽象为loadload，loadstore，storestore，storeload四种。cookbook还给出了4中内存屏障在一些平台下的对应指令
，可以看到intel下的loadload与storestore指令都是NO-OP，但是意义不同，loadload对应的no-op是不必提供，intel默认就能保证单线程内load顺序。
storestore对应的no-op指的是不支持该内存屏障。

关于这个抽象，[资料][101]中的storestore的解释与JSR-133不同，前者不要求第一个store的全局可见性，存疑但我倾向于JSR-133正确。


而语言层面的内存屏障更偏向于程序语义，还是以[C内存模型][26]或[C++内存模型][27]为例。常用的三种语义：acquire，release，seq-cst。

这些程序语义上的内存模型与4中内存屏障抽象之间的关系可以参考[这里][28]。

C++下内存顺序与intel下指令的对照关系可以参考[这里][30]。


## 无锁编程

C/C++的内存模型要比java复杂，C/C++下的无锁编程可以参考[An Introduction to Lock-Free Programming][31]。

注意区分下面的两个无锁编程的例子，其要求的最低内存模型不一样。
第二个例子使用第一个例子的内存模型是不行的。

```
//acquire-release 要求每个线程是program order


//shared variables

int prepared = 0;

//producer

do_produce();

prepared = 1;


//comsumer

while( prepared != 1 ){

}

do_comsume();



//mutex 要求顺序一致性
/*

下面这个例子的指令组合特性决定了至少存在一个
```
x_is_running = 1
...
x_is_runing == 1
```
这样的指令顺序，且这两条指令之间（需要原子性保证至少能区分先后）最少可以一条指令都没有。

因此需要写操作完成后立刻全局可见。注意区分这里的数学组合特性的要求与顺序一致性的要求。

*/

//thread 1

a_is_running = 1;

if(b_is_running != 1){
	do_critical();
}


//thread 2

b_is_running = 1;

if(a_is_running != 1){
	do_critical();
}
```

## 与同步、缓存一致性的关系

与二者不是同一抽象层面。内存模型是程序指令一级正确运行的保证，而同步操作是应用语义一级别正确允许的保证。
缓存一致性则是内存模型中全局可见性的实现手段。内存模型决定了什么时候将storebuffer写回到缓存，
缓存一致性则保证写回缓存后最终会所有缓存一致，但不保证什么时候达到这种一致性，而内存模型与同步则会要求在什么时候（哪些指令执行前或后）达到
这种缓存一致性。

## 其他资料

已阅读：

https://www.cs.utexas.edu/~bornholt/post/memory-models.html

未阅读：
《A Unified Theory of Shared Memory Consistency》https://arxiv.org/pdf/cs/0208027.pdf

《A unified formalization of four shared-memory models》http://pages.cs.wisc.edu/~markhill/papers/topds93_drf1.pdf

《A Comprehensive Bibliography of Distributed Shared Memory》提供了一个论文索引。



[0]:https://www.cs.utexas.edu/~bornholt/post/memory-models.html
[1]:http://beza1e1.tuxen.de/memory_models.html
[2]:http://lamport.azurewebsites.net/pubs/pubs.html#multi
[3]:http://www.cse.psu.edu/~buu1/teaching/spring07/598d/_assoc/CCBD250576DD4E41ABC1EC82207C66A0/mosberger93memory.pdf
[4]:https://arxiv.org/pdf/cs/0208027.pdf
[5]:http://pages.cs.wisc.edu/~markhill/papers/topds93_drf1.pdf
[6]:https://preshing.com/20120930/weak-vs-strong-memory-models/
[7]:http://rsim.cs.uiuc.edu/Pubs/popl05.pdf
[8]:https://pdfs.semanticscholar.org/0aaf/2025a30fa2b56491a34dec2da27d7eeb7160.pdf
[9]:https://docs.oracle.com/javase/specs/jls/se9/html/jls-17.html#jls-17.4
[10]:https://docs.oracle.com/javase/specs/jls/se9/html/jls-17.html#jls-17.7
[11]:https://en.cppreference.com/w/cpp/atomic/memory_order
[12]:https://en.cppreference.com/w/cpp/atomic/atomic_thread_fence
[13]:https://stackoverflow.com/questions/8841738/c-memory-barriers-for-atomics
[14]:https://stackoverflow.com/questions/39053600/does-standard-c11-guarantee-that-memory-order-seq-cst-prevents-storeload-reord#
[15]:https://stackoverflow.com/questions/32705169/does-the-intel-memory-model-make-sfence-and-lfence-redundant
[16]:https://stackoverflow.com/questions/16071682/does-intel-sfence-have-release-semantics
[17]:https://stackoverflow.com/questions/27627969/why-is-or-isnt-sfence-lfence-equivalent-to-mfence/
[18]:https://www.zhihu.com/question/29465982
[19]:https://stackoverflow.com/questions/4537753/when-should-i-use-mm-sfence-mm-lfence-and-mm-mfence
[20]:https://stackoverflow.com/questions/32681826/does-sfence-prevent-the-store-buffer-hiding-changes-from-mesi
[21]:https://stackoverflow.com/questions/44864033/make-previous-memory-stores-visible-to-subsequent-memory-loads/
[22]:https://hadibrais.wordpress.com/2018/05/14/the-significance-of-the-x86-lfence-instruction/
[23]:https://stackoverflow.com/questions/23603304/java-8-unsafe-xxxfence-instructions
[24]:http://openjdk.java.net/jeps/171
[25]:https://blog.csdn.net/aigoogle/article/details/39023069
[26]:https://en.cppreference.com/w/c/atomic/memory_order
[27]:https://en.cppreference.com/w/cpp/atomic/memory_order
[28]:https://preshing.com/20120913/acquire-and-release-semantics/
[30]:https://www.cl.cam.ac.uk/~pes20/cpp/cpp0xmappings.html
[31]:https://preshing.com/20120612/an-introduction-to-lock-free-programming/

[100]:https://stackoverflow.com/questions/27595595/when-are-x86-lfence-sfence-and-mfence-instructions-required
[101]:https://preshing.com/20120710/memory-barriers-are-like-source-control-operations/
[102]:https://preshing.com/20120625/memory-ordering-at-compile-time/
[103]:https://preshing.com/20120515/memory-reordering-caught-in-the-act/

