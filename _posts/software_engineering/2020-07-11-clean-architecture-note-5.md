---
layout: post
title: 架构整洁之道--第五部分--摘抄

tagline: "Supporting tagline"
category : 软件工程
tags : [architecture, 架构]

---
{% include JB/setup %}

* toc
{:toc}

本文是我在读《架构整洁之道》时感觉到很精彩的片段的摘抄，摘抄保留了原书的目录结构。


依赖的是该书[在线中文对照版本][0]。

初学架构，迫使自己换种思路思考软件开发，受益良多。该书精彩论述太多，有时候未免像是整个抄书：）
<hr/>

# 五-软件架构

## 15. 什么是软件架构

The purpose of that shape is to facilitate the development, deployment, operation, and maintenance of the software system contained within it.

	而设计软件架构的目的，就是为了在工作中更好地对这些组件进行研发、部署、运行以及维护。

<hr >

The strategy behind that facilitation is to leave as many options open as possible, for as long as possible.

	如果想设计一个便于推进各项工作的系统，其策略就是要在设计中尽可能长时间地保留尽可能多的可选项。

<hr >
Their troubles do not lie in their operation; rather, they occur in their deployment, maintenance, and ongoing development.

	真正的麻烦往往并不会在我们运行软件的过程中出现，而是会出现在这个软件系统的开发、部署以及后续的补充开发中。

The impact of architecture on system operation tends to be less dramatic than the impact of architecture on development, deployment, and maintenance. Almost any operational difficulty can be resolved by throwing more hardware at the system without drastically impacting the software architecture.

	软件架构对系统运行的影响远不及它对开发、部署和维护的影响。几乎任何运行问题都可以通过增加硬件的方式来解决，这避免了软件架构的重新设计。

<hr >
Having said that, there is another role that architecture plays in the operation of the system: A good software architecture communicates the operational needs of the system.

	即使这样，软件架构在整个系统运行的过程中还发挥着另外一个重要作用，那就是一个设计良好的软件架构应该能明确地反映该系统在运行时的需求。

All software systems can be decomposed into two major elements: policy and details. The policy element embodies all the business rules and procedures. The policy is where the true value of the system lives.

<hr >
	基本上，所有的软件系统都可以降解为策略和细节这两种主要元素。策略体现的是软件中所有的业务规则与操作过程，因此它是系统真正的价值所在。

The goal of the architect is to create a shape for the system that recognizes policy as the most essential element of the system while making the details irrelevant to that policy. This allows decisions about those details to be delayed and deferred.
	
	软件架构师的目标是创建一种系统形态，该形态会以策略为最基本的元素，并让细节与策略脱离关系，以允许在具体决策过程中推迟或延迟与细节相关的内容。

### 理解

细节与策略是相对的，很大程度上跟我们的软件目的相关，有时候一些细节是软件目的引入的，软件目的引入的细节不再是细节。

与软件目的直接或间接相关的是策略问题要思考，不相关的才是细节问题。比如在HTTP上实现某某某，HTTP就是一个直接相关的策略，HTTP标准协议规定的东西都不再是细节，这时候我们没得选，科技再发达我们也没得选。又比如要求在毫秒级别返回一个用户的所有数据，那么就应该把这些数据放在一台计算机上的内存中，而不是放在多台机器的硬盘上，这些就是跟目标间接相关的策略，因为在当下现实的世界里，只能做么做，将来科技发展了，可能放在多台机器上也可行，但设计架构不是写小说，要切实可行。

具体的例子比如，RFC6749规定OAuth2.0的协议，该协议目的就是在Http之上提供一个可靠安全的三方授权方案。Http协议就是其目的引入的细节，
在此基础上设计协议的时候可以直接将重定向、锚点等http技术细节纳入设计，因为这时候它们不再是可选的细节，这时候没得选。

细节决策总是在最后才做出的。什么叫最后？我理解就是‘临时抱佛脚”那种最后，当然我们不是真的“报佛脚”。这里面有设计到一个设计原则的问题，当我们最后做细节决策的时候，尽量将其实现成“给我一个决策”而不是“找到一个绝测“，这意味着做细节决策本身也是被封装起来的。

<hr />

该章节关于开发的论述很精彩，为了不影响摘抄的简洁性又不牺牲这些精彩的论述，这里特把整节放在这儿：

