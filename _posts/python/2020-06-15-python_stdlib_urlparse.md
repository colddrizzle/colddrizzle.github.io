坑:

```
urlparse.urlsplit("www.baidu.com/img/baidu_85beaf5496f291521eb75ba38eacbd87.svg")
```
解析出来的scheme与netloc都为空，整个为path，这应该是bug