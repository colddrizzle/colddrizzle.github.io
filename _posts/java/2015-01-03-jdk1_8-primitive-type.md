---
layout: post
category : java
tagline: "Supporting tagline"
tags : [java]
title : JavaCore-java数据类型与运算
---

* toc
{:toc}

<hr />

本篇主要是java核心编程上层第三章要点笔记。



自动拆箱装箱？

类型提升？


# 3.3 数据类型

一共8种基本数据类型：4种整型 2种浮点型 一个unicode代码点char与一个布尔类型。

## 3.3.1 整型

4种整型：byte short int long。位宽与平台无关分别是1 2 4 8字节。

java中没有unsigned修饰符。也没有无符号数。

### 字面量写法
long类型后面跟一个L或l字母。

从java7开始，可以用0b或0B表示二进制。

从java7开始，可以在字面量中任意加下划线加强可读性。

```
0b1111_0011
0B11_11
1_000_000
2_00
```

问题：为什么long字面量需要加L？为什么short、byte没有相应的s或b字母？

因为不加L的字面量会被当成int。也就是
```brush:java
long a = 20_0000_0000; //没有问题 20亿在int的范围之内

/**
编译器读入时看做一个20亿的int型，关联到变量a的时候
（也就是赋值时，这个需要了解class文件的结构与运行）
在转为long类型，转换的方式就是有符号扩展。
*/

//有问题，30亿作为int超出范围了，难道就无法声明了吗 这就是L解决的问题。
long b = 30_0000_0000; 

```

那么对于short、byte来讲，数字字面量当成int完全可以满足short、byte的所有表达。至于大于其表达范围的字面量，
编译时自然会报错。
```
short a = 20_0000; //编译报错

byte b = 0xFF;// 编译报错

byte b2 = 0x7F; // 编译通过
```

## 3.3.2 浮点类型

float的尾数有23位，因此最小的精度为2^(-23)。

double的尾数有52位，因此最小精度为2^(-52)。

`3.14`这样的字面量被当做double类型，若要声明float类型需要在后面加`f`或者`F`。

float类型因为精度问题很少使用，除非精度不是问题且数量非常大的时候，出于节省空间的考虑声明为float。

### 字面量写法

```
0.314D

3.14e-1

//16进制的指数计数法表示0.125
// 尾数采用16进制 指数采用10进制 指数的基数是2而不是10
// 0.125 = 2^-3
0x1.0p-3

```

### 无穷大与NaN
```
Double.POSITIVE_INFINITY;

Double.NEGATIVE_INFINITY;

Double.NaN;
```

无穷大可以参与大于小于比较，因而可以作为一些算法中的界。


### 舍入误差

浮点数会有舍入误差。

```brush:java

System.out.println(2.0D-1.1D);

//输出 0.8999999999999999

```

因此浮点数不能用于金融计算。应该使用BigDecimal类。

### strictfp关键字

