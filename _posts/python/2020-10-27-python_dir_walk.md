---
layout: post
title: python中目录处理
description: ""
category: python
tags: [python, listdir]
---
{% include JB/setup %}

* toc
{:toc}

<hr />

一般而言，python有关目录处理的api有：

* glob
* os.listdir
* os.walk
* os.path.walk

`glob`在“python标准库之glob”篇有过介绍，不再赘述。

另外三个简而言之，`os.listdir`与`os.walk`都是列出某个目录下的所有文件与目录，区别在于前者不会列出子目录下的东西，而后者会包含子目录。
`os.path.walk`是介于二者之间的方法，允许传入回调函数自定义遍历过程，该方法在python3中被移除(实际上我们仍然能用listdir模拟它)，因此我们不再管它。

下面我们用一个例子来看下，假设我们有如下目录：

```
#目录结构

dir0
	data00
	data01
	dir1
		data10
		data11
	dir2
		data20
		data21

path_process.py # 我们的脚本

```

脚本内容：

```brush:python
import os

print(os.listdir("dir0"))

print(list(os.walk("dir0", True)))

```

输出如下：

```
['data00', 'data01', 'dir1', 'dir2']
[('dir0', ['dir1', 'dir2'], ['data00', 'data01']), ('dir0\\dir1', [], ['data10', 'data11']), ('dir0\\dir2', [], ['data20', 'data21'])]

```

可见os.walk的语义更倾向于枚举出所有的目录，随带附上该目录下的子文件与子目录，因此每个目录输出一个三元组。枚举所有目录可以由浅而深也可以反过来。