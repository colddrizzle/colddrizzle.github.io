---
layout: post
category : 其他
tagline: "Supporting tagline"
tags : [dot,graphviz]
title : graphviz文档笔记
---

graphviz的文档很多地方不够详细，不实际探索一下很难明白什么意思，本文记录了探索的结果。

1. toc
{:toc}

<hr />

## graphviz工具的整体结构
graphviz是一个工具集，主要用于绘制***点线结构*的图**，大致可以分为dot语言、布局引擎、周边工具集、API四个部分。

dot语言用来描述图的结构与属性，但dot语言中极少关于节点、线段具体位置的描述，节点与线段的位置由布局引擎排版。
也即是说，同一个dot语言描述的文件，不同的布局引擎输出的图形并不一样。

graphviz支持的布局引擎还算比较多的，官方网站[readmap][0]部分介绍了主要几种引擎的风格，配合[gallery][1]还是很容易即需即学即用的。

周边工具集比较多，主要用来进行图结构编辑、查看、图片处理等等，基本用不到，略过。

API部分提供了常用几种语言风格的API，使用API就不用手动组织字符串来组织dot文件的格式了。虽然官方文档有接口定义，但是windows平台平没有对应的lib，需要自己编译（Graphviz使用swig来实现各脚本语言的接口，swig是一个简单又强大的工具，有兴趣可以了解一下）。综合下来我找到三种方式：
* 自己编译graphviz获得gv.3python接口规范的lib
* pip install pygraphviz 但在windows平台python2下安装失败了，没有深究。
* pip install graphviz 
最终决定使用的是第三个，这个好像也是MIT提供的，整个lib非常简单轻量，就是用python组织文件，然后起一个进场调用dot工具渲染。


## dot语言
dot语言的[语法][2]还是比较简单的。描述图形实体用的元素只有graph、subgraph、node、edge四种。
每种元素都可以定义若干属性，官方文档有全部的[属性列表][3]，需要注意的是属性适用的元素类型，并且有的属性仅仅由某些引擎或某些输出格式支持。

一个dot描述文件必然包含在一个graph元素中，并且graph元素只有一个，且graph可以匿名。需要注意的是，图只能是有向图digraph或是无向图graph中的一种，有向图的边必须都是`->`，无向图的边必须都是`--`。不能是部分边有向、部分边无向这种混合形式，如果想表达这种形式，可以通过设置[dir属性][4]。
```
//wrong example
graph{
	a--b
	b->c
}
digraph{
	a->b
	b--c
}
//right example
graph{
	a--b[dir=both]
	a--b[dir=forward]
}

```

![img](/assets/resources/graphviz-dir-attr-0.png)

如图，将一个graph表现的像是有向图一般，同理还有讲一个有向图，表现的像是无向图一般。
```
digraph{
	edge[dir=none]
	a->b
	b->c
}

```
![img](/assets/resources/graphviz-dir-attr-1.png)

也就是说，`digraph`与`graph`关键字仅仅约束了`--`与`->`的使用，但对边的箭头形式并没有约束。那么`--`与`->`的作用是什么呢？
推测：1.排版引擎需要 2.周边工具集里面网络图处理工具需要，有待证实。
注意dir属性在digraph中默认是forward，在graph中默认是none。这个forward的方向依据是rankdir属性，rankdir属性默认是`TB`,也就是`top to bottom`。


用于修饰`graph`或者`digraph`的`strict`则限定了相同的边只话一条。所谓相同的边，在graph中指的是两个端点相同的边定义，在digraph中指的是断点相同且
方向相同的边，这个方向指的是`->`的箭头方向，与`dir`导致的箭头属性无关。相同的边判定不包括属性，且所有的相同的边的属性会归拢到一起。
```
//定义了相同的边，一个指明箭头，一个指明颜色，最后的a--b的属性会两个都包括。
strict graph{
	a--b[dir=both]
	a--b[color=blue]
}
```
![img](/assets/resources/graphviz-strict-0.png)

若不指定`strict`，则渲染结果如图：

![img](/assets/resources/graphviz-strict-1.png)

`strict`关键字的一大妙用就是可以通过一条条路径的方式来描绘一个图，想象一个系统流式的输出一条条的路径，我只需要把路径记录在文件中，加上`strict`关键字就可以生成图，不需要在自己统计节点与边，重新组织图。例子：

