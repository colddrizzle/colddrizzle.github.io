##定位要义

static relative absolute fixed float

css+div定位中，某个div总是处在其他的容器类元素（比如，另一个div）之内的。默认情况下
每个容器类元素其下面的子元素都是流式布局，也就是static，是的，这个名字真的起的很烂。

流式布局的子元素会随着上层容器元素本身的大小改变而自动流动，这是流式布局灵活的体现。

在给定容器元素大小与各子元素大小的情况下，某个子元素的在流式布局中的位置是可以确定的，
relative就是指相对于这个确定的位置如何偏移，通过`left top bottom right`来制定。

上面static、relative都是在流中。而absolute，fixed、float则是指将这个元素脱离于上层元素的流。
所谓脱离，是指流中其他元素布局不再考虑这个元素，好像这个元素不存在一样。


那么，脱离了流之后，这个元素如何定位呢？absolute、fixed都是相当于某一个非static元素定位。
只不过absolute相对于其上层最近的非static元素，fixed则是相对于显示器窗口（如果把浏览器最大化的话）。
这俩也是通过`left top right bottom`来确定位置。通过`left top right bottom`来定位并非失掉灵活性，因为可以设置百分比。


float脱离了流之后，则根据设置往其上层元素的左侧或右侧漂移。若是一个容器元素下有多个float元素会怎么样呢？
float使用一种“尽力”策略，若往左漂，则能有多左就多左，因此不能再用`left right`之类的来定位。


https://www.w3school.com.cn/css/css_positioning.asp
https://www.w3school.com.cn/css/css_positioning_floating.asp