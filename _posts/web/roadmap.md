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



	____________________________________

CSS:

css layout
https://segmentfault.com/a/1190000009139500?utm_source=sf-similar-article
https://www.runoob.com/w3cnote/css-position-static-relative-absolute-fixed.html


	________________________________________________________

JS

es6 module
https://zhuanlan.zhihu.com/p/106884635?utm_source=wechat_timeline
http://caibaojian.com/es6/module.html

模块加载后缀名：https://blog.csdn.net/edc3001/article/details/86763073

JS：弱引用 yield 用yield实现range

弱引用：
https://segmentfault.com/a/1190000023340253
https://blog.csdn.net/gao_xu_520/article/details/79999824


es5 es6 typescript:

https://www.jianshu.com/p/b2f544d7686e
https://zhuanlan.zhihu.com/p/98709371


	————————————————————————————————————————————————————————————

VUE

.vue文件与vue-loader 以及一堆构建工具


前端路由是什么意思
https://segmentfault.com/a/1190000011967786
https://www.zhihu.com/question/53064386
http://www.divcss5.com/html/h55258.shtml

不使用构建工具单使用vue的相关讨论
https://segmentfault.com/q/1010000012769694
https://www.zhihu.com/question/66400933?sort=created

将vue当做模块引入：

https://m.html.cn/web/vue-js/12595.html

```
<script type="module">
  import * as Vue from 'https://unpkg.com/vue@2.6.0/dist/vue.esm.browser.min.js';
  new Vue({
    ...  
  });
</script>
```

渐进式学习vue：
https://www.jianshu.com/p/89a7d14d21aa

不使用vue但实现模块化的一个思路：
https://refined-x.com/2017/10/28/%E5%A6%82%E4%BD%95%E4%B8%8D%E7%94%A8%E6%9E%84%E5%BB%BA%E5%B7%A5%E5%85%B7%E5%BC%80%E5%8F%91Vue%E5%85%A8%E5%AE%B6%E6%A1%B6%E9%A1%B9%E7%9B%AE/

	——————————————————————————————————————————————————————————————————————————





## 浏览器标注插件

基本逻辑

监听鼠标释放事件

事件发生时，使用window.getSelection()函数获取选取的内容，
若选取内容不为空，则在页面上弹出标注菜单。

上面的函数获取的selection内容，会给出其anchorNode，进而可以获取其parentNode，以至于到根，从而获得标注内容的路径。

如果选择了多个内容又会怎么样呢？那要看selection这个数据结构是怎么定义的。

SelectionAPI探究
https://blog.csdn.net/hjb2722404/article/details/110954436