```
strict digraph "so example" {
    rankdir=LR;
    "0" -> "3" -> "4" -> "5" -> "C";
    "0" -> "3" -> "4" -> "5" -> "A";
    "0" -> "6" -> "7" -> "5" -> "E";
    "0" -> "6" -> "7" -> "5" -> "D";
    "0" -> "6" -> "7" -> "5" -> "B";
}

```
生成图：
![img](/assets/resources/graphviz-strict-2.png)

边的某些属性需要分清边的头与尾。对于有向边`->`,箭头所指向的为edge的头，箭尾所指向的节点为edge的尾。对于无向边，这个边第一次被解析器读取的时候，左边的节点被认为是尾，右边的节点被认为是头。



### 属性定义与作用域


给graph、digraph或subgraph定义属性只需要把属性赋值语句放在花括号里面就可以了。
给node与edge定义属性则有三种形式：

1. 给具体的node或edge定义属性，属性作用域仅仅包括当前node或边。
```
graph{
	a[color=red]
	a--b[dir=both]
}
```
2. 给所有的node或者edge定义属性，属性作用于包括当前位置的最内层大花括号所在的graph或者subgraph，且定义位置之前的位置不生效。而且strict关键字会合并相同边属性，但这跟属性作用域没有关系，注意理解。这条规则不适用于图属性，比如`rankdir=LR`定义在任何位置都是一样的效果。这条规则指的是所有的点属性定义，不是具体的点属性定义，比如下面例子中的在子图中设置了d的颜色，在外围中依旧生效。
```
 strict graph{
 	rankdir=LR
     {
         a--b//属性不生效
         edge[color=red]
         b--c//属性生效
         d[color=green]//具体的点属性定义在外围生效
         node[color=red]//宏观的点属性定义在外围不生效

     }
     c--d//属性不生效
     d--e
     {a--b[color=blue]}
 }
```
![img](/assets/resources/graphviz-attr-scope-0.png)
属性是有作用域范围的，但是节点以及点的属性作用域的作用域是全图，定义在子图里面的点在另一个平行子图里也可以引用。

3. 使用subgraph给某些节点或边定义属性。
dot中subgraph仅仅只需要一对花括号框起来，也就是可以匿名，可以不写`subgraph`关键字。且匿名subgraph不会影响布局引擎排版。
```
graph{
	rankdir=LR
	{
		node[color=green]//虽然这里是宏观的点属性定义，在作用到了具体的点上了
	   	c e//具体的点一旦获得属性color=green则全局生效。
	}
	
	b--c 
	d--e
	{
		edge[color=blue]
		a--b
		c--d
	}
}
```
![img](/assets/resources/graphviz-attr-scope-1.png)

### subgraph与cluster
dot中的subgraph是逻辑上的subgraph，并不会对排版造成直接影响。主要作用：
* 组织dot语言文件，方便在两个点集合的任意两点之间建立边
```
digraph{
{A B}->{C D}
}
```
![img](/assets/resources/graphviz-subgraph-0.png)
```
graph{
{A B}--{C D}
}
```
![img](/assets/resources/graphviz-subgraph-1.png)

*  提供一个上下文用于给一类点或边定义属性，参见上一小节属性作用域。其实最常用的是指定`rank`属性，参见下面特殊属性的介绍。
*  一类以cluser靠头命名的subgraph会将子图内的点排到一起并用一个框围起来。这种用法并不是dot语言的语法，而是某些布局引擎支持的特性，目前所知，dot引擎是支持的。
```
graph{
	subgraph cluster_0{b c}
	a--b[dir=both]
	b--c[dir=forward]
}
```
![img](/assets/resources/graphviz-subgraph-2.png)

注意，只有fdp引擎支持cluster与cluster、cluster与node之间的边，[example][5]。dot引擎虽然也支持cluster之间的边，但需要配合compound属性。