A software system that is hard to develop is not likely to have a long and healthy lifetime. So the architecture of a system should make that system easy to develop, for the team(s) who develop it.

	一个开发起来很困难的软件系统一般不太可能会有一个长久、健康的生命周期，所以系统架构的作用就是要方便其开发团队对它的开发

Different team structures imply different architectural decisions. On the one hand, a small team of five developers can quite effectively work together to develop a monolithic system without well-defined components or interfaces. In fact, such a team would likely find the strictures of an architecture something of an impediment during the early days of development. This is likely the reason why so many systems lack good architecture: They were begun with none, because the team was small and did not want the impediment of a superstructure.

	这意味着，不同的团队结构应该采用不同的架构设计。一方面，对于一个只有五个开发人员的小团队来说，他们完全可以非常高效地共同开发一个没有明确定义组件和接口的单体系统（monolithic system）。事实上，这样的团队可能会发现软件架构在早期开发中反而是一种障碍。这可能就是为什么许多系统都没有设计一个良好架构的原因，因为它们的开发团队起初都很小，不需要设计一些上层建筑来限制某些事情。

On the other hand, a system being developed by five different teams, each of which includes seven developers, cannot make progress unless the system is divided into well-defined components with reliably stable interfaces. If no other factors are considered, the architecture of that system will likely evolve into five components—one for each team.

	但另一方面，如果一个软件系统是由五个不同的团队合作开发的，而每个团队各自都有七个开发人员的话，不将系统划分成定义清晰的组件和可靠稳定的接口，开发工作就没法继续推进。通常，如果忽略其他因素，该系统的架构会逐渐演变成五个组件，一个组件对应一个团队。

Such a component-per-team architecture is not likely to be the best architecture for deployment, operation, and maintenance of the system. Nevertheless, it is the architecture that a group of teams will gravitate toward if they are driven solely by development schedule.

	当然，这种一个组件对应一个团队的架构不太可能是该系统在部署、运行以及维护方面的最优方案。但不管怎样，如果研发团队只受开发进度来驱动的话，他们的架构设计最终一定会倾向于这个方向。

实际上，这部分论述与“康威定理”关系密切：

Conway’s law: Organizations which design systems[...] are constrained to produce designs which are copies of the communication structures of these organizations.

	设计系统的组织，其产生的设计和架构等价于组织间的沟通结构

我们希望这种等价性是组织服从于软件架构，而不是组织挟持软件架构，后者常常是因为懒惰草率的架构设计。软件架构跟软件关系不大，跟“软”关系很大，是团队合作问题。

### 总结
架构目标：最大限度的方便运行（系统的用例与正常运行）、开发、部署、维护。

使结构灵活的策略或原则：尽可能长时间的保持最多的开放选项

实现上述策略的思考方法：区分系统中的策略与细节（策略与细节是相对的，明确所开发软件的目的才能区分策略与细节）。

软件的目的不是玄幻、缥缈的，软件的目的可以用所有用例集合来描述，即便用例不全，我们也应该弄清楚软件的设计意图。

## 16. 独立性

As we previously stated, a good architecture must support:
* The use cases and operation of the system.
* The maintenance of the system.
* The development of the system.
* The deployment of the system.

```
正如我们之前所述，一个好的架构必须支持：
	系统的用例与正常运行。
	系统的维护。
	系统的开发。
	系统的部署。
```

<hr >

A good architecture balances all of these concerns with a component structure that mutually satisfies them all. Sounds easy, right? Well, it’s easy for me to write that.

	一个设计良好的架构应该充分地权衡以上所述的所有关注点，然后尽可能塔成一个可以同时满足所有需求的组件结构。这说起来还挺容易的，不是吗？

The reality is that achieving this balance is pretty hard. The problem is that most of the time we don’t know what all the use cases are, nor do we know the operational constraints, the team structure, or the deployment requirements. Worse, even if we did know them, they will inevitably change as the system moves through its life cycle. In short, the goals we must meet are indistinct and inconstant. Welcome to the real world.

	事实上，要实现这种平衡是很困难的。主要问题是，我们在大部分时间里无法预知系统的所有用例的，而且我们也无法提前预知系统的运行条件、开发团队的结构，或者系统的部署需求。更糟糕的是，就算我们能提前了解这些需求，随着系统生命周期的演进，这些需求也会不可避免地发生变化。总而言之，事实上我们想要达到的目标本身就是模糊多变的。真实的世界就这样。

