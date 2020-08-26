---
layout: post
title: Linux终端概念

tagline: "Supporting tagline"
category : linux
tags : [linux, terminal, tty, ptmx, pts]

---
{% include JB/setup %}

* toc
{:toc}

<hr />

## 终端演变过程
每当谈起Linux终端相关，就会冒出一堆名词：终端、虚拟终端、虚拟控制台、伪终端、哑终端、shell、bash、tty、pty、pts
等，让人头大。很多名词其实只是习惯沿用，内涵与最初早就不一致了，为了清楚，有简单必要追溯下linux历史。

我们知道linux是Linus于1991年开发的第一个版本，当时unix是主流操作系统，所以linux模仿了unix（真实情况要比这复杂，我们简单带过），而unix最初是
Ken Thompson和Dennis Ritchie于20世纪70年代为DEC PDP-7--一种小型机上开发的。在大型机、小型机时代，计算机是非常庞大且昂贵的设备，Ken Thompson与Dennis Ritchie将Unix开发成多用户操作系统，使得计算机可以共享。

既然是多用户操作，每个用户都需要配一套输入输出设备，这种设备就是终端，可见，最初终端是一种物理设备。终端基本上可以分为两类：一类是与计算机本身自带的终端，称之为控制台（console）,另一类是通过线缆远距离连接到计算机的终端，这种终端又可以分为两类：电传打字机(teletype)与视频终端(video terminal)。在unix系统中，一切都是文件，这两类终端就分别被抽象成`/dev/console`与`/dev/tty`文件。

小型机时代，即便是终端也是昂贵的设备，电传打字机因为便宜，被Unix发明者接到unix系统上，使其成为计算机的终端设备，电传打字机([teletype wiki][0])在纸片上打印字符来输出，这类终端又被称为哑终端，因为其内部没有CPU、内存、硬盘，不能运行任何程序。

视频终端的代表是[DEC VT100][1]，视频终端拥有简单的转义字符处理、屏幕光标、复制粘贴、历史命令等简单的处理功能，但本质上还是一个单纯的终端，不能运行通用程序，计算工作仍要交给其所连接的大型机、小型机来完成。

随着个人计算机以及图形化界面的发展，每台计算机都配备了一套输入输出设备，并且也不再使用字符界面。但是原来的很多程序都是跟字符终端绑定的，这些程序会默认打开stdin、stdout、stderr这三个文件流来进行工作，为了使这些程序能够正常运行，需要模拟一个终端，这个终端就叫伪终端(pseudo terminal)。另外当通过远程ssh连接到linux的字符界面的时候，实际上是连接到了linux服务器上的ssh server上，ssh server负责与系统内的程序进行交互，此时也需要给这些程序提供一个伪终端。所以伪终端就是给程序提供stdin、stdout、stderr的一个东西。实现伪终端的技术
就涉及到ptmx与pts文件，下小节再讲。

图像界面下，操作系统提供了终端模拟器(Terminal Emulator)来实现伪终端。注意终端模拟器不是指shell程序（bash是shell的一种，指的是Bourne-Again SHell），shell程序一个依赖于字符终端的普通程序而已。终端模拟器在图形界面中提供一个字符界面，并从图形人机接口（GUI）中接受键盘输入，利用伪终端技术
传递给依赖字符终端的程序，然后将这些程序的输出展现在字符界面中。sshd与之类似，下节将ptmx再讲。

通常终端模拟器会模拟某一个型号的终端（是的，在历史中曾经有各种型号的物理终端），模拟的这个终端就被称为虚拟终端。可以通过`toe -a`查看可以模拟的终端型号，通过`echo $TERM`查看当前虚拟终端型号。

注意伪终端的概念不等同虚拟终端，伪终端是相对于古老程序来说的，并且是一个与终端或者虚拟终端相对应的概念。图像界面下，终端模拟器虚拟终端再加上伪终端技术实现我们通常意义上图像界面中的那个终端窗口。虚拟终端依赖伪终端技术来实现，伪终端技术不止可以实现虚拟终端。

不论是物理终端还是虚拟终端，甚至是伪终端，都可以用`tty`命令查看当前终端在系统中映射成的文件。

## ptmx与伪终端
上一节讲到，有些时候需要给依赖字符终端的程序提供一个假的终端，ptmx就是这样一个神奇的机制。参考[man ptmx][2]:

	When a process opens /dev/ptmx, it gets a file descriptor for a pseudoterminal master (PTM), and a pseudoterminal slave (PTS) device is created in the /dev/pts directory. Each file descriptor obtained by opening /dev/ptmx is an independent PTM with its own associated PTS, whose path can be found by passing the descriptor to ptsname(3).
	...
	In practice, pseudoterminals are used for implementing terminal emulators such as xterm(1), in which data read from the pseudoterminal master is interpreted by the application in the same way a real terminal would interpret the data, and for implementing remote-login programs such as sshd(8), in which data read from the pseudoterminal master is sent across the network to a client program that is connected to a terminal or terminal emulator.

