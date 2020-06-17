chrome.com被墙，中文文档：http://chrome.cenchy.com/index.html

插件的三个js：content script popup script background script
参考这里：https://huajiakeji.com/dev/2018-07/1482.html

content script可以访问dom，后两个不行。content script独立的运行空间，后两个脚本是否互通呢？

其实chrome扩展非常简单，基本只需要查阅API文档，但如果还是要更傻瓜的教程，可以参考这里：https://huajiakeji.com/category/dev/

关于inline event报错：https://www.cnblogs.com/liuxianan/p/chrome-plugin-develop.html