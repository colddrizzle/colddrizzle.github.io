---
layout: post
category : python
tagline: "Supporting tagline"
tags : [python, test]
title: python-unittest
---
{% include JB/setup %}


* toc
{:toc}

<hr />


本文只是python 3 自带的unittest官方文档要点笔记。

有关单元测试基本概念请参考《单元测试概念》篇。

## unittest中概念

* test fixture

* test case

* test suite

* test runner

## 使用方式
在test源码中调用：

```
unittest.main()
```

使用命令行，可以测试整个包、模块、类或单个方法：

```
python -m unittest filename[.classname[.methodname]]
```

使用Test discover（自动搜索）:

```
python -m unitest discover

python -m unittest
```
test discover 默认情况下搜索以test开头的文件`test*.py`，可以用`-p`指定文件模式。

当开始运行后，test runner将测试模块中继承了`unittest.TestCase`的类中以`test`开头的方法。

## 代码组织

### 原则
The basic building blocks of unit testing are test cases — single scenarios that must be set up and checked for correctness.

The testing code of a TestCase instance should be entirely self contained, such that it can be run either in isolation or in arbitrary combination with any number of other test cases.

### 组织测试
通过实现以下代码来处理test fixture。
```
setUp()

tearDown()
```

使用test suite与test runner来自定义测试过程
```
def suite():
    suite = unittest.TestSuite()
    suite.addTest(WidgetTestCase('test_default_widget_size'))
    suite.addTest(WidgetTestCase('test_widget_resize'))
    return suite

if __name__ == '__main__':
    runner = unittest.TextTestRunner()
    runner.run(suite())
```

### 重复利用旧的测试代码

因为只有test case才能收集到test suite中去，所谓重复利用旧代码就是用`FunctionTestCase`将原来的测试函数包装成一个Test Case。

```
# old test code
def testSomething():
    something = makeSomething()
    assert something.name is not None

# wrap with a FunctionTestCase
testcase = unittest.FunctionTestCase(testSomething,
                                     setUp=makeSomethingDB,
                                     tearDown=deleteSomethingDB)

```

### Skipping tests and expected failures

既然有with 这种写法了，为什么还要expected failures?
```
import unittest

class TestStringMethods(unittest.TestCase):
    def test_split(self):
        s = 'hello world'
        self.assertEqual(s.split(), ['hello', 'world'])
        # check that s.split fails when the separator is not a string
        with self.assertRaises(TypeError):
            s.split(2)

if __name__ == '__main__':
    unittest.main()
```

### 使用subtests

当很多测试用例仅存在参数上的微小差别的时候，可以将它们写在一个测试方法中，然后再用subtests区分它们。

### 深度定义testrunner


## 测试替身(test doubles)
关于测试替身的意义可以参考[wiki][0]。替身有多种，之间的区别可参考[xunit][1]。

mock是替身的一种，python3中unittest自带了mock模块。最近仍然活跃更新的第三方mock工具可以参考[python-doublex][2]和[aspectlib][3]。

这部分可以参考文档，文档以及非常通俗详尽了：[新手文档][4]，[API文档][5] 。


## 通过python自带的test学习测试的写法
在python的安装目录下，比如我的`D:\Applications\python3.7.3\Lib\test`，包含有系统类库的所有的测试。

运行所有的测试`python autotest.py`。

可以通过学习这里测试的写法来学写测试。



[0]:https://en.wanweibaike.com/wiki-Test%20double
[1]:http://xunitpatterns.com/Mocks,%20Fakes,%20Stubs%20and%20Dummies.html
[2]:https://bitbucket.org/DavidVilla/python-doublex/src/master/
[3]:https://python-aspectlib.readthedocs.io/en/latest/testing.html#spy-mock-toolkit-record-mock-decorators
[4]:https://docs.python.org/3/library/unittest.mock-examples.html
[5]:https://docs.python.org/3/library/unittest.mock.html

