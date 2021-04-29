浏览器插件

chrome的插件文档被墙了。

因此参考firefox文档：https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions。

chrome、firefox、edge浏览器遵循基本相同的api，相互之间只需要做少量的修改就可以移植。

## 插接构成

https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions/Anatomy_of_a_WebExtension

其中内容脚本与后台脚本需要注意下，内容脚本也区别与页面内脚本。内容脚本不可以访问页面内脚本，也不可以访问全部的扩展API，
比如`downloads.download`就不能在内容脚本中访问，内容脚本主要是用来访问dom的。后台脚本不可以访问目标页面的dom，二者之间通过
通信进行协作。

后台脚本正如其名， 只要插件被启用就开始执行。内容脚本的执行分情况，声明式在页面url符合匹配规则时开始执行，程序式使用`tabs.executeScript`动态执行一个内容脚本。



## 用户界面

一个插件的用户界面可以包含非常多的组件

https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions/user_interface

## 兼容性

https://developer.mozilla.org/zh-CN/docs/Mozilla/Add-ons/WebExtensions/Chrome_incompatibilities

兼容性里面firefox与chrome最大的一点区别是异步调用。firefox采用promise风格，而chrome采用回调风格。

关于chrome异步回调还要一个点：https://blog.csdn.net/anjingshen/article/details/75579521