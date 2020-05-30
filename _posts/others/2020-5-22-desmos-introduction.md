---
layout: post
title: 数学绘图软件desmos介绍

tagline: "Supporting tagline"
category : 其他
tags : [数学绘图]

---
{% include JB/setup %}

* toc
{:toc}

## 基本

desmos绘图软件是一个在线网页版绘图软件，有好几个产品，可以参考
[官网](https://www.desmos.com/)，这里介绍的是其中一个叫做Graphing Calculator的工具。偏重于函数图像展示，但是从官方gallery来看，
几乎无所不能，甚至能画出一个5缸发动机的基本演示，还是能动的，wow!

几何绘图工具也有提供，还比较简陋，不如GeoGebra强大好用。

官方中文指南在[这儿](https://desmos.s3.amazonaws.com/Desmos_User_Guide_ZH-CN.pdf)

## 如何定义函数

### 直角坐标系
desmos将`x`与`y`当做坐标系坐标，且支持`x`与`y`的隐函数。
desmos可以将非`x`与`y`的单字母当做变量。变量可以以滑块的方式添加取值范围，并绘制变量变动时的动画效果。

desmos将任意满足以下条件的表达式当做函数自动绘图
* 仅包含两个单字母
* 表达式左边仅包含一个单字母

比如`a=b+c`，将`c`添加为变量，则desmos自动将`a`当做y坐标，`b`当做x坐标绘制函数图像。

desmos自动将`a=1`这种当做常量滑块定义，那么如何绘制水平线或垂直线呢。只能使用`x`与`y`来定义，比如`x=1`。

注意我们需要区分坐标与变量的概念。
只要一个单字母被当做坐标而不是变量，那么不同表达式之间的同名坐标是没有关系的。但是同名变量是有关系。

### 极坐标系

[参考这里](https://www.desmos.com/calculator/pgyxrshobg)

## 如何定义点
定义任意非x与y的单字母有序对，就定义了一个点。比如`(h,k)`。
然后分别限定h与k的范围就定义了该点的位置。比如`h=1,k=2`。

## 如何画定长线段

思路一就是给出该线段x与y直接的函数关系，然后限定x的取值范围。

思路二就是给出x与y坐标的表示，比如说h与k，然后用`(th,tk) (0<=t<=1)`来表示。

思路三是极坐标系。

参考[这里](https://www.desmos.com/calculator/0imfm6eo2r)。
蓝色线段是直角坐标系下。
绿色与紫色是极坐标系下线段，且互相垂直。


## 如何组织变量

变量直接建立函数关系，也就是建立依赖关系。但是所有变量的依赖关系要构成一个有向无环图，通过分析有向无环图来限定变量直接的取值范围。

比如h=x,x=h，我们不能同时限定x的取值范围与h取值范围导致其冲突


## 创建文件夹组织表达式与变量

Easy!

## 添加图片并将图片与变量关联

Easy!

## Enjoy!

这里提供几个有趣的函数图像，可以试一试！

[来自知乎的心形线？不止](https://www.zhihu.com/question/349185539/answer/861696646)

[疯狂的函数1](http://www.matrix67.com/blog/archives/4447)

[疯狂的函数2](https://support.desmos.com/hc/en-us/articles/202529079-Unresolved-Detail-In-Plotted-Functions)