---
layout: post
category : python
tagline: "Supporting tagline"
tags : [python, test]
title: python测试概念与工具
---
{% include JB/setup %}


* toc
{:toc}

<hr />

除了单元测试还有各种其他测试，参考官网给出的python测试框架分类：https://wiki.python.org/moin/PythonTestingToolsTaxonomy

还有python自带的doctest，适用于非常轻量级测试的情况，而且doctest有效避免了注释老化的问题。因为
doctest意味着注释本身也要通过测试，是个“双向”测试。