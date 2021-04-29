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


es6 module
https://zhuanlan.zhihu.com/p/106884635?utm_source=wechat_timeline
http://caibaojian.com/es6/module.html

css layout
https://segmentfault.com/a/1190000009139500?utm_source=sf-similar-article
https://www.runoob.com/w3cnote/css-position-static-relative-absolute-fixed.html

前端存储indexdb：https://www.jianshu.com/p/bb116c7a74b3


c10k问题：https://zhuanlan.zhihu.com/p/61785349



selection接口：
basenode与extendnode是anchornode与focusnode的别名

一个selection包含多个拖蓝也就是range，但一般用鼠标操作只能获得一个拖蓝。

range的endcontainer有时候会变成下一个元素但其offset为0，这时候应当使用类似于字符串strip的方法将其去掉。

selection的选取顺序仅依赖于dom顺序，css不会改变这个顺序。比如自上而下三个p元素，使用css将第二个p元素放在最下面。鼠标拖动选择第一第三个的时候还是会选择上第二个，
尽管鼠标看上去没有从第二个p上面划过。
