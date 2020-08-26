---
layout: post
title: java类加载器
description: ""
category: java
tags: [java]
---
{% include JB/setup %}

* toc
{:toc}

<br />

## 类的生命周期与类加载器

### 类的加载时机

### 类加载器的作用

## Hotspot中类加载器的设计

### 三层类加载器

为什么要这么设计

BootstrapClassLoader与AppClassLoader的默认目录

### 双亲委派

### 打破双亲委派

## 自定义类加载器

## 热替换

## 与python的对比








src\main\org\apache\tools\ant\Project.java里的例子
```
//L1221
            try {
                o = Class.forName(classname, true, coreLoader).newInstance();
            } catch (final ClassNotFoundException seaEnEfEx) {
                //try the current classloader
                try {
                    o = Class.forName(classname).newInstance();
                } catch (final Exception ex) {
                    log(ex.toString(), MSG_ERR);
                }
            } catch (final Exception ex) {
                log(ex.toString(), MSG_ERR);
            }
```
这两个class.forName的区别是什么


委派模型

classloader本身也是个class，也需要被loader 因此是树状结构

classloader可以指定默认搜索路径吗

类是什么时候被自动加载的，import的时候吗

module与package是一回事吗

有没有办法更新已加载的类

每个classloader有自己的缓存空间

自定义类加载器的应用场景

类什么时候被加载 其对应的指令是什么

classloader的规范相关

java为什么要设计不同层级的classloader


用于初始化的静态域放在哪儿

code attribute与method的关系

classloader的类关系图

classloader的父类是谁加载它他就把谁设置为父类吗

如何打破双亲委派模型





