---
layout: post
category : 其他
tagline: "Supporting tagline"
tags : [dpi, ppi, pt, px, dot]
title : 关于显示与印刷规格的一些理解
---

{% include JB/setup %}

在弄清这个问题之前，需要把握一个原则，对于印刷行业来说，关心的是最终产出的字体或图画的实际尺寸（英寸），而对于显示来说，并不特别关心实际尺寸，
因为显示画面一般可以随意放大缩小，这时候更关心的是像素以及像素密度。这也是为什么图片一般是有DPI信息的，而视频往往没有DPI信息，因为视频一般不会被印刷成实物。

### 术语 
pt: point，中文称为“点”。起源于印刷行业的字号单位，有绝对尺寸。有美式点或DTP点等不同的点标准[wiki][0]。现代电脑如word,photoshop中采用的一般是DTP
点，1pt=1/72inch。

dot: 中文称为“点”。一般用DPI(dot per inch)来指的是印刷设备的物理的点的密度，没有绝对尺寸。
pixel: 中文称为像素。一般用PPI(pixel per inch)用来指的是显示设备的物理的像素密度。没有绝对尺寸。
px: 我理解是CSS引入的，称为CSS像素。一般与物理像素有着跟设备相关的对应关系称为dppx（dot per px）。比如我的macbookpro 15分辨率是2880*1800。但是css像素分辨率是1440*900，也就是一个CSS px对应两个物理像素，也就是dppx为2。

所以可以看到，除了pt是由绝对尺寸之外，印刷设备与显示设备两种物理设备都没有绝对尺寸，所以很多都是绝对尺寸的字图画在相对尺寸的设备上显示导致的换算问题。

### 起源于印刷行业
规定字号的绝对大小我猜测是为了阅读方便，排版美观。为了这两个目的，就需要考虑不同字号直接的比例，以及常用字号在阅读载体上的实际观感体验。
比如阅读书本或报纸的时候，书本报纸与眼睛的距离是一个相对固定的距离，那么在这个距离下什么样的字号既能看的清又能显示的足够多就是要考虑的问题。

### Windows与mac的设计理念不同
那么到了显示设备上，首先期初的显示设备并不是手拿着阅读，因此阅读距离不同，其次，显示设备可以缩放画面。windows与mac的设计理念不同由此分歧。
windows追求的是显示设备的阅读效果与印刷品的阅读效果类似，为此采用了一种“谎报”dpi的[方法][1]。其做法就是认为阅读屏幕的距离比阅读书本的距离长大约1/3。因此在72dpi的印刷体到了72ppi的屏幕上需要扩大1/3才能看起来像是1inch,因此windows谎报屏幕的PPI为96，这样72点1inch的字体便渲染出来96个像素宽度，96个像素宽度在72的ppi上相当于96/72=4/3inch。本来这个谎报的DPI是系统自己扩大1/3自动设定的，但在如今的windows系统上这个谎报的DPI是可以自己设置的。

![img](/assets/resources/set_virtual_dpi_on_windows.png)

假设字体的字号为x，那么字体的印刷尺寸为x/72inch。而在windows虚拟dpi下的实际尺寸的计算公式就是`（虚拟dpi/屏幕ppi）*(x/72)inch`。这就是为什么上图中的虚拟dpi越大字体越大，分辨率设置的越低（ppi越小）字体远大。

需要注意的上图中的96dpi是与IE浏览器中内建属性`screen.logicalXDPI,screen.deviceXDPI`等并不是一回事，详细参考[here][2]。

比如在我的台式机上屏幕为Dell 1909W（16inchx10inch. 1440x900），ppi为90。因此屏幕上72点的字体实际宽度大约为`(96/90)*2.54=2.7cm`。

![img](/assets/resources/72pt_on_windows.png)


而mac认为既然画面可缩放，追求的是概念一致性。72点的字体在屏幕也应该显示一英寸的大小，而那个时候mac的显示屏ppi刚好是72，所以一个pt对于一个像素。然而，在如今retina屏幕上，这种一致性已经不存在了。retina屏幕使用高PPI的屏幕与HiDPI技术，HiDPI具体而言就是使用4个物理像素来渲染原来的一个像素所占用的空间，因此表现更细腻，可以想见HiDPI技术主要是关于如何平滑的技术。

