---
layout: post
category : web
tagline: "Supporting tagline"
tags : [javascript, language]
title: javascript闭包的对外变量引用
---
{% include JB/setup %}

<hr />

闭包的概念相信并不陌生，但是偶尔不注意也会踩到大坑。看下面这样一个例子：

<pre class="brush:javascript;">
foos=[]
lst = [[1,2],[2,3],[3,4]]

for (i in lst) {
	p = lst[i];
	foos.push(function (f){
		f(p);
	});
}

for (i in foos){
	foos[i](function(i){
		console.log(i);
	});
}
</pre>

代码的逻辑非常简单，首先在`foos`数组中放入函数对象，该函数对象引用外部for循环中一个变量p。简言之，将lst的元素作为参数与foos中的函数一一配对。
然后依次调用foos中的函数。

然而，这段代码的输出并不会向我们想的那样是:

```
[1,2]
[2,3]
[3,4]
```

而是：

```
[3,4]
[3,4]
[3,4]
```
原因是什么呢？原因在于两个被混淆的场景：闭包中可以引用闭包外变量，而这种引用误以为与函数传参机制相同（传值，传引用）。

确实，在适用于传值的时候，两者机制是相同的。比如上面代码可以改成如下就能正确输出：
<pre class="brush:javascript;">
foos=[]
lst = [[1,2],[2,3],[3,4]]

for (i in lst) {

	foos.push(function (f){
		f(lst[i]); // not p, but lst[i]
	});
}

for (i in foos){
	foos[i](function(i){
		console.log(i);
	});
}
</pre>
这时候的i是值传递，也就是代码运行到第6行生成的闭包类似于下面这样：
<pre class="brush:javascript;">
function (f){
		f(lst[0]); 
}

function (f){
		f(lst[1]); 
}

function (f){
		f(lst[2]); 
}

</pre>

所以能产生正确的结果，但在第一种情况下，生成的闭包是类似于下面这样：
<pre class="brush:javascript;">
function (f){
		f(p); // p --> outer-scope[p]
}
</pre>
此时并不像函数参数传引用那样：p分别保留了lst中三个元素的引用。而是p就指向其外部作用域中的p，而外部作用域中的p是一个随时会变化的量。
也就是这时候的p引用类似于c++中的别名引用。

由此我们可以知道，要避免函数闭包中对外引用的变量的变化，引用闭包外变化的量最好是值传递类型的。若不得不引用闭包外变化的且是引用传递的变量，则最好不要用闭包而采用
函数传参的方式，如下：
<pre class="brush:javascript;">
foos=[]
function put(f,p){
	foos.push(function(){
		f(p);
	});
}


lst = [[1,2],[2,3],[3,4]]
for (i in lst) {
	p = lst[i];
	put(function(p){
		console.log(p);
	}, p);
}

for (i in foos){
		foos[i]();
}
</pre>

上面例子中最后函数执行的时候，p引用的是put函数的参数，而put函数的参数是在for循环中传引用传过去的，也就是分别引用了lst数组的三个元素。

类似的事情还发生在setTime等异步执行的函数引用外部变量的时候。尤其是Promise的then函数中（Promise规范规定回调必须异步调用），比较隐蔽。

与python中闭包对外引用机制对比如何？
