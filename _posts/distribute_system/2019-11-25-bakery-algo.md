---
layout: post
title: A New Solution of Dijkstra’s Concurrent Programming Problem
description: ""
category: 分布式
tags: [分布式]
---
{% include JB/setup %}

* toc
{:toc}

在这篇论文中，Lamport给出了一个多进程互斥算法，lamport本人非常看重这个算法，这是一个神奇的算法，它甚至不要求读写操作的原子性，也不关心读操作返回的任何值，lamport在http://lamport.azurewebsites.net/pubs/pubs.html#bakery 上说其之后的不少成果根源于此，甚至说关羽并发的一切都是来自研究该算法。

## 部分翻译

进程共有的存储包含以下内容:

```
integer array choosing[1:N], number[1:N]
```

choosing[i]与number[i]在进程i的内存中比被初始化为0.
number[i]的值的范围是无界的，稍后再讨论这一点。

下面是进程i的程序。执行必须从非临界段开始。maximum函数的参数可以任何顺序参与运算。整数对的“less than关系”定义为(a,b) < c, d当a< c或者a = c但b < d的时候。

```
//something before

begin integer j;
	L1: choosing[i] := 1
		number[i] := 1 + maximum(number[1], ..., number[N]);
		choosing[i] := 1
		for j = 1 step 1 until N do
			begin
				L2: if choosing[j] != 0 then goto L2;
				L3: if number[j] != 0 and (number[j], j) < (number[i], i) then goto L3;
			end;
		critical section;
		number[i] := 0
		noncritical section;
		goto L1;
end

//something after
```

我们允许进程i在任意时刻失败,然后在非临界区重启（同时choosing[i] = number[i] = 0）. 然而，如果一个进程一直失败重启，那么整个系统会死锁。

## Proof of Correctness

为了证明这个算法的正确性，我们做出如下定义。称进程i为在门口，当 choosing[i] = 1的时候。称进程i为在面包房内，从进程重置 choosing[i]为0到进程失败或者离开临界区。算法的正确性由如下的断言推论而出。
注意，该断言没有做读写重叠的任何假设（读写操作可以是非原子的）。

断言1. 如果进程i与k都在面包房之内，并且i进入面包房的时间早于k进入门口的时间，那么有number[i] < number[k].

> 什么叫早于？虽然此处可以以“绝对时间”或者统一时钟周期来理解，但都包含假设的意味，因此我们理解为在内存上开来，进程i的choosing[i]变为0先于进程j的choosing[j]变为1.

> 除了断言1中的条件之外，其他任何情况都不足以保证number[i] < number[k]。比如进程早于进程j进入面包房，则有可能number[i] >= number[k]。

>为什么断言1没有对读写做出原子假设。因为断言1中choosing[i] 置为0与choosing置为1 都关心的是值变化的瞬间，而不是关心值改变的过程。

断言2. 如果进程i在临界区，进程k在面包房，且 k不等于i。 那么有(number[i], i) < (number[k], k)

>注意该断言并未对进程k是否在临界区做出任何声明。

证明： 既然 choosing[k] 只有0 与 1两个值。 从进程i的视角看来，我们可以假设，读写这个值是一瞬间的事，同时的读与写不会同时发生。例如，如果 choosing[k]正从0变为1，同时这个值正被另一个进程i读取，那么这个读取要么读到0，从而读发生在写之前，要么读到1从而写发生在读之前。所有的时间都是以进程i的视角来定义的。

>其实上面还是做了写操作原子性的假设，即便是1到0的变化，我们依然无法断定下面的硬件如何实现，只有当0与1的存储编码只差一个bit的时候，这种假设才是正确的，因此lamport的这里有错。幸运的是，最常使用的intel处理器规范保证了读写一个字的原子性（引证？）。

令$$t_{L2}$$为进程i最后一次执行L2且j = k时 读取choosing[k]的时间。令$$t_{L3}$$为进程i执行最后一次L3且j=k时的时间，因此有
$$t_{L2} < t_{L3}$$。当进程k选择number[k]的当前值的时候，令$$t_{e}$$为进程k进入门口的时间。$$t_{w}$$为进程k写完number[k]的值的时间。$$t_{c}$$为进程k离开门口的时间。那么有$$t_e < t_w < t_c $$。

>进程i肯定会有最后一次执行L2的时候，怎么保证有j=k呢？有j=k且最后一执行意味着choosing[k] = 0, 意味着进程k不在门口。断言2规定了进程k在面包房内。断言2为什么要规定在面包房内呢？ 从进程i的视角来看，其他进程要么在门口要么不在门口，因此可能没有j=k。而我们只关心进程k是否进入临界区打破算法，若进程k在门口那么其肯定不在临界区，我们也自然不用关心。就算其他所有的进程都在门口，L2遇到j = i的时候也会退出循环。

既然choosing[k]在时间$$t_{L2}$$的时候为0，我们要么有(a) $$t_{L2} < t_e$$ 要么有 (b)$$t_c < t_{L2}$$。在情况(a)中，根据断言1有 number[i] < number[k]， 因此断言2成立。

情况(b)的时候，我们有 $$t_w < t_c < t_{L2} < t_{L3}$$，因此有$$t_w < t_{L3}$$。因此，在开始于$$t_{L3}$$时刻的L3语句执行期间，进程i读取了number[k]的当前值。既然进程i因为j=k不再执行L3，那么它一定有(number[i], i) < (number[k], k)。 因此，情况(b)下断言成立。

断言3. 假设只会发生有限的进程失败。如果没有进程在临界区且在面包房里有一个没有失败的进程，那么一些？进程将最终进入临界区。

证明：假设没有进程进入过临界区。那么总会在经过一段时间后，没有进程进入或者离开面包房。此时，假设在面包房的所有进程中进程i拥有最小的(number[i], i)。那么进程i最终将完成for循环进入临界区。从而与开头假设矛盾。

断言2意味着任何时候最多有一个进程在临界区中。断言1与断言2证明进程之间按照FIFO的顺序进入临界区。因此，一个单独的进程不能被阻塞除非整个系统死锁。断言3意味着除非某个进程在临界区挂掉，否则不会死锁。

如果进程j持续的失败重启，运气坏的情况下，进程i将会永远发现choosing[j] = 1， 因而永远在L2循环。

## Further Remarks

如果在面包房里总是至少有一个进程，


断言1是显而易见的。