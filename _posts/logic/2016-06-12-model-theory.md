---
layout: post
title: 模型论粗浅理解

tagline: "Supporting tagline"
category : logic
tags : [logic, model theory, math]

---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 什么是模型论

参考wiki：https://www.wanweibaike.com/wiki-%E6%A8%A1%E5%9E%8B%E8%AE%BA
参考：https://blog.csdn.net/yuanmeng001/article/details/79472247

其实查阅网上资料，模型论理解的马马虎虎，最好还是去读下专著：姚宁远的《初等模型论》第一章
以及D.Marker的《模型论引论》

## 区分“真”与“正确”

“真”指的是具体模型下的意义，是语义范畴。
“正确”指的是能够形式推导证明出来，是语法范畴。

## 非标准模型--超实数的由来

https://www.zhihu.com/question/263354787
注意其对皮亚诺算术的改造，得到了非标准模型与无穷大的概念。
同样，可以创造出无穷小，从而创造出超实数的概念，参考https://blog.csdn.net/yuanmeng001/article/details/56656976

是否可以认为皮亚诺公理系统并未定义无穷大？

## 哥德尔完备定理与不完备定理

### 完备与可靠
首先区分可靠与完备的概念：
可靠：形式推导出来的都为“真”
完备：为“真”的都可以形式推导出来。

### 哥德尔完备定理
wiki：https://www.wanweibaike.com/wiki-%E5%93%A5%E5%BE%B7%E5%B0%94%E5%AE%8C%E5%A4%87%E6%80%A7%E5%AE%9A%E7%90%86

其声称在一阶谓词演算中所有逻辑上有效的公式都是可以证明的。
如果一个公式在这个公式的语言的所有模型中都为真，它就被称为“逻辑上有效”的。为了形式的陈述哥德尔完备性定理，你必须定义这个上下文中词语“模型”的意义。这是模型论的基本定义。

完备性定理是否可理解为一阶逻辑都是完备的。


### 哥德尔不完备定理
wiki：https://www.wanweibaike.com/wiki-%E5%93%A5%E5%BE%B7%E5%B0%94%E4%B8%8D%E5%AE%8C%E5%A4%87%E6%80%A7%E5%AE%9A%E7%90%86

wiki上有关于该定理误解的一部分说明。

定理内容：任何逻辑自洽的形式系统，只要蕴涵皮亚诺算术公理，它就不能用于证明它本身的兼容性。

问题1：皮亚诺算术公理系统 本身应该也是不完备的，其不能证明的问题有哪些？
wiki上提到了一些我可以明确的是Goodstein定理，其可以用皮亚诺公理系统描述，但是皮亚诺公理系统无法证明。

该问题也非常有意思，其证明涉及到序数的概念也非常简单，可以了解一下。百度百科[古德斯坦定理](https://baike.baidu.com/item/%E5%8F%A4%E5%BE%B7%E6%96%AF%E5%9D%A6%E5%AE%9A%E7%90%86)提到了其一个变体九头龙游戏，同样看起来非常不可思议。

#### 关于误解
wiki上提到欧几里得几何可以被一阶公理化为一个完备的系统，但是怎么一阶公理化的呢？
有资料称塔尔斯基把欧几里德几何学公理系统简化成“点”的理论？搞成所谓的“一阶理论”。

不完备定理要求公理系统能定义自然数，而不是包含自然数。

### 看似矛盾的两个定理

哥德尔完备定理指的是一阶逻辑上为真的都可以证明。
不完备定理指的是只要包含初等算术系统，则必然不存在不可证明命题。

https://www.zhihu.com/question/263354787
上解释说是一阶系统都存在无数个非标准模型，一个句子G可能在标准模型上为真，在非标准模型为假，不限定模型的情况下，不能得出”真假一致“的结论，因此有不完备定理。
而完备定理的前提是”逻辑上为真“都可以证明，相当于已经限定了模型。

