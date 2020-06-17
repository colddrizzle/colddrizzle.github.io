---
layout: post
title: 理解Promise及其实现
description: ""
category: web
tags: [javascript]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 回调嵌套

在讨论这个问题之前，我们不得不注意到javascript的语言特性和运行环境：javascript是单线程的。鉴于此，对于经常遇到的一些耗费时间的操作，系统
层面往往提供了异步实现方式，比如图片加载与ajax调用。

	前者提供了onloading与onerror注册机制，后者提供了XmlHttpRequest。XmlHttpRequest可以指定同步或者异步工作模式，在异步的时候，提供了
	onreadystatechange注册机制。

之所以提供异步机制，究其原因是因为javascript是单线程的。若是同步操控则会照成整个页面卡住的情况，这往往不是我们想要的结果。

	Html5提供了WebWorker多线程机制，但这属于H5，不属于javascript自己的方案。
	这种异步操作的大体实现机制：注册函数相应后强行插入当前的执行逻辑中吗，毕竟是单线程。


题外话：关于异步函数什么时候执行的问题可以参考[segmentfault回答][1]以及其中提到的书"你不知道的javascrip"和这篇文章[Tasks, microtasks, queues and schedules][2]。
简而言之，就是宿主环境判定主线程空闲的时候执行，判定主线程空闲依据任务队列而来。也就是通常来说，会在主线程执行末尾开始执行回调，除非主线程中有一个延时很长的setTimeout之类的，使得主线程交出了CPU。

但是有时候同步操作又是我们想要的，比如我有一个页面，会动态地根据用户的操作从服务器上加载一些图片，然后对这些图片进行操作。在javascript中，加载图片很简单，利用浏览器内置的Image对象：

<pre class="brush:javascript;">
var img = new Image();
img.src = src;

//process_img();
</pre>

但是在浏览器的实现中，图片加载却是个异步操作，也就是浏览器另用一个线程来加载图片，因此执行完`img.src = src`之后并不能立刻对图片进行操作，执行`process_img()`会出错。为此，浏览器提供了`onload`与`onerror`机制。如下：

<pre class="brush:javascript;">
var img = new Image();
img.src = src;

img.onload = process_img;

//do_something_after_process_img();

</pre>

注意，`onload`是个异步调用注册机制，该行执行完成后仅仅是挂个回调函数，`process_img`的实际操作并未执行。
因此，依赖于`process_img`处理结果的`do_something_after_process_img()`执行会出现问题。

这时候很自然的想到，把这部分逻辑放到`process_img`的逻辑中。但这样做一来函数合并职责划分不清，二来这个`do_something_after_process_img()`往往是动态的，
我们编码时并不知道。因此，合理的做法是给`process_img()`添加一个回调函数作为参数。

<pre class="brush:javascript;">
var img = new Image();
img.src = src;

img.onload = function(){
	process_img(do_something_after_process_img);
}
</pre>

回调函数往往是处理异步执行结果的方法。但是当回调函数中还包含异步执行需要回调函数套用回调函数的时候，We mess up. 让我们来看一下。

若是`process_img`本身内部要包含一个异步操作呢? 则无论合并函数还是提供回调函数都行不通。当然其内部异步操作也可以提供异步回调注册机制，不妨说就是
`onfinish`。这时候我们的代码差不多是这样的:

<pre class="brush:javascript;">
var img = new Image();
img.src = src;

function process_img(){
	async_process.onfinish = something_after_async_process_0;

	async_process();
}

img.onload = process_img;

</pre>

继续，如果something_after_async_process_0中还要异步操作呢？

<pre class="brush:javascript;">
var img = new Image();
img.src = src;

function something_after_async_process_0(){
	
	//do something

	async_process_1.onfinish = something_after_async_process_1;

	async_process_1();

	//do something
}

function process_img(){

	//do something

	async_process_0.onfinish = something_after_async_process_0;

	async_process_0();

	//do something
}

img.onload = process_img;

</pre>

上面的代码还不是最反直觉的，回调函数通常是匿名函数作为参数传入异步调用中，而不是像上面那样有个注册机制、有个命名函数。于是我们的代码变为如下这样：
<pre class="brush:javascript;">
var img = new Image();
img.src = src;

img.onload = function(){ 		   //process_img
	async_process_0(function(){	   //something_after_async_process_0
		async_process_1(function(){//something_after_async_process_1

		});
	});
};

</pre>

可想而知，若是嵌套层数一多，代码会变的多丑。

## 区分回调、异步调用与回调嵌套症结

异步调用与回调存在一些细微的区别：异步调用更强调调用方不需要等待漫长的执行过程可以立刻返回，强调不阻塞，
而回调则强调函数调用者为对方，函数效果在己方。二者之所以一起提起在于异步调用的结果可以通过回调来告知，但是也可以通过发消息检查消息来获知。
所以异步调用与回调并不是一定是绑定的。异步调用和回调都可以单独存在，并不互相依赖。

在javascript的情景下，二者通常是绑定的，虽然有时看上去不那么明显，比如
<pre class="brush:javascript">
	var img = new Image();
	img.src = src;
</pre>
上面的代码隐式地开始了一个异步图片加载过程。

虽然如此，上面的情景中主要问题在于匿名函数回调嵌套，跟异步调用无关。

那为什么要回调嵌套呢？因为我们想绑定一些逻辑到回调函数之后再在执行，但是我们不知道回调函数何时执行。如果有其他方式来实现这一点
显然我们就不需要回调嵌套了。所以问题核心在于回调函数的顺序依赖。

