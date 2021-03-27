---
layout: post
title: matplotlib简明指导

tagline: "Supporting tagline"
category : 其他
tags : [matplotlib]

---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 简介

Matplotlib is a comprehensive library for creating static, animated, and interactive visualizations in Python.

## 基本认识

[官方资料User Guide][0]。

### 界面构成

![img](/assets/resource/matplotlib_ui.webp){:width="100%"}

基本界面如上图所示，大略可以分成三部分：Figure、Axes、datas（你自己的数据画出来的图）。

Figure包含标题、Axes与图例。

Axes包含Axis、Spines、Gird。

	Axes有人翻译为轴域，还是比较合理的，不能单纯的理解为Axis的集合，很多时候Axes等价于subplot（子图）。但是subplot是按照指定比例的分行分列的来划分的。而
	Axes仅仅是一幅子图。相关可以参考这里：python matplotlib中axes与axis的区别是什么? - 禹洋搬运工的回答：https://www.zhihu.com/question/51745620/answer/231113561

这里需要区分Axis与Spines，Spines是构成坐标轴的2条（3D的话就是3条）正交的基线，而Axis是则包含Spines，Axis还包含标题label、刻度以及名字。

datas主要由line和Markers组成，所谓Markers就是表示一个数据的小图形，甚至可以是小图片。

以上都可以在官方User Guide中找到更多说明。

实际上，界面除了上面部分在上下边缘还有工具栏，可以拖动、放大缩小。

绘图并非一定要绘制在axes中，Figure中也可以绘制，只不过没有坐标轴刻度而已。

另外注意一个概念Artist：Basically everything you can see on the figure is an artist (even the Figure, Axes, and Axis objects). This includes Text objects, Line2D objects, collections objects, Patch objects ... (you get the idea). When the figure is rendered, all of the artists are drawn to the canvas. Most Artists are tied to an Axes; such an Artist cannot be shared by multiple Axes, or moved from one to another.

```brush:python;

import matplotlib.pyplot as plt
import matplotlib.lines as lines

fig = plt.figure()
fig.add_artist(lines.Line2D([0, 1], [0, 1]))
fig.add_artist(lines.Line2D([0, 1], [1, 0]))
plt.show()
```

实际上，axes可以看做是一种特殊的画布，只不过因为没有坐标轴，上面的线的起止点变成figure画布长和宽的比例了。

### 绘制哲学

matplotlib中表示一些列点，是将其x坐标与y坐标分别成一个向量来表示的。比如表示点`(1, 2), (3, 4)`，则表示成`[1, 3], [2, 4]`两个向量。3D则表示为三个向量。

默认情况下，matplotlib绘制的图像的坐标范围是你给出的数据的坐标范围。但是可以通过设置xlimit与ylimit来选择观看哪一部分的数据。实际上，即便你设定了limit，依然可以在结果界面工具栏里拖动图片
来观察其他部分的数据，整体上matplotlib绘制结果的显示界面就像一个可以上下左右滑动的窗口

matplotlib的轴上的刻度单位长度不是固定的，并没有一个单位长对应多少个像素这样的设置，而是随窗口大小变化的。刻度精度可以通过`xticks`与`yticks`来设置。

### 两套接口
matplotlib提供了两套风格的接口，一套是[兼容MATLIB的命令式编程风格][1]，一套是基于对象的编程风格。基本上前者所有的操作都是通过`plt.xxx`的方式来调用的。
一般而言前者写起来比较简洁，后者稍微繁琐，但是复杂的功能最好用OO的方式来实现，会更有条理。

### 前端、后端

matplotlib分前后端，前端就是调用matplotlib的api代码部分，后端就是代码变现的部分。matplotlib的后端是可更换的，这赋予了matplotlib强大的能力。

### 交互式模式与非交互式模式

通过`plt.ion()与plt.ioff()`来控制开关的两种模式，所谓交互式模式就是绘图结果出来后，继续编辑脚本，可以即时更新绘制结果(一般需要调用`plt.draw()`来命令系统更新)。

### 嵌入其他UI

https://matplotlib.org/stable/gallery/index.html#user-interfaces

## 绘图基础接口

回想一下gtk或者java awt绘图库，它们通常都提供一些基础的API来绘制点、线、填充面，以及执行面的交、并、差操作。其实matplotlib也一样。

```brush:python;

import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots()  # Create a figure containing a single axes.
# ax.plot函数接收偶数N个数组，分别作为N/2条线段的x向量与y向量，若是奇数个数组，则认为最后一个线段的x向量是
# [0, 1, 2, 3...]
ls = ax.plot([1, 2, 3, 4], [1, 4, 2, 3], [5, 6, 7, 8], [7, 7, 7, 7])  
print(ls)

plt.show()
```

执行上面的代码可以看到，ax.plot返回的其实是个line2D对象的列表:

```
[<matplotlib.lines.Line2D object at 0x11524ab80>, <matplotlib.lines.Line2D object at 0x11524abb0>]
```

debug下查看某个line2D对象可以发现，其中有一个`_path.vertices`属性，其中以坐标元组的方式列出了这条线上的所有点，line2D就是matplotlib的基础API之一。
代码`ax.plot()`就是创建这些line对象，然后将其添加到figure上，其实等价于下面的代码：

