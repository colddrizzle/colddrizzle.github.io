---
layout: post
title: C中的结构体对齐
description: ""
category: c&cpp
tags: [c&cpp, struct align]
---
{% include JB/setup %}

* toc
{:toc}


# 对齐规则

对齐规则就是规定按几个字节对齐，最重要的就是确定对齐字节数。

其影响包含两方面：
1. 结构体中每个成员的起始地址必须是对齐字节数的整数倍。

2. 整个结构体的大小必须是对齐字节数数的整数倍。

第二条的意义是：结构体的最后一个成员的长度若是小于对齐字节数，其后面会补0（仿佛后面还有一个结构体成员需要对齐一样）。

比如short长度为2，int长度为4：
```brush:cpp
struct any{
	int a;
	short b;
}
```
如果使用对齐指令是的上面的安装4字节对齐，整个结构体的大小会是8而不是6。当然如果按照2字节对齐，整个结构体大小就是6了。

很容易推断出，4字节对齐的时候下面的整个结构体大小为20。

```brush:cpp
struct any{
	char array[9];
	int a;
	short b;
}

```

上面的规则是与编译器无关的，所有编译器都这样。

无非是各编译器的默认对齐字节数与对齐指令不同。

# 确定对齐字节数
由上面可知，最重要的就是确定对齐字节数。

有时候，对齐字节数并不是看上去的那个数（编译器默认或者对齐指令里指定的数）


## 对齐字节数的计算

设编译器或对齐指令指定的数为n。

结构体成员中字节最宽的类型的为m，这个成员不包括数组与嵌套结构体，比如：

```brush:cpp
struct a{
	long long array[100];
	int a;
	short b;
	struct any_structy;
}
```

最宽的类型为成员`int a`的`int`类型。数组与结构体被忽略，这很好理解，数组与结构体可看做一种“流动地可伸缩”的字节串，不存在固定宽度。

运算γ(x)为求不小于x的最小的2的幂，γ(3) = 4。

则对齐字节数为γ(min(m, n))。

因此，假设int宽度为4，则下面的结构体大小为20。

```brush:cpp
#pragma pack(11) //11其实不生效，最大位宽为4
struct in{
    char array[9];
    int b;
    short a;
};
```


从上面可以看出，实践中我们还需要确定各个编译器的默认对齐字节数与对齐指令风格。

## 各编译器默认对齐

貌似VC是按照结构体最宽类型来对齐的。

gcc除了上面的规则之外，外加一条最高宽度限制。32位为4字节，64位为8字节。

区别在于，32位下`long long`类型为8字节。VC下按8字节对齐，gcc下按4字节对齐。

以上都没有验证过，抄的这里：https://blog.csdn.net/striver1205/article/details/41211473

## 使用对齐指令

VC下的[对齐指令风格](https://docs.microsoft.com/en-us/cpp/preprocessor/pack?view=vs-2019)：

```brush:cpp
#pragma pack(2)
struct in{
    int b;
    short a;
};
```

MingWGCC的对齐指令风格与VC一致。

GCC下的对齐指令风格:

```brush:cpp
struct in{
    int b;
    short a;
}__attribute__((aligned(2)));
```

# 其他资料
http://c.biancheng.net/view/243.html

https://blog.csdn.net/striver1205/article/details/41211473