解决回调函数依赖顺序问题，几乎可以立刻构想出这样一种方案，就是用一个队列，依次存放各个回调函数及其结果。
执行下一个回调函数之前，先检查前一个回调是否有结果。这里的问题就是我们并不知道下一个回调函数何时调用，
因此当下一个回调函数执行前，若是前一个回调尚且没有结果，就需要等待，等待的方法是就是定时检查（这个定时检查可以是同一个线程也可以是另一个线程）。
这个基本上就是Promise的思路。

另外一个解决回调函数依赖顺序的问题就是不使用回调函数，全部变为同步阻塞调用。解决上面提出的图片加载问题，初步接触前端script的人很容易陷入这种思维中
，试图找一个类似sleep()的方法，然而web端的并发模型与OS里截然不同，就陷入了思维困境。

#### 解决异步回调深层次嵌套的其他方式：
http://www.fly63.com/article/detial/2944

https://blog.csdn.net/sz85850597/article/details/86550728

## promise

上面我们讲到，Promise就是为了解决回调嵌套而生的，也就是如下流程：
```
回调嵌套导致代码丑陋--->核心在于回调依赖顺序问题--->Promise另辟蹊径解决这个问题从而得以更简洁的方式编码
```
但需要注意的是Promise并不仅仅是为了解决回调嵌套而诞生，回调嵌套的根本原因在于匿名函数使用，像上面不使用匿名函数
代码其实是可以不写成“金字塔嵌套”形式的，但是使用Promise可以使其在简洁地使用匿名函数的情况下也变得清晰优雅。
再一个，promise仅仅是为了[能写出干净整洁的代码而发明的][4], promise并没有解决回调本身的一些固有难题，比如信任问题。
所以[这里][5]说能解决信任问题的观点是不对的（好像里面的promise实现也不对）。关于为什么我们需要Promise，可以参考[这里][3]。


Promise的语法与用法不再赘述，可以参考[这里][0]。需要注意的是resolve指的是决议，fulfilled才是promise满足的状态。
因为有些时候是不知道promise状态是否满足的。有两种情况：
* promise本身自不用说是个promise，但promise异步调用又返回一个promise，则promise的状态需要决议
* promise的then返回一个promise，但如果promise回调函数里本身就返回一个promise。则then返回的promise状态就需要决议。

决议过程可以参考Promise/A+规范，下面会在提到。

接下来我们分析下Promise做了什么以及是怎么实现的。

## promise实现

根据Promise的用法，可以推想出如下结论：
1. Promise通过用户自己调用resolve和reject得知异步操作是否完成
2. Promise调用then的时候，then里面的逻辑不会立刻执行，而是等待resolve与reject的调用
3. Promise的then中需要一种方式实现这种等待
4. Promise创建后用户异步代码立刻被执行，但是调用then的时候异步代码未必执行完
5. then返回的依然是一个promise，但是是一个状态为resolve或者reject的Promise
6. then返回的promise可以多次调用then方法，相当于一个Immutable对象
7. then返回的reject状态的Promise，then的第一个参数不会去处理它
8. then之后再调用then，则后一个then相当于前一个then的回调函数。
9. Promise对象需要一种方式把异常传下去，直到有人处理他


如果我们要自己模拟Promise的实现，难处理的点在 结论3：要实现等待。javascript没有提供sleep或协程中那种线程主动放弃CPU的手段，也没有goto这种可以跨函数调用栈的语法。
而要是用死循环来模拟等待的话，主线程就不会空闲下来，毕竟javascript是单线程。根据[Tasks, microtasks, queues and schedules][2]这里的描述，
主线程不空闲下来，异步回调的逻辑就不会执行，因此死循环等待也不行。

promise使用的方法就是在promise内部注册一个Timer函数，不停的检查当前Promise状态。then作为前一个promise是回调函数，注册在前一个promise的callbacks队列内（当然前一个promise状态是fulfilled或rejected状态就不需要注册了，直接调用就好了，但promise规范要求其异步执行，后面会讲）。

上面我们讲解决回调函数依赖顺序问题时讲到可以使用一个队列，但这个队列在promise中是隐式实现的，如下图里，下一个then链接到上一个promise的callbacks形成队列。注意其中的callbacks本身也是一个队列，因为一个promise可以多次调用then。

![img](/assets/resources/promise-structures.jpeg){:width="100%"}

完整规范可以参考：

[Promises/A+官方规范](https://promisesaplus.com/)

[Promises/A+规范翻译](https://www.cnblogs.com/fsjohnhuang/p/4139172.html)

实现参考：

[本文主要参考实现](https://www.jianshu.com/p/459a856c476f) 里面提到了一个npm里的promise规范测试套件，可以用来测试自己实现的
promise是否符合规范。原地址中的代码也可从[这里](/assets/resources/source/Promise.js)下载。

[辅助参考](https://www.freecodecamp.org/news/how-javascript-promises-actually-work-from-the-inside-out-76698bb7210b/)

[辅助参考](https://juejin.im/post/5a30193051882503dc53af3c)


[0]:https://www.runoob.com/w3cnote/javascript-promise-object.html
[1]:https://segmentfault.com/q/1010000011078470
[2]:https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules
[3]:https://runnable.com/blog/5-reasons-why-you-should-be-using-promises
[4]:https://stackoverflow.com/questions/39004567/why-do-we-need-promise-in-js
[5]:https://zhuanlan.zhihu.com/p/26815654


