

类型理论与类型系统
	结构化类型
	名义类型
	Duck Type


type与class

subtype与subclass

编程语言的范式：https://en.wikipedia.org/wiki/Programming_paradigm

## 面向对象与基于对象

## 基于过程与函数式编程


## 闲说OOP

### 抽象

### 封装

### 继承

实现继承的问题：
破坏封装
	脆弱基类

接口继承的问题：

### 多态

#### 继承实现多态

##### 动态绑定

动态绑定这个事情说起来很新鲜，但不是凭空挂在OOP的4个基本特征下的，只有使用继承来实现多态的时候，才有必要用到动态绑定。

那么go与python中有多态吗，有动态绑定吗？

首先我们要搞清楚什么是class，什么是object。面向对象编程里object是一组数据与操作的集合。
而class则是用于定义object的结构与操作的（当然并不是所有的oop都需要class，存在如JS那种基于原型的OOP，也就是OOP最重要的是
Object）。操作也就是函数或者说方法，是绑定了一个小的执行环境也就是object来执行的。

本来嘛，class给出object的定义后也就绑定了操作与object的关系。但是OOP中允许object与object之间存在层级关系。基于class的OOP
通过class之间的层级关系来定义object之间的层级关系，而基于原型的OOP直接通过object本身来定义之间的层级关系。这还不算完，基于class的
OOP中，一个class本身相当于定义了一种类型，这本来没什么，就像C语言中结构体用来自定义各种类型一样。但是当class之间存在层级关系时，就不得不考虑
class的类型特征与[类型系统][0]的关系了。

##### 结构化类型实现多态


## 各种语言特征

### python
有接口与多态的概念吗
鸭子类型。
为什么说python没有类型，或者说python称得上强类型吗

### go语言
Go（又称 Golang）是 Google 的 Robert Griesemer，Rob Pike 及 Ken Thompson 开发的一种静态强类型、编译型语言。Go 语言语法与 C 相近，但功能上有：内存安全，GC（垃圾回收），结构形态及 CSP-style 并发计算。

#### 接口

#### 结构形态

#### 并发计算

### JS语言

#### 基于原型
有继承、多态的概念吗