```brush:python;
fig.add_artist(lines.Line2D([1, 2, 3, 4], [1, 4, 2, 3]))
fig.add_artist(lines.Line2D([5, 6, 7, 8], [7, 7, 7, 7]))
```

下面来看关于面的基础API，在matplotlib中，面叫做patch（面涂上颜色后看起来像一个个的小补丁），由path来描述。

实际上Line2D下面也包含一个path，可以用`get_path`来查看line对象对应的path。但是matplotlib中好像没有提供用path来定义line的方法。
因此我们可以认为path是为了定义pathpatch，是为了定义面。

matplotlib通过一些操作码（code）来绘制path，这些操作码如下：

```
STOP
MOVETO #移动到某点
LINETO #画线直到某点
CURVE3 #二阶贝塞尔曲线
CURVE4 #三阶贝塞尔曲线
CLOSEPOLY #自动画线到开始点从而封闭路径
```

但注意，path仅仅是逻辑概念，并不对应任何图形。需要将其转化为patch才可以绘制。

一个例子：

```brush:python;
import matplotlib.pyplot as plt
from matplotlib.path import Path
import matplotlib.patches as patches

verts = [
   (0., 0.),  # left, bottom
   (0., 1.),  # left, top
   (1., 1.),  # right, top
   (1., 0.),  # right, bottom
   (0., 0.),  # ignored
]

codes = [
    Path.MOVETO,
    Path.LINETO,
    Path.LINETO,
    Path.LINETO,
    Path.CLOSEPOLY,
]

path = Path(verts, codes)

fig, ax = plt.subplots()
patch = patches.PathPatch(path, facecolor='orange', lw=2)
ax.add_patch(patch)
ax.set_xlim(-2, 2)
ax.set_ylim(-2, 2)
plt.show()
```

可以用`matplotlib.artist.Artist.set_clip_path()`来创建用一个多边形剪切另一个多边形的操作。下面的例子中注释掉的代码取消注释后再看效果就知道了。
注意多个patch的zorder是按照其add_patch的调用顺序递增的，但是也可以用`set_zorder`来人为更改。

```brush:python;
from matplotlib.path import Path
from matplotlib.patches import PathPatch
import matplotlib.pyplot as plt

vertices = []
codes = []

codes = [Path.MOVETO] + [Path.LINETO]*3 + [Path.CLOSEPOLY]
vertices = [(1, 1), (1, 3), (3, 3), (3, 1), (0, 0)]

codes1 = [Path.MOVETO] + [Path.LINETO]*2 + [Path.CLOSEPOLY]
vertices1 = [(1.5, 1.5), (5, 5), (5, 4), (0, 0)]

path = Path(vertices, codes)

path1 = Path(vertices1, codes1)

pathpatch = PathPatch(path, facecolor='red', edgecolor='none')

pathpatch1 = PathPatch(path1, facecolor='none', edgecolor='green')


fig, ax = plt.subplots()


ax.add_patch(pathpatch1)

#pathpatch.set_clip_path(pathpatch1) #调用该方法之前需要将参数线添加到图形中，也就是先调用add_patch

ax.add_patch(pathpatch)


ax.autoscale_view()

plt.show()

```

利用path定义路径可以绘制任意几何图形，matplotlib也将一些基础几何图形做了封装，可以直接使用，参见[patches][2]。

关于path与patch的一个官方比较复杂的例子:[Dolphin][3]。

path的官方指南:[path tutorial][4].

## 布局

https://matplotlib.org/stable/tutorials/intermediate/gridspec.html
讲了基于GridSpec与SubplotSpec的布局控制，以及subplots()是对其的一个封装，用于行列均分的简易情况。

https://matplotlib.org/stable/tutorials/intermediate/tight_layout_guide.html
讲了如何利用`plt.tight_layout()`来解决自动布局导致的标题、刻度挤在一起的坏情况。

## 封装好的绘图模式

折现

散点

直方

饼图

## 3D绘制

https://matplotlib.org/stable/tutorials/toolkits/mplot3d.html

surface



## 动画

## 事件处理


## 其他系列教程

[Matplotlib入门-1-plt.plot()绘制折线图](https://zhuanlan.zhihu.com/p/110656183)

[Matplotlib入门-2-坐标轴axis/axes设置](https://zhuanlan.zhihu.com/p/110902615)

[Matplotlib入门-3-plt.gca()挪动坐标轴](https://zhuanlan.zhihu.com/p/110976210)

[Matplotlib入门-4-plt.legend()创建图例](https://zhuanlan.zhihu.com/p/111108841)

[Matplotlib入门-5-plt.scatter()绘制散点图](https://zhuanlan.zhihu.com/p/111331057)

[Matplotlib入门-6-plt.bar()绘制柱状图](https://zhuanlan.zhihu.com/p/113657235)

[github上的教程项目](https://github.com/matplotlib/AnatomyOfMatplotlib)


[0]:https://matplotlib.org/stable/tutorials/introductory/usage.html
[1]:https://matplotlib.org/stable/tutorials/introductory/pyplot.html
[2]:https://matplotlib.org/stable/api/patches_api.html
[3]:https://matplotlib.org/stable/gallery/shapes_and_collections/dolphin.html
[4]:https://matplotlib.org/stable/tutorials/advanced/path_tutorial.html