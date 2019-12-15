根据这个来：
https://developer.mozilla.org/en-US/docs/Web/Security

或许我们应该理解为什么这些问题能造成危害


## Mixed Content

https://developer.mozilla.org/en-US/docs/Web/Security/Mixed_content

https的网页中不允许发起http的请求。

解决方式是自动将http转为https （服务器端不认识https会怎么处理）
```
<meta http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">
```

有没有其他解决方法，比如允许一个例外


## CSP

https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Content-Security-Policy

https://blog.csdn.net/u014465934/article/details/84199171





## web安全核心思想

将客户端与服务端之间维持的内容监管起来

维持的内容 包括 链接、网页内容、缓存、会话等等