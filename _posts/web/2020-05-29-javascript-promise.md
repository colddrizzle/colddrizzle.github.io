---
layout: post
title: Promise由浅入深：从图片同步加载说开去
description: ""
category: web
tags: [javascript]
---
{% include JB/setup %}


在讨论这个问题之前，我们不得不注意到javascript的语言特性和运行环境：javascript是单线程的。鉴于此，对于经常遇到的一些耗费时间的操作，系统
层面往往提供了异步实现方式，比如图片加载与ajax调用。

	前者提供了onloading与onerror注册机制，后者提供了XmlHttpRequest。XmlHttpRequest可以指定同步或者异步工作模式，在异步的时候，提供了
	onreadystatechange注册机制。

之所以提供异步机制，究其原因是因为javascript是单线程的。若是同步操控则会照成整个页面卡住的情况，这往往不是我们想要的结果。

	Html5提供了WebWorker多线程机制，但这属于H5，不属于javascript自己的方案。
	这种异步操作的大体实现机制：注册函数相应后强行插入当前的执行逻辑中吗，毕竟是单线程。

但是有时候同步操作又是我们想要的，比如我有一个页面，会动态地根据用户的操作从服务器上加载一些图片，然后对这些图片进行操作。在javascript中，加载图片很简单，利用浏览器内置的Image对象：

<pre class="brush:javascript;">
var img = new Image();
img.src = src;

//process_img();
</pre>
但是在浏览器的实现中，图片加载却是个异步操作，也就是`img.src = src`之后并不能对图片进行操作，图片仍在加载中，执行`process_img()`会出错。
为此，浏览器提供了`onload`与`onerror`机制。如下：

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
	async_process_1.onfinish = something_after_async_process_1;

	async_process_1();
}

function process_img(){
	async_process_0.onfinish = something_after_async_process_0;

	async_process_0();
}

img.onload = process_img;

</pre>

上面的代码还不是最反直觉的，异步调用的回调函数通常是匿名函数作为参数传入异步调用中，而不是像上面那样有个注册机制、有个命名函数。于是我们的代码变为如下这样：
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

但其实我们可以稍微包装下`onload`机制:
<pre class="brush:javascript;">
function load_image(src){
	var img = new Image();
	img.src = src;

	return {
		then:function(ok_foo){
			img.onload = ok_foo;

			return {
				except:function(error_foo){
					img.onerror = error_foo;
				}
			}
		}
	}
}

load_image("src").then(function(){
	process_img();
}).except(function(){
	//process_error
});

</pre>


<pre class="brush:javascript;">

function some_callback_registry(callback);

function MyPromise(){

	return {
		then:function(postaction){
			some_callback_registry(postaction);
		}
	}
}

</pre>

本文参考：
https://blog.csdn.net/xiaopeng_han123/article/details/86471579
https://segmentfault.com/a/1190000005078431
https://www.runoob.com/w3cnote/javascript-promise-object.html
https://segmentfault.com/a/1190000017312249
实现参考：
https://zhuanlan.zhihu.com/p/26815654
https://www.cnblogs.com/goloving/p/9297308.html


解决异步回调深层次嵌套的其他方式：
http://www.fly63.com/article/detial/2944
https://blog.csdn.net/sz85850597/article/details/86550728
