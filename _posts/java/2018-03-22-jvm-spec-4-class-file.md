---
layout: post
title: Java虚拟机规范之类文件格式
description: ""
category: java
tags: [java]
---
{% include JB/setup %}

* toc
{:toc}

<br />

？：常量池常量类型
https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4-140

？：attributes数组是如何知道每个元素的类型的

```
attribute_info attributes[attributes_count];
```

原因在于每种attribute结构体的前两个元素都是一样的，存储了该attribute的类型与长度
```
    u2 attribute_name_index;
    u4 attribute_length;
```

？：attribute的种类与位置。

attribute可以出现在多个地方。比如
```
field_info {
    u2             access_flags;
    u2             name_index;
    u2             descriptor_index;
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}

method_info {
    u2             access_flags;
    u2             name_index;
    u2             descriptor_index;
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}
```
都可以有attribute，其attribute的种类是不一样的。
按位置划分可以允许的attribute有表格：
https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.7-320


？静态代码块与非静态代码块都编译为`method_info    methods[methods_count];`的一部分。


？描述符：分为field描述符与method描述符。

描述符以一种约定结构的字符串。用来表示field与method的类型（方法签名）。

https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.3

关于field描述符：尤其要注意数组描述符

数组描述符的维度不能超过255
https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.3.2

关于方法描述符：
方法描述符的参数个数不得多于255个：
A method descriptor is valid only if it represents method parameters with a total length of 255 or less, where that length includes the contribution for this in the case of instance or interface method invocations. The total length is calculated by summing the contributions of the individual parameters, where a parameter of type long or double contributes two units to the length and a parameter of any other type contributes one unit.

A method descriptor is the same whether the method it describes is a class method or an instance method. Although an instance method is passed this, a reference to the object on which the method is being invoked, in addition to its intended arguments, that fact is not reflected in the method descriptor. The reference to this is passed implicitly by the Java Virtual Machine instructions which invoke instance methods (§2.6.1, §4.11).


描述符在class文件中的使用：
各种常量结构中的`descriptor_index`中。

包括下面5种
```
field_info {
    u2             access_flags;
    u2             name_index;
    u2             descriptor_index;
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}

method_info {
    u2             access_flags;
    u2             name_index;
    u2             descriptor_index;
    u2             attributes_count;
    attribute_info attributes[attributes_count];
}

CONSTANT_NameAndType_info {
    u1 tag;
    u2 name_index;
    u2 descriptor_index;
}

CONSTANT_MethodType_info {
    u1 tag;
    u2 descriptor_index;
}

LocalVariableTable_attribute {
    u2 attribute_name_index;
    u4 attribute_length;
    u2 local_variable_table_length;
    {   u2 start_pc;
        u2 length;
        u2 name_index;
        u2 descriptor_index;
        u2 index;
    } local_variable_table[local_variable_table_length];
}
```

`descriptor_index`本身指向的是常量池中`CONSTANT_Utf8_info`类型的常量。具体是field描述符还是method描述符由上面结构体决定。
field_info中的自然指向的就是一个



？：field与method在class中的存储。

第一层结构：
https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.4.2

参见上述表，因为一个class文件中可以定义多个class或接口，因此其有一个class_index属性。
`name_and_type_index`指明其名字与类型。类型自然是两种描述符形式。

第二层结构：
field的初始值与method的方法体是怎么关联过来的？？

通过field_info与method_info中的某个attribute。
更确切的说：


	specifical method? <init>与 <clinit>


自己写的代码块与自动生成的代码块谁先谁后？


？：method_info与CONSTANT_MethodType_info的联系与区别

method_info中有个

？：Field_info与CONSTANT_Fieldref_info Method_info与CONSTANT_Methodref_info 



？：与反射或lambda表达式相关的部分：
CONSTANT_MethodHandle_info？


CONSTANT_InvokeDynamic_info？


？：类文件格式之修饰符
https://blog.csdn.net/weixin_42090746/article/details/103511359