![2010WWDC](/assets/resources/hi_dpi.jpg)
<center>2010 WWDC大会</center>


在retina屏幕上逻辑上仍然是一个字号pt对应一个像素，不过是这个像素是“虚拟像素”，一个“虚拟像素”对应两个物理像素，而我的macbook pro的屏幕ppi高达220，若是换算成虚拟像素也有110。因此只有72pt的字体也就是72个虚拟像素的字体看起来比一英寸小很多，所以实际测量下220ppi的retina屏下的72点的“中”字的宽度大约`72*2.54/110 = 1.82cm`。

实际上，retina屏幕屏幕中ppi与分辨率已经不是一回事了。其实windows中的虚拟DPI也是将分辨率与PPI的概念分离了。

而且，当通过上面的mac远程连接windows桌面并查看72点的字体的时候，字体的实际尺寸就变成了`96*2.54/110=2.2cm`了。


### Photoshop中的情况
文章开头说，只有印刷行业才严格的关心最终产出物的实际尺寸。那么我们上面讨论都是屏幕显示设备，他们的显示的72pt的字体实际尺寸往往不是1inch。
而在ps中，其产出物是电子作品或者印刷品的电子稿，后者就需要关心实际尺寸了。

在ps新建画布的界面中，可以看到会要求我们设定画布的尺寸与DPI，而且尺寸有不同的单位，那么在windows下这个尺寸单位实际有什么不同呢？

![ps_new](/assets/resources/ps_new.png)

实际上，像素单位就是屏幕上的一个像素，此时DPI设置并不影响画布在显示器上显示的大小，但是若将该画布打印，则DPI就会发生作用了。
而点单位指的就是字号单位pt且1pt=1/72inch。此时，画布在显示器上的实际大小受到DPI影响，DPI越大，画布越大。因为此时，ps是先用inch单位的画布尺寸乘以你设置的DPI获得画布的像素宽度。可以看到photoshop绕过了windows系统的虚拟DPI的概念，直接与屏幕PPI进行换算。

而且像素单位与点单位分别反映了两种不同的侧重点，前者用于电子产品的尺寸设计，后者用于印刷产品的尺寸设计。


### 打印机的DPI为什么那么高
由于身边没有打印机，有些想法无法验证
打印机的DPI是任意可调的吗
打印机的72pt的字严格是1inch吗等等

### graphviz中的情况
[graphviz][3]利用了windows的虚拟DPI的概念，设置graph尺寸的时候单位为inch，并且graph的渲染器使用的DPI为72。而且graphviz是面向印刷出版的，
所以显示屏幕上也会试图显示1inch的图像，从而使用了虚拟DPI，比如虚拟DPI为96.那么1inch的图像在显示器上就是96个点。

### CSS中的情况
CSS中主要是引入px的概念，称之为css像素，css像素就像retina中的虚拟像素，在不同的设备上对应不同的物理像素。推荐一个[网站][4]查看当前设备信息。
关于css像素的具体作用等有需要的时候再去了解吧。

### 题外话
上述链接中第一个的作者是微软先进阅读计算小组的成员，他有两篇文章不错介绍了ClearType的相关情况。
[link_1][5] [link_2][6]


[0]:https://zh.wikipedia.org/wiki/%E9%BB%9E_(%E5%8D%B0%E5%88%B7)
[1]:https://blogs.msdn.microsoft.com/fontblog/2005/11/08/where-does-96-dpi-come-from-in-windows/
[2]:https://msdn.microsoft.com/en-us/ie/ms537625(v=vs.94)
[3]:https://graphviz.gitlab.io/
[4]:https://www.mydevice.io/
[5]:https://blogs.msdn.microsoft.com/fontblog/2005/10/20/you-can-tune-a-font-but-you-cant-tuna-fish/
[6]:https://blogs.msdn.microsoft.com/fontblog/2008/07/16/cleartype-improves-the-efficiency-of-typical-office-tasks/