---
layout: post
title: 单元测试概念
description: ""
category: 软件工程
tags: [unit test, test, software enginerring]
---
{% include JB/setup %}

* toc
{:toc}

<br />



## 单元测试用来做什么
https://en.wanweibaike.com/wiki-Unit%20test
https://www.wanweibaike.com/wiki-Component%20or%20Unit%20testing
https://martinfowler.com/bliki/UnitTest.html

单元测试与自动化测试：
http://xunitpatterns.com/Goals%20of%20Test%20Automation.html#Defect%20Localization
In this chapter I describe the goals we should be striving to reach to ensure successful automated unit tests and customer tests. 
自动化测试通常应该进行的两种测试：单元测试与客户测试。意味着单元测试是自动化测试的一部分。


## 什么是一个”单元“

https://stackoverflow.com/questions/1066572/what-should-a-unit-be-when-unit-testing
https://www.blinkingcaret.com/2016/04/27/what-exactly-is-a-unit-in-unit-testing/
https://osherove.com/blog/2012/5/15/what-does-the-unit-in-unit-test-mean.html
## 参数化测试
又叫数据驱动测试
https://en.wanweibaike.com/wiki-Parameterized%20test


## 单元测试框架

https://en.wanweibaike.com/wiki-Unittest

https://blog.csdn.net/zhang_yin_liang/article/details/90577017

## 测试用具

https://en.wanweibaike.com/wiki-Test_harness

## 测试的标准4个步骤

xunit 546

## Test Doubles

https://cloud.tencent.com/developer/section/1345504

https://www.ibm.com/developerworks/cn/java/j-lo-TestDoubles/index.html

https://blog.csdn.net/benkaoya/article/details/100046470

http://xunitpatterns.com/Test%20Double.html

### 各种测试替身的区别

http://xunitpatterns.com/Mocks,%20Fakes,%20Stubs%20and%20Dummies.html

https://zhuanlan.zhihu.com/p/26942686

https://martinfowler.com/bliki/TestDouble.html

https://www.endoflineblog.com/testing-with-doubles-or-why-mocks-are-stupid-part-1

https://www.jianshu.com/p/7a04f28b08a6

https://martinfowler.com/articles/mocksArentStubs.html

### 测试替身模式

http://xunitpatterns.com/Test%20Double%20Patterns.html

### mock
关于mock的两种模式："action -> assertion" mocking pattern, standard "record(story) -> replay" pattern


## 测试代码的组织


如何处理单元之间的依赖

如何处理网络、多线程

## 测试模式

xunit网站

## 难以测试的代码

### 固有难度的测试场景

这里列举了三种典型场景并有分析与可能的解决方案
http://xunitpatterns.com/Hard%20to%20Test%20Code.html

####  高度耦合的代码

使用测试替身

#### 异步代码

#### 不可测代码

### 人为增加测试难度的编程方法


## 单元测试与TDD


## 单元测试实践中的误区

http://sdk.org.nz/2009/02/25/why-unit-testing-is-a-waste-of-time/ 评论部分Nick Bauman