javascript中的异步

https://www.jianshu.com/p/c198638d70e3

https://blog.csdn.net/clschen/article/details/51727599

https://zhuanlan.zhihu.com/p/26567159


下面这段代码中创造done的用法
```
function loading_image(src){
	var img = new Image();
	img.src = src;

	return{
		done:function(f,p){
			img.onload = function(){
				f(img,p);
			};
			img.onerror = function(){
				console.log("load", src, "error");
			}
		}
	}
}

loading_image(src).done(function(img, p){
	
});
```

js中的几种异步编程模型：
http://blog.codingplayboy.com/article/125
https://zhuanlan.zhihu.com/p/26567159


## 回调函数

## Promise

## 发布订阅者模式

## Generator

## Async、wait
https://blog.pusher.com/promises-async-await/
https://segmentfault.com/a/1190000007535316
https://hackernoon.com/javascript-promises-and-why-async-await-wins-the-battle-4fc9d15d509f