<hr >
You can see the pattern here. If you decouple the elements of the system that change for different reasons, then you can continue to add new use cases without interfering with old ones. If you also group the UI and database in support of those use cases, so that each use case uses a different aspect of the UI and database, then adding new use cases will be unlikely to affect older ones.

	由此，我们可以总结出一个模式：如果我们按照变更原因的不同对系统进行解耦，就可以持续地向系统内添加新的用例，而不会影响旧有的用例。如果我们同时对支持这些用例的 UI 和数据库也进行了分组，那么每个用例使用的就是不同面向的 UI 与数据库，因此增加新用例就更不太可能会影响旧有的用例了。

<hr />

So long as the layers and use cases are decoupled, the architecture of the system will support the organization of the teams, irrespective of whether they are organized as feature teams, component teams, layer teams, or some other variation.
	
	只要系统按照其水平分层和用例进行了恰当的解耦，整个系统的架构就可以支持多团队开发，不管团队组织形式是分功能开发、分组件开发、分层开发，还是按照别的什么变量分工都可以。

<hr />

Architects often fall into a trap—a trap that hinges on their fear of duplication.
	
	架构师们经常会钻进一个牛角尖——害怕重复。

But there are different kinds of duplication. There is true duplication, in which every change to one instance necessitates the same change to every duplicate of that instance. Then there is false or accidental duplication. If two apparently duplicated sections of code evolve along different paths—if they change at different rates, and for different reasons—then they are not true duplicates. Return to them in a few years, and you’ll find that they are very different from each other.

	但是重复也存在着很多种情况。其中有些是真正的重复，在这种情况下，每个实例上发生的每项变更都必须同时应用到其所有的副本上。重复的情况中也有一些是假的，或者说这种重复只是表面性的。如果有两段看起来重复的代码，它们走的是不同的演进路径，也就是说它们有着不同的变更速率和变更缘由，那么这两段代码就不是真正的重复。等我们几年后再回过头来看，可能就会发现这两段代码是非常不一样的了。

<hr />

There are many ways to decouple layers and use cases. They can be decoupled at the source code level, at the binary code (deployment) level, and at the execution unit (service) level.

	按水平分层和用例解耦一个系统有很多种方式。例如，我们可以在源码层次上解耦、二进制层次上解耦（部署），也可以在执行单元层次上解耦（服务）。

it’s hard to know which mode is best during the early phases of a project. Indeed, as the project matures, the optimal mode may change.

	在项目早期很难知道哪种模式是最好的。事实上，随着项目的逐渐成熟，最好的模式可能会发生变化。

My preference is to push the decoupling to the point where a service could be formed. should it become necessary; but then to leave the components in the same address space as long as possible. This leaves the option for a service open.

	通常，我会倾向于将系统的解耦推行到某种一旦有需要就可以随时转变为服务的程度即可，让整个程序尽量长时间地保持单体结构，以便给未来留下可选项。

### 理解


架构要支撑起运行。但很多用例涉及到性能指标或者安全指标，性能与安全似乎总是与实现细节相关的，细节又不再架构的考虑范围之内。在思考架构的时候如何处理这部分矛盾呢？

其实是这样的，系统架构对于软件编码来说是上层抽象，在架构设计中涉及到性能或安全问题的时候其实可以看做是软件目的引入的细节。这个时候就要看引入的细节到底有多细，然后需要去找该细节对应的上层抽象就可以了，这也是我们的系统边界。但是千万不要随意的扩大或缩小软件目的引入的细节。

安全问题与安全指标我不熟悉，我们以性能指标为例。

所有的性能问题无外乎吞吐量与延迟两个指标，再抽象的看这两个指标，它们都是数据的处理速度指标。

抽象的看数据的处理就是：汇集输入数据->算法->汇集结果展现--这样一个过程，这里的输入与输出是系统边界上的输入与输出。

通常来说，数据越放在一起收集起来越快，因此性能指标对应的抽象是数据放在单台计算机上、单个进程还是单个线程上这样的抽象层次或者是永久存储还是内存这样的抽象层次。这要求系统架构师明白这些抽象层次上的性能数量级，比如CPU对缓存的执行时间在纳秒级别，读取磁盘的基本在毫秒级别。

