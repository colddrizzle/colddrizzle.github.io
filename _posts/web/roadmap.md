常见的web安全问题 这些安全问题框架也好 浏览器也好都已经注意到了且有想要的解决方案 因此我们只需要理解就好


重复点击问题

同时登陆问题

VS code运行javascript：https://www.zhihu.com/question/271734418


JS中lambda函数好奇怪：
1. A = (()=>{xxx});这样声明的函数不能作为构造函数
2. 在原型上添加的lambda函数，在通过对象调用时其this不指向调用对象，而是指向Object
3. lambda声明的函数其没有prototype属性，不能再prototype上指派属性与函数

https://blog.csdn.net/lincifer/article/details/53191961

调用textarea.value并不会触发oninput事件，这有时候带来便利，但有时候我们希望能手动触发该事件。参考下面例子
https://blog.gxxsite.com/manual-trigger-oninput-event/


网络安全：
为什么使用HTTPS:https://zhuanlan.zhihu.com/p/72616216 
	里面似乎没有提到DNS污染，这属于身份认证的范畴

SSL原理：https://www.iteye.com/blog/iluoxuan-1736275
中间人攻击：https://www.cnblogs.com/lulianqi/p/10558719.html
	中间人攻击包括多种手段，是一类攻击手段