上面的文档内容讲到，当进程打开`/dev/ptmx`文件的时候，将获得一个文件描述符用来实现PTM的文件描述符与一个PTS设备。进程可以对PTM进行读写，对应的PTS就可以执行相反的操作，就像一个能双向通信的管道。实践中，伪终端技术通常用来实现终端模拟器或者远程登录。

`lsof`命令能显示打开某文件的所有进程或者进程打开的所有文件，让我们利用`lsof`命令来验证下。

首先，在图形界面中打开一个终端，查看其关联的设备文件。
```
$ tty
$ /dev/pts/0
```

查看，当前bash进程ID：
```
$ echo $$
$ 4340
```

当前bash进程理应是由终端模拟器创建的，因此查看bash进程的父进程信息。
```
$ ps axj|grep 4340

 4334  4340  4340  4340 pts/0    28580 Ss    1000   0:00 bash
 4340 28580 28580  4340 pts/0    28580 R+    1000   0:00 ps axj
 4340 28581 28580  4340 pts/0    28580 S+    1000   0:00 grep --color=auto 4340
```
父进程为4334，看下4334是什么进程：

```
$ ps axj|grep 4334

  978  4334  4334  4334 ?           -1 Ssl   1000   0:22 /usr/lib/gnome-terminal/gnome-terminal-server
 4334  4340  4340  4340 pts/0    28582 Ss    1000   0:00 bash
 4334  4415  4415  4415 pts/1     4415 Ss+   1000   0:00 bash
 4340 28583 28582  4340 pts/0    28582 S+    1000   0:00 grep --color=auto 4334
```
可以看到4334是gnome-terminal-server进程，也就是终端模拟器进程，这验证了我们的说法。

查看下终端模拟器模拟的终端型号：

```
$ echo $TERM
xterm-256color
```

查看gnome-terminal-server打开的文件：
```
$ lsof -p 4334

...
gnome-ter 4334  zxj   13u      CHR                5,2      0t0      86 /dev/ptmx
gnome-ter 4334  zxj   14u      CHR                5,2      0t0      86 /dev/ptmx
...
```
可看到其打开了两次`/dev/ptmx`，那是因为我的机器上还有另一个终端窗口。

查看bash进程打开的文件：
```
$ lsof -p 4340
...
bash    4340  zxj    0u   CHR  136,0      0t0      3 /dev/pts/0
bash    4340  zxj    1u   CHR  136,0      0t0      3 /dev/pts/0
bash    4340  zxj    2u   CHR  136,0      0t0      3 /dev/pts/0
...
```
可以看到bash进程（一个依赖字符终端的进程）打开的stdin、stdout、stderr都是`/dev/pts/0`文件。这验证了ptmx文档中的说法。

<hr />
同样的方法可以验证ssh远程登录时候sshd与ptmx直接的情况，不再赘述。

## ttyN是虚拟终端吗
linux下可以通过ctrl+alt+FN来切换图像界面与字符终端界面，很多说法说这些字符界面是虚拟终端，但我们认为这种说法并不恰当，显然这个虚拟终端与
图像界面下终端模拟器模拟出来的终端并非一回事，实际上我们认为这些字符终端就是物理终端。

所谓物理终端，就是物理设备加硬件驱动。

显卡与显示器之间是有最小标准之类的协议的，使得显卡与显示器可以在不使用最适配驱动的情况也能工作。linux应该是使用这类最小标准协议来抽象了一套硬件驱动，驱动所实现的终端标准在ubuntu其TERM=linux，驱动的物理设备就是我们的显示器，从这个概念上讲，ttyN字符终端是物理终端而非虚拟终端。

以上可以仿造上一小节的方法进行验证。

## 参考

[资料1][3]

[资料2][4]

[资料3][5]

[资料4][6]

[资料5][7]

关于ptmx/pts原理：

[资料6][8]

[0]:https://en.wanweibaike.com/wiki-TeleType
[1]:https://en.wanweibaike.com/wiki-DEC%20VT100
[2]:https://linux.die.net/man/4/ptmx
[3]:https://www.cnblogs.com/sddai/p/9769086.html
[4]:https://segmentfault.com/a/1190000009082089
[5]:https://cloud.tencent.com/developer/news/304629
[6]:http://www.wowotech.net/tty_framework/tty_concept.html
[7]:http://www.360doc.com/content/14/0818/16/426085_402858968.shtml
[8]:https://blog.csdn.net/luckywang1103/article/details/71191821