但是，对于分布式系统中问题而言，分布式算法与集中式算法需要汇集的输入往往是不同，对于这样的架构性能问题要引入具体的算法吗？当然不，我们只需要考虑支撑我们的用例性能指标需要汇集多少台计算机上的数据作为输入即可。


<hr />
架构的4个目标上实际上各有专人负责：

* 支持用例运行：产品经理
* 开发、部署：项目经理、开发工程师
* 维护：产品经理、开发、运维工程师

架构的工作与他们的边界是什么？产品经理负责对接用户、整理需求。架构则根据软件目的（需求、用例）拆分成组件，使得各部分开发、部署、维护顺利进行。项目经理负责协调资源、监督开发进度。工程师负责实现与细节。(能用用例表现一下各位置的工作职责吗)

<hr />

这一章触及了一些真正的现实难题：架构设计时并不知道全部的用例，需求会变化，用例会变化，因此我们需要一定的解耦原则。解耦的原则确定了，如何确定解耦的粒度呢？实际上没有最好的粒度，粒度是会变化的，。架构应该是动态发展的。

这一章的题目为什么叫独立性呢？看起来软件架构的4个目标定义很清晰，但是实际中我们可能连系统的用例是什么都不清除，这时候依然有一些成本较低的原则使得我们能做出良好的设计。这些原则背后的关键词就是独立性或者说解耦。


用例解耦（垂直解耦比较好理解），那么怎么理解分层解耦呢？


<hr />

解耦通常意味着消除重复与责任集中，但重复有必要区分是真正的重复还是表面重复。

<hr />

面向服务的架构（SOA）与架构的关系就像是面向对象编程与编程的关系，仅仅是工具，不是目的。

### 总结
应对用例的变化：解耦

没有最好的解耦的粒度，只有刚好够用的解耦粒度。

解耦粒度是会变化的，架构应预料到解耦粒度的变化。

## 17. 划分边界

To draw boundary lines in a software architecture, you first partition the system into components. Some of those components are core business rules; others are plugins that contain necessary functions that are not directly related to the core business. Then you arrange the code in those components such that the arrows between them point in one direction—toward the core business.

	为了在软件架构中画边界线，我们需要先将系统分割成组件，其中一部分是系统的核心业务逻辑组件，而另一部分则是与核心业务逻辑无关但负责提供必要功能的插件。然后通过对源代码的修改，让这些非核心组件依赖于系统的核心业务逻辑组件。

You should recognize this as an application of the Dependency Inversion Principle and the Stable Abstractions Principle. Dependency arrows are arranged to point from lower-level details to higher-level abstractions.

	其实，这也是一种对依赖反转原则（DIP）和稳定抽象原则（SAP）的具体应用，依赖箭头应该由底层具体实现细节指向高层抽象的方向。

### 理解

这一章作者先举了两个坏例子，然后再举了一个成功的例子，坏例子描述的并不是特别清晰，当然这也不重要。

重要的是作者后面讲的业务逻辑与数据库、GUI的关系，以及由此引申出的插件式架构。

首先一个问题：划分谁的边界？

我想应该是架构整体的边界以及架构内各组件之间的边界，这二者是类似的，只是颗粒度的不同。

第二个问题：边界划分在哪里？

原文是“You draw lines between things that matter and things that don’t. ”。听起来就是废话，因为问题变成了哪些是重要的，哪些是不重要的。这里我想可以
用16章的内容来理解，与我们的软件目的（或业务逻辑的核心目标）直接相关的就是重要的，间接相关的就是不重要的。
看上去还是有点抽象，但让我们再想想软件目的由什么定义：由用例定义。用例会关心数据库吗？一般客户不会关心这个的，或者没有充分的理由要求这个。


这里作者举的例子是业务逻辑与数据库的划分边界。一个小问题就是其中的“Database 组件知道 BusinessRules 组件的存在，而 BusinessRules 组件则不知道 Database 组件的存在”以及“Database 组件却不能脫离 BusinessRules 组件而存在”。其实这里结合下一章的“跨边界调用”更好理解一些，这里的就是“跨边界调用”中依赖反转的例子，到下一章我们再细说。根据“跨边界调用”那一节可以想到，其实这章里数据库与GUI的两个例子不是随便选的，它们恰好各是“跨边界调用”的两种形式。