dot语言是一门比较宽松的语言，字符串是否有引号包括不重要，除非字符串与关键字重叠。而且语句之间的冒号或者分好仅仅是为了可读性，用空白符代替也无所谓。并且字符串定义支持C语言形式的`\`加换行符的多行表示形式，还支持用`+`把多个字符串拼接起来就像是python中那样。

## 节点形状与线的形状

### 节点与线的锚点
线与节点的链接位置可以指定，称为port属性。节点的port属性使用东南西北的方位缩写来制定，比如`ne s ws`等。
指定port可以通过edge的headport与tailport属性，也可以写成形式`node1:port1 -> node2:port5:nw;`。注意这里的`port1 port2`指的是record-based shape与html-like label里面指定的port名字，用来将边指向这种复杂节点的某一部分。一般情况，简单的节点锚点可以如下指定：
```
digraph{
a:n -> b:s;
}
```
![img](/assets/resources/graphviz-port-0.png)


### 节点形状
节点的形状大致可以分为三类，文档有[详细说明][6]，不再细表。注意下第二类record-based shape以及
节点的边也可以定制形状。我们主要关心HTML-like label。

### HTML-like Label
label属性本身是个元素的名字，但这个元素的名字是可以通过html定制格式的，当把节点的形状隐去，看起来好像html格式的label就是节点。
所以使用HTML-like label 一般会设置形状`shape=none or shape=plaintext`。

HTML-like label适用的范围包括node、edge、cluster、graph以及边的头尾headlabel与taillabel。其格式是包括在`<>`内的html文本。
支持的HTML标签可以分为两类：
* 文本格式类，比如加粗、斜体，下划线，字体等
* 表格类，就是`table`标签那一套，支持的标签的属性参见文档。
```
graph{
	a[label=<<table cellBORDER="0"> <tr> <td>a</td> </tr> <hr/> <tr> <td>a</td> </tr> </table>>]
}
```
![img](/assets/resources/graphviz-html-table-0.png)

表格内容还可以是图片。支持port属性的标签只有table与td，也就是整个表与具体的单元格，不支持对行或列指定锚点。以上在文档节点形状一节都有详细说明。

### 线的形状
线的形状设置可以：
* 通过dir配合rankdir属性指定默认的箭头方向。dir=back的时候，`a->b`的画出来的箭头方向将从b指向a。
* 指定箭头的[风格][7]
* 通过splines属性指定线的[风格][8]

## 一些属性的解析
大部分属性都比较直观配合文档很容易理解，但也有一些属性略复杂。

### order与rank 适用范围：dot 引擎
理解这两个属性需要了解一点dot引擎的[排版算法][9]。dot的排版算法会将所有的节点排序，序号相同的节点会被对齐。看下面的例子，rankdir=LR从左往右排版。
```
digraph G {
    rankdir=LR
    node[shape=circle]
    q_[shape=none label=""]
    q3[shape=doublecircle]
    q4[shape=doublecircle]
    q_->q0
    q0->q1[label="λ"]
    q0->q2->q4[label=a]
    q1->q4->q2[label=b]
    q1->q3[label=a]
    q3->q4[label="λ"]
    /*
    {rank=same; q4 q3}
    {rank=same; q1 q2}
    */用于指定rank方式的语句
}
```
若不指定rank，则排版结果为：

![img](/assets/resources/graphviz-rank-0.png)


指定rank=same后，排版结果为:

![img](/assets/resources/graphviz-rank-1.png)

图中的红线与rank数值仅仅是示意，不是渲染出来的。可以看到q1与q2被放在同一列对齐，q3与q4被放在同一列对齐。
当然rank除了取“same”还有其他值，具体参考文档。

### ordering属性 适用范围：dot引擎
ordering是节点属性，ordering=out时候，节点的出度排序与输入顺序一致。ordering=in时候节点的入度排序与输入一致。

```
digraph G {

    node[shape=circle]
    q_[shape=none label=""]
    q3[shape=doublecircle]
    q4[shape=doublecircle]
    q_->q0
    q3->q4[label="λ"]
    q0->q1[label="λ"]
    q0->q2[label=a];
    q2->q4[label=a]
    q1->q4[label=b];
    q4->q2[label=b]
    q1->q3[label=a]

   {rank=same;q3 q2 q1}
} 
```

![img](/assets/resources/graphviz-ordering-0.png)

可以看到q4的三条入度边的出现顺序从左到右是q1->q4, q3->q4, q2->q4。当q4指定按入度排序后，渲染结果与文件中出现顺序一致。

![img](/assets/resources/graphviz-ordering-1.png)


### size与ratio
以英寸为单位设置产生的图片的最大宽与高。注意是最大宽与高，而不是最终的宽与高。如果设置的宽与高比实际产生的图片要大，那么
最终产生的图片并不会扩大，而是保持其实际大小。所以这个属性是用来缩小图片的，一般还要配合ratio使用，ratio指明了缩小方式，具体参考文档。

### dpi或resolution
上面说size属性无法扩大图片，那么配合dpi属性就可以扩大图片。 比如我希望获得600x400像素的图片，那么设置`size="3,2";dip=200`就可以了。

需要注意的是无论ratio还是dpi都不会扭曲图片，而只是放到或缩小的至少宽或高其中一个符合要求。

### viewport
用于在图片上截取窗口并放大，该属性会遮盖size属性。上面order与rank例子里面的图，设置viewport为以q2为中心并放大两倍
```
digraph G {
    rankdir=LR
  viewport="300,200,2,'q2'"//q2需要引号 否则不能正确设置
    node[shape=circle]
    q_[shape=none label=""]
    q3[shape=doublecircle]
    q4[shape=doublecircle]
    q_->q0
    q0->q1[label="λ"]
    q0->q2->q4[label=a]
    q1->q4->q2[label=b]
    q1->q3[label=a]
    q3->q4[label="λ"]
   
    {rank=same; q4 q3}
    {rank=same; q1 q2}

}
```

渲染结果为：

![img](/assets/resources/graphviz-viewport-0.png)

### bb
bb这个属性备注里是`write only`，意思是用来输出的，并不会被任何排版引擎读取或者使用。
In the Notes field, an annotation of write only indicates that the attribute is used for output, and is not used or read by any of the layout programs.

输出格式的[文档][10]中指明，当你以dot作为输出格式的时候，dot会把输入文件内容重新输出，并且附上很多属性。其中graph会被附上bb属性。
具体使用命令`dot -Tdot -O file.gv`产生的dot文件里就会看到bb属性了。所以bb这个属性基本就是用来看的，无法设置。

疑问是dot格式输出的文件里的节点位置属性很奇怪，跟直接输出图片产生的结果不一样，不知道为什么。

### compound 适用范围：dot引擎
前面提到过fdp引擎允许把cluster当成节点来画边。在dot中compound关键字有类似作用，但不能在点与cluster之间画边。首先设置graph属性compound=true,然后将跨cluster的边添加属性lhead=clusterName,ltail=clusterName。之所以要指明clusterName，是因为一个节点可能存在于多个cluster中。
```
graph{
compound=true
subgraph cluster_0{
	a--b
}
subgraph cluster_1{
	c--d
}
a--c[lhead=cluster_1 ltail=cluster_0]
}
```
![img](/assets/resources/graphviz-compound-0.png)

### image
在节点上添加图片。需要用imagepath属性指定图片的搜索路径。默认情况下节点会伸缩到图片的大小，可以给节点指定fixedsize=true禁止伸缩，
然后用Imagescale属性指明图片适应节点尺寸的方式。
```
graph{
imagepath = "C:\\Users\\Administrator\\Desktop"
node[shape=box imagescale=true fixedsize=true]
a[image="shake.gif"]
}
```
### layer
当把节点分层后，可以输出多幅图片，每张图片只显示一层的节点。
```
digraph G {
	layers="local:pvt:test:new:ofc";

	node1  [layer="pvt"];
	node2  [layer="all"];
	node3  [layer="pvt:ofc"];		/* pvt, test, new, and ofc */
	node2 -> node3  [layer="pvt:all"];	/* same as pvt:ofc */
	node2 -> node4 [layer=3];		/* same as test */
}
```
layer属性只支持postscript格式，所以运行命令`dot -Tps -O input_file`就可以生成多张图片

### constraint
当设置该属性后，排版引擎排版的时候不再考虑这条边，排完版后再把这条边添加上去。文档中的[例子][11]非常明晰了，不再细表。

[0]:https://graphviz.gitlab.io/about/
[1]:https://graphviz.gitlab.io/gallery/
[2]:https://graphviz.gitlab.io/_pages/doc/info/lang.html
[3]:https://graphviz.gitlab.io/_pages/doc/info/attrs.html
[4]:https://graphviz.gitlab.io/_pages/doc/info/attrs.html#d:dir
[5]:https://graphviz.gitlab.io/_pages/Gallery/undirected/fdpclust.html
[6]:https://graphviz.gitlab.io/_pages/doc/info/shapes.html
[7]:https://graphviz.gitlab.io/_pages/doc/info/arrows.html
[8]:https://graphviz.gitlab.io/_pages/doc/info/attrs.html#d:splines
[9]:https://graphviz.gitlab.io/_pages/Documentation/TSE93.pdf
[10]:https://graphviz.gitlab.io/_pages/doc/info/output.html#d:dot
[11]:https://graphviz.gitlab.io/_pages/doc/info/attrs.html#d:constraint