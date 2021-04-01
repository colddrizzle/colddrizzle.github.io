---
layout: post
title: BAT速查样例
description: ""
category: 其他
tags: [bat]
---
{% include JB/setup %}

* toc
{:toc}

<hr />


# 输出

```brush:bash

echo "23d"
"234"

echo 123 345
123 345
```

# 关闭回显

```brush:bash

@echo off
echo hello

```


# 创建文件

```brush:bash

fsutil file create new {name} {size}

echo hello bat >> file.txt

```

# 写文件内容

```brush:bash

echo hello bat >> file.txt

```

# 创建文件夹

```brush:bash
md "E:\My documents\Newfolder1"

md dir1
```

# 删除

删除文件用`del`。删目录用`rmdir`或`rd`。

目录结构:

```
-dir1
--|data0.txt
--|data1.txt
--|dir2
----|data3.txt
----|data4.txt
```

```brush:bash

:: 删掉dir1下所有文件
del /q /f dir1

::删掉dir1以及dir1下的所有文件与目录
rmdir /q /s dir1

::删掉dir1下的所有文件，但保留目录结构

del /q /f /s dir1
```

# 注释
```brush:bash
:: 注释内容
rem 注释内容
```

# 变量

```brush:bash
::声明变量

set var=value

::引用变量

echo %var%

```

# 输入
```brush:bash

set /p var="提示信息"
```

# 命令行参数

%0是脚本本身的名字，参数从%1开始。

```brush:bash

echo %0 %1 %2
```

# 函数与调用


```brush:bash
:: 声明函数

: func_name
your_func_body
goto:eof


调用函数：
call:func_name

```

# 将命令行输出赋值给变量

Linux下使用反引号就可以了，windows下有点麻烦, 要用for变通:

```brush:bash
for /f %%r in ( 'your_command' ) do set your_var=%%r  
```

# for循环
```
在cmd窗口中：for %I in (command1) do command2 

在批处理文件中：for %%I in (command1) do command2
```

我们先来看一下for语句的基本要素都有些什么：

1. for、in和do是for语句的关键字，它们三个缺一不可；
2. %%I是for语句中对形式变量的引用，即使变量l在do后的语句中没有参与语句的执行，也是必须出现的；
3. in之后，do之前的括号不能省略；
4. command1表示字符串或变量，command2表示字符串、变量或命令语句；

```brush:bash
@echo off
for  %%I in (A,B,C) do echo %%I
pause

::输出
A
B
C
```

# 测试文件是否存在

```brush:bash
if  条件 ( //条件前后要留出空格

) else (

)

```

# 条件分支

```brush:bash


SET SourceFile=%cd%\updater.exe
 
if exist %SourceFile% ( 
) else (
    //你要做的事情
)

```