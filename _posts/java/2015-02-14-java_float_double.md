---
layout: post
category : java
tagline: "Supporting tagline"
tags : [java]
title : 浮点数相关
---

* toc
{:toc}

<hr />

# 二进制形式的科学计数法

对于十进制，我们知道有e跟指数的科学计数法。同样，对于二进制也要相应的科学计数法：
其可以表示为：

$$a * 2^b, 1\le a \lt 2, b=0,1,2,3...$$

# 浮点数的标准

## IEEE754
浮点数的计算机表示与运算是有相关标准的，既IEEE754。有关该标准可参考[wiki][0]。

## 内存格式

IEEE754规定了单精度与双精度浮点数的存储格式，其都遵循如下格式。

```
 - - - - - - - - - - - -
| 符号  | 指数  | 尾数  |
 - - - - - - - - - - - -
```

符号位需要1bit。对于单精度浮点数，尾数有23bit。那么指数部分就是8bit。对于双精度浮点数，尾数有52bit。指数有11bit。

需要注意的是尾数与指数在IEEE754规定的格式中不是直接存储的。

对于十进制来说，尾数是10以内的数字，对于二进制来说，尾数2以为的数字，也就是说尾数的整数部分永远都是1。

指数当然可以是负数，但是需要注意的是指数部分并非是区分正负按照补码或者原码来存储的。指数部分没有符号位，也就是说指数部分永远是大于等于0的数，那么如何表示负指数呢？方法就是用指数部分存储的值减去一个“指数偏移量”，对于单精度指数，偏移量是127，因此8位指数实际表示的指数范围是[-127, 128]。对于双精度指数，偏移量是1023，因此11位指数实际表示的范围是[-1023, 1024]。

并非指数范围内的所有指数都是正常浮点数可用的，实际上，两个端点的值有特殊用途，也就是说，对于单精度，指数取值范围为[-126, 127]，双精度范围为[-1022, 1023]。指数部分存储的全0或者全1的时候有特殊含义，下面会再提到。

## 表达式

浮点数的值可以用如下表达式来计算：

$$value = (-1)^{sign} * decimal * 2^{exponent} \tag {1}$$

其中$$decimal = 1 + m, exponent = c - offset $$。

尾数部分m的值可以表示为：

$$ m =\sum_{i=1}^{i=23} m_i * 2 ^{-i} \tag{2}$$

offset就是上面提到的指数偏移量。上面提到指数与尾数都不是直接存储的，指数存储的是c，实际计算要减去偏移量。尾数部分存储的是m，1不变因此省去。既然尾数部分用于包含一个1，指数部分又不可能是0，那么如何表示0呢？

上面提到当指数部分全0或者全1的时候有特殊含义，其中就解决了表示0的问题。实际上配合m，有如下4种情况：

* m = 0 指数所有bit为0  表示0 因为单独符号位的缘故，浮点数其实是有正负0的，这点不像是补码表示的整型
* m = 0 指数所有bit为1 表示正负无穷大。正负看符号位。
* m != 0  指数所有bit为0 非正规化数字
* m != 0 指数所有bit为1 表示NaN

以上部分参考自[这里][1]。

# 精度与范围

浮点数并不能表示精确的表示任意小数。

## 32位
尾数部分23位，根据表达式2，m的取值范围为[0, 1-2^(-23)]。因此单精度浮点数的尾数部分的差最小为2^(-23)。
2^(-23)约等于1.1920928955078e-7，也就是小数点后第7位。因此，10进制的小数第8位以及之后的位数是绝不可能用32位浮点数表示的。

但这并不意味者7位以及以内的小数，32位浮点数就能精确表示，比如1.4, 浮点数（不论32位还是64位）是无法精确表示的，因为按照附录中
转换为二进制小数的方法，1.4的二进制表示是个无限循环小数。

以上就是有效位数为6位或7位的精确含义。对任意一个32位浮点范围内的小数，即便是有效位数以内，也大概率是近似表示的。有效不代表精确。