第三个重点：数据库、GUI是IO，作者由此推广出结论：对于核心业务逻辑而言，所有的IO都不重要。


插件式架构：书中并没有给出插件式架构的具体定义，但我们可以大致推测出其样子。重要的是意识到，插件作为主要业务逻辑的扩展，必然是被主要业务逻辑调用同时又调用主要业务逻辑的某种服务，我们必须在插件与主要业务逻辑直接的两种方向的调用直接划好边界，并使用下一章所描述的两种跨边界调用的方式处理好依赖关系：使得插件依赖于主要业务逻辑而不存在反过来的情况。


### 总结
暂无。

## 18. 边界剖析

### 理解

#### 跨边界调用

在“可怕的单体结构”小节中，作者举了两个例子，一个是低层的客户端调用高层的服务，调用方向与依赖方向是一致的。另一个是高层的客户端调用低层的服务，
调用方向与依赖方向是相反的。第二个例子就是所谓的依赖反转的情况。

通俗一点的说，第一种情况是我调用由别人定义并实现的服务，因而我完全依赖于别人的定义。第二种情况是，我自己定义一套我需要的服务接口，具体的实现由多态在运行时寻找，因而我不依赖于别人的定义或实现。

之所以要有这种依赖反转的情况，原因在于要保证：不重要的组件依赖于重要的组件，低层的组件依赖于高层的组件，辅助组件依赖于核心组件--这些方向性才是关键。

这里的难理解的地方在于“低层与高层”，怎么一会客户端是低层，一会儿客户端又是高层呢？我们在下面小节“层次的划分”中再解释。


#### 物理边界

注意，本章中“单体结构”、“部署组件”、“线程”、“进程”、“服务”各小节是并列的。

所谓单体结构就是指的静态链接成一个软件。

部署组件结构指的是动态链接形成一个软件。

单体结构与部署组件结构都是运行在一个进程、一个地址空间之中。

线程不属于架构边界也不属于部署单元，书中提到应该仅仅是为了区分于进程。

本地进程，确切的讲，应该叫本地多进程。书中明确提到了“系统架构的设计目的是让低层进程称为高层进程的一个插件”。

服务，则是不同机器上的服务，每个服务都可能包括多个进程。

从单体结构--单进程部署组件--本地多进程--服务，结构复杂度是逐渐增加的。但不论怎么，低层次依赖于高层次的原则不会变。


#### 层次的划分

无论是“跨边界调用”小节还是“物理边界”小节，都提到了低层次依赖于高层次。这似乎与我们通常理解的高层次构建于（依赖于）低层次不一样。

原因在于高低层次的定义不一样。通常我们讲的高层次依赖于低层次，其中一种意义指的是函数调用，A调用B，则A依赖于B，B的变动必然影响A，A是高层，B是低层，这没有问题。但软件架构中，高低层的定义并不同，其实书中明确的层次划分解释应该在22章，大意是越靠近业务逻辑的，其层次越高。

在这种划分中，层次变成了一个主观的概念。想象一下，Linux桌面系统与内核分别由两个团队研发，在内核团队看来，内核是高层次，桌面是低层次，因此内核不应该依赖于桌面，而桌面可以依赖于内核。但在桌面团队看来，桌面系统是高层次，内核系统是低层次，因此桌面系统不应该依赖于内核，而内核系统可以依赖于桌面。那么谁对谁错呢？我想两边都是部分对的。理想的情况应该是桌面与内核不互相依赖，桌面不依赖于内核意味着桌面系统本身对于内核服务有自己的抽象层，内核不依赖于桌面则是很自然的情况，因为内核不会是交互的发起方。

### 总结

暂无。


## 19. 策略与层次
A strict definition of “level” is “the distance from the inputs and outputs.” The farther a policy is from both the inputs and the outputs of the system, the higher its level. The policies that manage input and output are the lowest-level policies in the system.

	我们对“层次”是严格按照“输入与输出之间的距离”来定义的。也就是说，一条策略距离系统的输入/输出越远，它所属的层次就越高。而直接管理输入/输出的策略在系统中的层次是最低的。


## 20. 业务逻辑

## 21. 尖叫的软件架构

## 22. 整洁架构

未完待续。


[0]:https://www.bookstack.cn/read/Clean-Architecture-zh/docs-ch17.md