什么时候应该使用strictfp:
[参考](https://stackoverflow.com/questions/517915/when-should-i-use-the-strictfp-keyword-in-java?r=SearchResults)

strictfp的语法用法：
[参考](https://www.breakyizhan.com/java/4099.html)

strictfp对那些运算起作用?

strictfp对方法内调用的方法还起作用吗?

[参考](https://stackoverflow.com/questions/6769887/doubt-about-strictfp-and-strictmath?r=SearchResults)

[这里](https://howtodoinjava.com/java/keywords/strictfp-modifier/)提到`Double.MAX_VALUE`在不同的平台上拥有不同的值，但是使用strictfp之后拥有相同的值，由于手头缺少不同的CPU，暂未验证，先mark。

有关strictfp更多可以参考[wiki](https://en.wanweibaike.com/wiki-Strictfp)。

### StrictMath

java.lang.Math为了达到最佳性能，所有方法都是用计算机浮点单元中的例程。因而是平台相关的。

为了得到可预测的结果，应该使用StrictMath类。

StrictMath与strictfp: strictfp仅自定义的方法的当前方法起作用。java提供的方法需要单独的使用StrictMath类而不是Math类。

## 3.3.4 unicode与char类型

“强烈建议不要在程序中使用char类型，除非确实需要处理UTF-16代码单元”书中的这个强烈建议是出于什么样的考虑呢？

那是因为代码单元与码点不是一个概念 ，详细参考[这里](/2019/10/18/unicode)。在UTF16中因为代理对的存在，有可能两个代码单元表示一个码点。

char类型的字面量写法：
```brush:java
char c1 = 65;
char c2 = 'a';
```

char类型可以当做无符号的16位short类型：
```brush:java
char c1 = 65;
char c2 = 16;
System.out.println(c1);
System.out.println(c1+0);
System.out.println(c1+c2);

//output:
// A
// 65
// 81
// 后两个结果打印的数字就是因为类型自动转换导致println接受其实是int类型。
```

## 3.3.5 布尔类型

java中布尔类型与整型的0或者引用类型的null有着确定的区分。

在C中可以写：
```brush:c
if(0){
	//do something
}

if(NULL){

}
```

但是在java中不能写
```brush:java
if(0){

}

if(null){

}

```

# 3.4 变量
使用如下方法来判断哪些字母可以用于java变量名:

```brush:java
    Character.isJavaIdentifierStart(ch);
    Character.isJavaIdentifierPart(ch);
```

不要觉得奇怪，java不仅仅支持数字以及26个英文字母做变量。面对世界上那么多语言文字，确实需要这样的方法来判断哪个“字”可以用来表示变量名。

```brush:java
//中文变量名

long 中文 = 1;

```

尽管$是一个合法的变量名字符，但是尽量不要在自己的代码中使用它。这个字符一般用于编译器或者其他工具生成的代码中。

C与C++区分变量的声明与定义：

```brush:c
int i = 1; //定义

extern int i;//声明
```
java中不区分声明与定义，相应的是定义并初始化与定义但未初始化。无论何时初始化，变量在第一次使用之前必须初始化。

### 常量表示

用final表示常量，final表示只能被赋值一次，其后不可再更改。赋值可以是定义时赋值也可以是之后赋值，但是只能有一次赋值。

# 3.5 运算符

包括加减乘除、取模、位移、逻辑运算。

## 3.5.1 数学函数与常量

## 3.5.2 数值类型之间的转换

合法转换：

![img](/assets/resources/java_type_convert.png)

实心箭头表示无信息丢失的转换。虚线箭头表示有精度损失的转换。

比如下面这个例子：

```brush:java
int ai = 123456789;
float fi = ai;
System.out.println(fi);
```

有精度损失的转换两个与float相关。
一个与long转double相关。

原因：int是4字节。float也是4字节。因此int转为相应的float有精度损失是可以理解（float的尾数只有23位），更别提long转float。相似的可以理解long转double。而int转double没有精度损失是因为double的尾数有52位，完全可以表达int类型的所有值。

精度损失的具体理解：float与double都是尾数加指数来存储的，其尾数是有位数限制的。`1_2345_6789`是一个int型数，需要转为float后位`1.23456792E8`。之所以比原来大了3，是因为`123456789`用二进制表示为`1_1101_0110_1111_0011_0100_0101_01`，浮点数首位1不存，尾数23位，实际上最后的`101`三位会舍弃，二进制三位最大为7，`101`为5，故而进1, 也就是在原来的值上-5+8，因此实际值大了3。

### 类型转换规则

书中讲二元运算时需要将其中一种类型转换为另外一个种类型。转换的规则为

* 如果两个操作数有一个是double类型，另一个也会转换为double类型
* 如果两个操作数有一个是float类型，另一个也会转换为float类型
* 如果两个操作数有一个是long类型，另一个也会转换为long类型
* 否则，两个操作数都将被转换为int类型。

注意，这意味着byte、char、short类型之间的运算都会被转为int类型。

我们也知道int转float、long转double会损失精度并自动四舍五入，那么这种转换会导致关系运算符出现诡异的结果吗？

确实会。看下面这个例子：
```brush:java

        int a1 = 123456789;
        float a2 = 1.23456790E8f;
        float a3 = a1;
        System.out.println(a2);
        System.out.println(a3);
        System.out.println(a1 < a2);
        System.out.println(a3 < a2);

// Output:
// 1.23456792E8
// 1.23456792E8
// false
// false
```

所以我们一定要避免有精度损失的类型自动转换。

问题1：所有的二元运算都会发生这种转换吗？或者说，自动转换发生在哪些时候？

问题2：JLS中又是怎么讲的呢？

JLS：https://docs.oracle.com/javase/specs/jls/se14/html/jls-5.html

## 3.5.3 强制类型转换

除了上小节图中提到的各种合法转换之外，有时候需要逆箭头转换，这时候就需要强制类型转换（cast）。

强制类型转换是通过直接截断进行的：
* 浮点型转整型：截断小数部分
* 大整型转小整型：截断高位部分
* double转float: 尾数与指数如何截断？

## 3.5.4 结合赋值与运算符

就是 文章末尾 补充部分 扩展运算符。

书中提到了一个例子：

```brush:java

int x = 1;
x += 3.5;
System.out.println(x);
//Output: 4
```
这其中发生的类型转换:首先x+3.5将x转换为double类型，结果也为double类型，然后再强制转换为int类型。相当于`x = (int)(x+3.5)`。由此可见，所谓强制类型转换也可以是自动发生的。


--------------------

首先关于类型转换应该是没有强制类型转换与自动类型转换的概念的，
而是转换上下文与转换类型的碰撞。

## 3.5.5 自增与自减运算符
类似C语言， 自增与自减运算符各有“前缀”“后缀”两种形式，区别在于是先运算还是先赋值。

## 3.5.6 关系与boolean运算符

`&&`与`||`运算都是按照短路方式来求值的。这一点通常用来精简条件判断，如：

```brush:java
x!=0 && 1/x > x + y; // no division by 0
```

## 3.5.7 位运算符

`&`-与   `|`-或   `^`-异或   `~`-非。这些运算时所有位都参与运算，包括符号位。

`>>`有符号右移运算符。

`>>>` 无符号右移运算符。

`<<` 左移全都补0，与符号无关，因此没有`<<<`。

应用在布尔值上时，`&`与`|`运算符也会得到一个布尔值。
这些运算符与`&&`和`||`运算符很类似，但是不会用“短路”的方式来求值。看下面的例子：

```brush:java
boolean cond1 = somemethod1();
boolean cond2 = somemethod2()
// 第一组
if(cond1 && cond2){
    ...
}
// 第二组
if(cond1 & cond2){
    ...
}
```

## 3.5.8 括号与运算符级别

## 3.5.9 枚举类型

# 3.6 字符串

上面讲到代码点与UTF16代码单元不是一个概念，同时在unicode中，代码点与字符也不是一个概念，这是因为组合字的存在。

要想判断一个代码点的“流”中哪些代码点构成一个字，需要借助[ICU]()工具。

下面看一个例子：


# 3.9 大数值

# 3.10 数组

# 补充

## java中操作符

一元操作符：`++ -- ~`

二元操作符：

* 算术运算符：`+ - * / %`
* 赋值运算符：`=`
* 关系运算符：`> < <= >= == !=`
* 逻辑运算符：`&& || !`
* 位运算符: `& | ^ >> << >>>` 注意：`~`运算在一元操作符分类中
* 扩展运算符: 算术运算符与位运算符(除了`~`)右侧加'='都是扩展运算符

一个异或扩展运算的例子：
```brush:java
//^ 异或运算
int m = 10; //10 = 0b1_0010
m ^= 3; // 3 = 0b11
System.out.println(m); //异或运算后：m = 0b1_0001

m = ~m
//m为32位int 每位取反（包括符号位）后:m = 0b11111111_11111111_11111111_11101110
//注意这会被当做是补码，因而是-10
System.out.println(m);

//Output:
// 9
// -10
```

三元操作符：
* 条件运算符: ? :

## 运算与溢出

两个byte数127+127会怎么样？

自动类型转换都当成int来处理是什么意思？

## java中unicode处理

对应组合字，下面这个例子是怎么样的

```brush:java
String s2 = "𤋮";
System.out.println(s2.getBytes().length);
System.out.println(s2.codePoints().count());
System.out.println(s.length());
System.out.println(s.codePointCount(0, s.length()));
```

## 两种与或非

## 哪些类型可以参与关系运算符与位运算符？

8中基本类型都可以参与吗？

两个布尔类型比较大小？进行移位运算？进行