当m取1-2^(-23)，尾数部分约等于2，且指数取127时，32位浮点数取得最大值约等于2^128，约等于3.4028236692094e+38。

## 64位
同样的方法，可知双精度浮点数尾数部分的差最小是2^(-52)，约等于2.22e-16，所以双精度只能保证15或者16位的有效数字。

双精度的最大表示范围为2^1024，约等于2e308。

# 浮点数的坑

## 近似表示与舍入

由于有限位数的二进制小数不能一一对应地表示有限位数的十进制小数，因此通常一个十进制数表示成二进制的时候是近似表示的。
当然0.5或者0.75这种可以精确表示，但是1.4就无法精确表示，其二进制是无限循环小数，实际存储的值是1.39999997615814208984375。这一点可以通过[浮点数在线工具][2]
来验证。但是如果通过`System.out.println(1.4f)`来打印的话，会发现打印的仍然是`1.4`，既然实际存储的是`1.3999...`，为什么打印出来不是实际存储的值呢？这是因为`println`函数自动做了舍入，如果通过`printf("%.100f", 1.4f)`来打印的话，就可以看出来实际存储的并非1.4。

同样，在单精度的情况下，0.49999999也无法精确表示，因为其有效位数不够，单精度存储做一个舍入之后实际存储的是0.5，这也可以通过上面提到的工具验证。

由以上讨论可知，三种情况下会出现舍入：

* 二进制小数表示是无限尾数小数
* 二进制小数位数有限，但其精确表示超出了单精度或双精度的尾数位数限制
* 打印的时候

三种情况中，打印的情况需要留意自定义小数尾数格式。第二种情况应该是避免的，因为这实际上因为选取的数据类型不对（应该用双精度选了单精度，应该用BigDecimal使用了双精度等等）。第一种情况是最常见的。

不论哪种原因，浮点数的这种近似表示的特性会带来很多意想不到的麻烦，下面看几个案例。

### 案例1
比如说，我们收集了一批数据，希望对其做四舍五入取整，自然应该用`Math.round()`函数。

数据中一个数是0.49999999，而我们错误的是用来单精度来存储，导致精度损失，实际存储的是0.5。这样做四舍五入的结果必然是跟数据不符的。

### 案例2
对于任意一个满足浮点数有效位数限制的浮点数，我们希望求出其整数部分的位数，一个自然的思路是求log再加1， 也就是使用`Math.log10()`函数。

```brush:java

System.out.printf("%.20f\n", Math.log10(100000000001f));
System.out.printf("%.20f\n", Math.log10(100000000000f));
System.out.printf("%.20f\n",Math.log10(99999999999f));

```
Output:
```
10.99999999110564800000
10.99999999110564800000
10.99999999110564800000
```
可以看到第一与第二个结果都不对，但若是改用双精度，则三个结果都能正确：

```
11.00000000000434300000
11.00000000000000000000
10.99999999999565700000
```

原因我未深究，但猜测是是因为
log10函数实际上是用级数展开式计算的，双精度的情况下，级数也是双精度的，因而能保留足够精确的结果。


### 案例3
下面的计算结果显然违反数学规则，这也是由于精度损失导致的。

```Brush:java
  double d = 29.0 * 0.01;
  System.out.println(d);
  System.out.println((int) (d * 100));

// Output:
// 0.29
//   28
```

## NaN、0与无穷大
NaN既“Not a Number”。

正常计算产生NaN的方式有：

* 0/0 正负无穷大/正负无穷大
* 正无穷大-正无穷大 负无穷大-负无穷大

应该还有其他计算也会产生NaN。

正常计算产生无穷大的方式有：
* 正数/0 -> 正无穷大
* 负数/0 -> 负无穷大
* Double.MAX_VALUE + Double.MAX_VALUE
* Double.MAX_VALUE * Double.MAX_VALUE

