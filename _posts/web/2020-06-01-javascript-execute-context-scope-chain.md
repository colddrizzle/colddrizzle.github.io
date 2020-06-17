执行上下文 与作用域链


如何解释下面的代码执行结果
<pre class="brush:javascript">
function A(func){
	function C(){
		console.log(1);
	}
	a = 1;
	func();
}

A(function(){
	C();		//能访问到C

	console.log(a); //访问不到a
});
</pre>

https://www.cnblogs.com/wilber2013/p/4909459.html