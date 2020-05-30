javascript中的异步

https://www.jianshu.com/p/c198638d70e3

https://blog.csdn.net/clschen/article/details/51727599


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