(Double.MAX_VALUE+1并不会导致无穷大，Double.MAX_VALUE/2+Double.MAX_VALUE却会导致无穷大，java判断结果是无穷大的标准是什么？)

无穷大满足有序性。也就是可以比较任意“普通”浮点数与无穷大得到正确的结果，比如`3.14f < Float.POSITIVE_INFINITY == True`

不管是产生NaN也好，无穷大也好，都是满足数学规则的，并且java计算出NaN或无穷大并不会抛异常，以为这符合数学规律。

前面“表达式”一节提到，浮点数的是由正负0的，数学意义上正负0的写法是允许的，当然也是相等的。因此在java中也有
`0f == -0f`。

## 数学比较、字典序比较与对象比较

这三种类型的比较是我自己区分的，虽然有助于理解与记忆，但实际上并不严格。

java中浮点数分基本类型与包装类型。基本类型的含义就是一个数学意义上的数字，而包装类型除了是数字外还是一个对象。

二者都有的操作是数学比较，也就是`==`与`> < <= >= !=`等运算符来比较。包装类型有自己的`compare\compareTo\equals`方法，但是语义不再是数学比较。

对于数学比较，有以下情况：
```brush:java
Float.NaN == Float.NaN;  // false
-0f == 0f;				// true
```

然而吊诡的是无穷大的比较：
```brush:java
Float.POSITIVE_INFINITY == Float.POSITIVE_INFINITY; //true
```
正无穷大居然是相等的，但与此同时又有
```brush:java
Float.isNaN( Float.POSITIVE_INFINITY - Float.POSITIVE_INFINITY );
```

对于包装类型的`compare/compareTo`方法来说，其意义更像是字典序比较，这可以通过查看JDK源码得知：
```brush:java
	//取自Float.class

    public int compareTo(Float anotherFloat) {
        return Float.compare(value, anotherFloat.value);
    }

    public static int compare(float f1, float f2) {
        if (f1 < f2)
            return -1;           // Neither val is NaN, thisVal is smaller
        if (f1 > f2)
            return 1;            // Neither val is NaN, thisVal is larger

        // Cannot use floatToRawIntBits because of possibility of NaNs.
        int thisBits    = Float.floatToIntBits(f1);
        int anotherBits = Float.floatToIntBits(f2);

        return (thisBits == anotherBits ?  0 : // Values are equal
                (thisBits < anotherBits ? -1 : // (-0.0, 0.0) or (!NaN, NaN)
                 1));                          // (0.0, -0.0) or (NaN, !NaN)
    }

```

可以看到是通过比较浮点数的每个比特来比较大小的。我们知道浮点数在内存中存储是按照`符号位、指数位、尾数`来存的，通常情况下这与数学比较意义是一致的。

但是对于正负0来说，有`Float.compare(-0f, 0f) == -1`成立，按比特的字典序比较，这种行为可以理解的。

同样，也很容易理解：
```brush:java
Float.compare(Float.NaN, Float.NaN)
Float.compare(Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY) == 0
```

需要注意的是上面的代码仅仅是说明`compare`的行为，`Float.NaN`与`Float.POSITIVE_INFINITY`都是基本类型，而不是保证类型。


对于`equals`方法，其源码如下：
```brush:java
    public boolean equals(Object obj) {
        return (obj instanceof Float)
               && (floatToIntBits(((Float)obj).value) == floatToIntBits(value));
    }
```
可以看到其行为与`compareTo\compare`是一致的。

另外,当然`hashcode`的行为也与`equals`一致。
```brush:java
    public static int hashCode(float value) {
        return floatToIntBits(value);
    }
```

## 浮点数比较
以下引自[资料][3]。

由于存在 NaN 的不寻常比较行为和在几乎所有浮点计算中都不可避免地会出现舍入误差，解释浮点值的比较运算符的结果比较麻烦。

