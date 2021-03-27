---
layout: post
title: python标准库之subprocess
description: ""
category: python
tags: [python lib, subprocess]
---
{% include JB/setup %}

* toc
{:toc}

[subprocess](https://docs.python.org/3/library/subprocess.html)

subprocess模块主要两个方法：subprocess.run与subprocess.Popen, 后者是前者的底层接口。

所谓subprocess就是子进程，当在python调用subprocess的上面两个方法之一时就会创建一个子进程，通常来讲，一个进程启动后其stdin、stdout、stderr指向键盘与终端等标准设备映射的文件。但是通过subprocess的启动的进程其默认没有关联标准输入输出设备。因此需要用参数指定，可以指定为任意文件，这就是subprocess.run中stdin、stdout、stderr的意义了。当然也可以用管道重定向到当前进程，这就是capture_output做的事情了。

subprocess.run()参数上面说明了几个，下面简要说明其他。

当check为True的时候，子进程的返回码（exit code）如果非0就抛出异常。参数check像是将subprocess的非0终结码关联到异常的一个遍历工具，当然没有提供这个功能，我们自己也能检查返回码并决定是否抛出异常。

If encoding or errors are specified, or text is true, file objects for stdin, stdout and stderr are opened in text mode using the specified encoding and errors or the io.TextIOWrapper default. The universal_newlines argument is equivalent to text and is provided for backwards compatibility. By default, file objects are opened in binary mode.

shell参数就是说命令是否通过shell执行。通常命令是另一个程序，可以通过也可以不通过shell执行。但是有些命令只能通过shell执行，这些就是shell的内建命令。