最好完全避免使用浮点数比较。当然，这并不总是可能的，但您应该意识到要限制浮点数比较。如果必须比较浮点数来看它们是否相等，则应该将它们差的绝对值同一些预先选定的小正数进行比较，这样您所做的就是测试它们是否”足够接近”。（如果不知道基本的计算范围，可以使用测试”abs(a/b – 1) < epsilon”，这种方法比简单地比较两者之差要更准确）。甚至测试看一个值是比零大还是比零小也存在危险 ―”以为”会生成比零略大值的计算事实上可能由于积累的舍入误差会生成略微比零小的数字。

NaN 的无序性质使得在比较浮点数时更容易发生错误。当比较浮点数时，围绕无穷大和 NaN 问题，一种避免 gotcha 的经验法则是显式地测试值的有效性，而不是试图排除无效值。在清单 1 中，有两个可能的用于特性的 setter 的实现，该特性只能接受非负数值。第一个实现会接受 NaN，第二个不会。第二种形式比较好，因为它显式地检测了您认为有效的值的范围。

```brush:java
	//浮点比较中，白名单模式比黑名单模式要好
    // Trying to test by exclusion -- this doesn't catch NaN or infinity

    public void setFoo(float foo) {
      if (foo < 0)
          throw new IllegalArgumentException(Float.toString(f));
        this.foo = foo;
    }

    // Testing by inclusion -- this does catch NaN

    public void setFoo(float foo) {
      if (foo >= 0 && foo < Float.INFINITY)
        this.foo = foo;
      else
        throw new IllegalArgumentException(Float.toString(f));
    }

```

## 无效的浮点假定
另外[资料][3]中提到了一个“无效的浮点假定”表，其实这个表数学上是成立的，只是因为浮点运算运行`NaN\Infinity`参与，导致的“反直觉”。

<table class="bx--data-table-v2 bx--data-table-v2--compact"><thead xmlns:dw="http://www.ibm.com/developerWorks/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<tr>
<th><span class="bx--table-header-label">这个表达式&#8230;&#8230;</span></th>
<th><span class="bx--table-header-label">不一定等于&#8230;&#8230;</span></th>
<th><span class="bx--table-header-label">当&#8230;&#8230;</span></th>
</tr>
</thead><tbody xmlns:dw="http://www.ibm.com/developerWorks/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<tr>
<td><code style="font-family:monospace;font-size:1rem">0.0 - f</code></td>
<td><code style="font-family:monospace;font-size:1rem">-f</code></td>
<td>f 为 <code style="font-family:monospace;font-size:1rem">0</code></td>
</tr>
<tr>
<td><code style="font-family:monospace;font-size:1rem">f &lt; g</code></td>
<td><code style="font-family:monospace;font-size:1rem">! (f >= g)</code></td>
<td>f 或 g 为 NaN</td>
</tr>
<tr>
<td><code style="font-family:monospace;font-size:1rem">f == f</code></td>
<td><code style="font-family:monospace;font-size:1rem">true</code></td>
<td>f 为 NaN</td>
</tr>
<tr>
<td><code style="font-family:monospace;font-size:1rem">f + g - g</code></td>
<td><code style="font-family:monospace;font-size:1rem">f</code></td>
<td>g 为无穷大或 NaN</td>
</tr>
</tbody></table>

# 浮点数的应用场景

一些非整数值（如几美元和几美分这样的小数）需要很精确。浮点数不是精确值，所以使用它们会导致舍入误差。因此，使用浮点数来试图表示象货币量这样的精确数量不是一个好的想法。使用浮点数来进行美元和美分计算会得到灾难性的后果。浮点数最好用来表示象测量值这类数值，这类值从一开始就不怎么精确。

以上两节参考自[这里][3]。

# 使用BigDecimal类

有关`BigDecimal`的说明除了参考JavaDoc外还可参考[这篇][5].

## BigDecimal的比较行为
首先BigDecimal不支持直接使用`> < ==`等操作符进行比较，需要调用相应的方法`compareTo`或`equals`。

其次BigDecimal类中compareTo与equals的语义不再像包装浮点型一样一致。

```brush:java
BigDecimal bd_1 = new BigDecimal("100.00");
BigDecimal bd_2 = new BigDecimal("100.000");
System.out.println(bd_1);
System.out.println(bd_2);
System.out.println(bd_1.equals(bd_2));
System.out.println(bd_1.compareTo(bd_2));
```

当然这些都在javadoc中有说明。

`compareTo`javaDoc:

	Compares this BigDecimal with the specified BigDecimal. Two BigDecimal objects that are equal in value but have a different scale (like 2.0 and 2.00) are considered equal by this method. This method is provided in preference to individual methods for each of the six boolean comparison operators (<, ==, >, >=, !=, <=). The suggested idiom for performing these comparisons is: (x.compareTo(y) <op> 0), where <op> is one of the six comparison operators.

`compareTo`执行的是数学意义的比较。

`equals`javaDoc:

	Compares this BigDecimal with the specified Object for equality. Unlike compareTo, this method considers two BigDecimal objects equal only if they are equal in value and scale (thus 2.0 is not equal to 2.00 when compared by this method).

`equals`执行的是对象意义上的是否相等。

# 浮点数总结

* 精度有限 
* 范围有限（上下溢出）
* 有效位数内也不一定精确表示。

如何测试相等：首先应该搞清楚自己想要哪种意义（数学、字典序、对象）上的相等。然后根据自己使用的是基本浮点类型、
包装浮点类型还是BigDecimal来判断应该采用上面的哪种测试方法。

# 附录：进制与进制转换

## 浮点数在线工具

[单精度][2]

[双精度][4]

## 进位制

所谓N进位制既是满N进1。每位的权重可表示为$$N^{n-1}$$。

任意一个m位N进制数都可以表示成：

$$ a_0 * N^0 + a_1 * N^1 + a_2 * N^2 + ... + a_{m-1} * N^{m-1} \tag{1} $$

进位制的特点1:高位的权重很大，大过所有低位的取最大数的和。比如十进制第5位权重为10000，前4位每位取最大数9，其和为9999。

特点2：任意一位的系数都小于N。

## M进位与N进位的相互转换

从 公式1可以看出，所谓转换成N进制就是确定N进制下其各项系数。

假定我们已经知道要转换的数的值为x。那么观察公式1可知，确定x在N进制下的各项系数有两种方法：

1. 根据特点1，找出x大于等于的最大的$$N^m$$。然后除以这个$$N^m$$，商就是第m+1位的值。余数继续除以$$N^{m-1}$$，进而确定第m为的值。
依次类推，确定各位。

2. 根据特点2，x除以$$N$$，余数就是第1位的值。商继续除以$$N$$，余数就是第2位的值。依次类推，确定各位。

但这里面的问题就是x是M进制的，在方法1中，如何比较M进制的x与$$N^m$$的大小是问题一。在两个方法中如何用M进制除以N做除法是问题二。
这两个问题的答案都是10进制。实际上，所谓的值x既是10进制意义下的x。

问题一中$$N^m$$既然是10进制意义下的，因此x也应该是10进制的。问题中N也是10进制意义下的，因此x也应该是10进制的。

实际应用中，整数的转换用方法2。小数的转换为方法1。之所以如此，是因为小数的情况下我们很容易知道最大的权重，也即是$$N^{-1}$$，而不容易知道最小的权重。

而整数的情况下，很容易知道小的权重也就是$$N^0$$，而不容易知道最大的权重。当然除以1没有意义，因此使用次小的权重$$N$$。


[0]:https://www.wanweibaike.com/wiki-IEEE%E6%B5%AE%E7%82%B9%E6%95%B0%E6%A0%87%E5%87%86
[1]:https://zhuanlan.zhihu.com/p/58731780
[2]:https://www.h-schmidt.net/FloatConverter/IEEE754.html
[3]:https://developer.ibm.com/zh/articles/j-jtp0114/
[4]:http://www.binaryconvert.com/convert_double.html
[5]:/2019/08/12/java_math