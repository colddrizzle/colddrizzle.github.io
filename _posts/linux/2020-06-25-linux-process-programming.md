---
layout: post
title: Linux进程编程相关

tagline: "Supporting tagline"
category : linux
tags : [linux, process]

---
{% include JB/setup %}

* toc
{:toc}

<hr/>

## fork

子进程继承父进程的进程组、session、打开的文件、工作目录。
父进程的文件锁定与未决信号不由子进程继承。

从fork()那一行开始，后面的代码将在父子进程里都生效，除非通过fork()的返回值来区分它们。

一个简单的例子：

```brush:c

#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>

#define __NR_gettid 186
#define gettid() syscall(__NR_gettid)

int main(void){
    pid_t ret;
    ret = fork();

    if( ret > 0){
        pid_t c = getpid();
        printf("parent: %d %d %d %d %ld\n", getppid(), c, getpgid(c), getsid(c), gettid());
        //to ensure parent exits after child
        //so child gets the correct ppid, not 1
        sleep(1); 
    } else if( ret ==0 ){
        pid_t c = getpid();
        printf("child: %d %d %d %d %ld\n", getppid(), c, getpgid(c), getsid(c), gettid());
    } else{
        printf("error %d\n", errno);
    }
}

```

linux中进程在内核中其实对应只包含一个线程的线程组，进程、线程关系篇有讲。

## wait&waitpid

### 为什么需要等待
wait、waitpid是父进程用来等待子进程退出状态的方法，并且如果父进程不调用wait来获取子进程退出状态的话，那么在父进程
存活期间，已经退出的子进程就成为僵尸进程。这似乎给我们一种错觉就是父进程有义务等待子进程退出。但这实际上只是linux进程模型设计上
给我们的一个错觉。

我们来思考下为什么会有这样一个错觉。首先我们必须承认，大多数情况下，父进程是关心子进程的退出状态的。所以当子进程退出的时候，必须把自己的退出
状态存放在某个地方。系统设计者当然并不知道实际使用的时候父进程是否关心子进程退出状态，于是就可能有两种设计：
1. 父进程创建子进程的时候告知子进程自己是否关心其退出状态。如果不关心，子进程退出状态丢掉就好了，如果关心则随便告诉子进程一个地址，让子进程将自己的存储状态存放在这个地址处。
2. 父进程不必告知子进程自己是否关心。子进程退出后一律保存自己的退出状态，直到父进程来访问后再释放。子进程退出状态保存在自己的PCB中，如果不访问，则一直保留。如果父进程直到退出都未访问，则这些PCB被init(或systemd或upstart，取决于系统所用的初始化系统)进程收养并释放。

显然，unix、linux选择的是第二种设计。实际上，所谓“僵尸进场”除了在父进程存活期间占用点内存之外并无坏处，也因此子进程退出时发送的SIGCHLD信号默认是被父进程忽略的，所以通常来说，是否调用wait、waitpid并不重要。但是，某些服务器进程需要一直运行，且会不断的创建子进程，这时候就会产生大量的僵尸进程，就会成为问题了。

通常有[3种方法][0]来处理这种情况：
1. 专用线程处理子进程退出。该线程一直循环调用wait阻塞处理任何子进程退出。
2. 两次fork。两次fork利用了一个特性：如果父进程退出子进程会被init进程收养。那么创建子进程后，子进程再创建“孙进程”，创建后子进程立马退出。那么“孙进程”将被init接管。从而保证了“孙进程”永远不会成为僵尸进程。
3. 内核2.6之后，显式忽略SIGCHLD信号`signal(SIGCHLD, SIG_IGN)`。显式忽略会同时设置信号的SA_NOCLDWAIT。参考[这里][1]。
4. 内核2.6之前，显式、隐式忽略信号都不能阻止僵尸进程产生。

注意，SIGCHLD信号在内核中的默认动作是忽略，这称为隐式忽略。它与显式忽略是不同的，显式忽略有posix规定的glibc自己附加的内容就是添加
`SA_NOCLDWAIT`标志。


在linux进程模型中，子进程在退出的时候会像父进程发送SIGCHLD信号，该信号的处理如下：
* 父进程隐式忽略该信号。父进程存活期间，子进程成为僵尸进程。
* 父进程显式忽略该信号。相当于告诉子进程我不关心你的结果。子进程退出时不会变成僵尸进程。
* 父进程捕捉该信号但是不调用wait，则子进程处于僵尸状态。
* 父进程退出并且一直没有调用wait，则僵尸进程被init收割。

下面我们来用跟一个简单的例子观察下这个过程：

```brush:c
#include <stdio.h>
#include <string.h>
#include <errno.h>

#include <sys/types.h>
#include <unistd.h>
#include <signal.h>


void sigchld_handler(int signum){
    printf("%d got SIGCHLD\n", getpid());
}

int main(void){
    char buf[1024];
    setvbuf(stdout, buf, _IOLBF, 1024);
    pid_t ret;
    pid_t c = getpid();

    //为了方便观察我们把父子进程放到一个新的进程组内。
    if(setpgid(c, c)){
        printf("%d setpgid failed: %s\n", c, strerror(errno));
    }else{
        printf("%d setpgid success\n", c);
    }

    ret = fork();
    if( ret > 0){
        pid_t c = getpid();
        signal(SIGCHLD, sigchld_handler);
        printf("parent: %d %d %d %d\n", getppid(), c, getpgid(c), getsid(c));
        pause();//任意信号都会中断pause，为了不让父进程收到SIGCHLD后立马退出，我们调用两次pause
        pause();
        printf("parent exit\n");
    } else if( ret ==0 ){
        pid_t c = getpid();
        printf("child: %d %d %d %d\n", getppid(), c, getpgid(c), getsid(c));
        pause();
    } else{
        printf("error %s\n", strerror(errno));
    }
}
```

首先，隐式忽略的情况。注释掉上面的设置signal handler的行来实验。
```brush:bash
$ ./_test.c
26522 setpgid success
parent: 26516 26522 26522 1775
child: 26522 26523 26522 1775

$ kill 26523
$ ps -A -o pid,stat|grep 26523
26523 Z

$ kill 26522
$ ps -A -o pid,stat|grep 26522
# nothing output
```
可以看到子进程成为僵尸进程，杀掉父进程后，僵尸进程消失。

然后我们设置signal handler重新执行实验。
```brush:bash
$ ./_test.c
26670 setpgid success
parent: 26664 26670 26670 1775
child: 26670 26671 26670 1775

$ kill 26671
26670 got SIGCHLD

$ ps -A -o pid,stat|grep 26671
$ 26671 Z

$ kill 26670
$ ps -A -o pid,stat|grep 26570
# nothing output
```
可以看到只捕捉信号无法避免僵尸进程。

还有两种情况，显式忽略以及调用wait收割，此处略去。

### wait&waitpid
两个函数都会将进程状态保存到一个int型参数status中。有一些宏用来协助处理status，参考man就可以了。
[这里][2]有一些关于status初始化的讨论。

### 非阻塞等待
调用wait或者waitpid有可能会导致阻塞。waitpid提供了非阻塞等待的方法，其方法签名
```brush:c
pid_t waitpid( pid_t pid, int * status, int options)
```
options选项可取WNOHANG与WUNTRACED。WNOHANG选项不论子进程是否退出都立刻返回，但是返回的值不同，就好像测试了一下进程是否结束。而WUNTRACED选项
可以返回已经停止而且自停止后还未报告状态的子进程。

### system()与忽略SIGCHLD


由于system函数的实现基本原理是使用fork函数创建一个子进程，用子进程调用exec函数，之后将子进程运行的内容替换成了目标程序。如果不阻塞SIGCHLD信号，那么如果在调用system函数之前还创建了一个其它的子进程，那么当system函数中fork创建的子进程结束后会给父进程发送SIGCHLD信号，如果此时父进程设置的信号处理方式是捕捉而且在信号处理函数中调用了wait函数，那么system函数就无法根据其函数中创建的子进程返回状态获取相应的返回值。记得有这样的规定，
system函数的返回应该是函数中创建子进程的返回状态。所以为了能保证system能够正确获取system函数中创建的子进程返回状态，SIGCHLD信号必须被阻塞。
同样，为了保证system函数不出现其它的一些问题，要求system函数要忽略SIGINT和SIGQUIT信号，如果system函数调用的程序是交互式的，如“ed”，就可能出现一些小问题。

也因为system需要阻塞并确保最后由自己处理子进程退出状态，如果忽略了sigchld，再调用诸如system函数，也会出现问题。

还可以参考Stackoverflow上的一条[问题讨论][3]。

### 更多关于僵尸进程、孤儿进程的资料
[两次fork][4]。

[孤儿进程僵尸进程][5]。

## 设置进程组setpgid	

setpgid并不像它的名字看起来的那样简单明了，有很多规则：

1. setpgid的的语义包括设置与创建进程组两部分。因此进程组id要么是另一个已经存在的组ID，那么是自身进程ID。
	* 另一个已经存在的组ID：必须是同session内的组。此时相当于移动进程的另一个组。
	* 自身进程ID。此时相当于创建进程组。

2. setpgid只能设置自己进程或者自己的子进程的组ID。

3. 设置子进程组ID之前子进程不能执行execve操作。(Why?)

4. 如果子进程是一个session leader，则setpgid不能更改其组ID。这是因为session leader必须是组长进程，[参见这里][10]。

以上内容来自man setpgid的error部分。

另外第4条提到不能更改session leader的group id，但是setpgid可以将一个group leader进程移动到另一个group里面（参考[这里][11]），原来的group就没有leader了。
这并不奇怪，session与group都可以没有leader而存在。毕竟session leader只是用来关联控制终端的，而group leader貌似没什么用，仅仅是标识该group的
创建者（group leader有什么用没找到资料...）。


## 设置会话 setsid
根据man setsid:
	 setsid()  creates  a new session if the calling process is not a process group leader.  The calling process is the leader of the new session (i.e.,
	 its session ID is made the same as its process ID).  The calling process also becomes the process group leader of a new process group in  the  ses‐
	 sion (i.e., its process group ID is made the same as its process ID).

与其称其为设置会话，不如称之为创建新会话。 调用setsid的进程本身不能是一个组长进程。调用后该进程称为新的session leader与group leader。

## pause与sleep
pause与sleep都将使调用进程挂起，直到未被忽略的任何信号到来或者sleep超时。

## signal
signal既可以用来注册信号处理函数，也可以用来忽略信号，比如：
```brush:c
signal(SIGCHLD, SIG_IGN);
```

## exec变体
从命名上看，6个变体分别是加上了`l v p`的后缀组合，那么他们是什么意思呢？

l与v表示以何种方式传参数，列举方式或者argv数组。
p表示从某些特定路径下搜索程序名。关于这部分最好的解释是man文档：

	The  execlp(),  execvp(),  and execvpe() functions duplicate the actions of the shell in searching for an executable file if the specified filename does not contain a slash (/) character.  The file is sought in the colon-separated list of directory pathnames specified in  the  PATH  environment variable.  If this variable isn't defined, the path list defaults to a list that includes the directories returned by confstr(_CS_PATH) (which typically returns the value "/bin:/usr/bin") and possibly also the current working directory; see NOTES for further details.

而e表示环境变量，以一个NULL结尾的字符串数组的方式来传递，比如：
```brush:c
char * envp[] = {"PATH=/bin", "FOO=99", NULL};
```

## kill、raise、alarm
kill向指定进程发送信号。
raise向当前进程发送信号，相当于kill的限制版本。
alarm向当前进程发送一个SIGALRM信号。

我们看一个alarm函数的例子：
```brush:c
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>

void wakeup(int sig_num){
    raise(SIGKILL);
}

#define MAX_BUFFER 80

int main(){
    char buffer[MAX_BUFFER + 1];
    int ret;

    signal(SIGALRM, wakeup);

    printf("you have 3 seconds to enter the password\n");
    fflush(stdout);

    alarm(3);

    ret = read(0, buffer, MAX_BUFFER);

    alarm(0);

    if(ret == -1){

    }else{
        buffer[strlen(buffer)-1] = 0;
        printf("User entered %s\n", buffer);
    }

}
```
程序在read之前设置一个3秒到时的alarm，3秒后发送SIGKILL杀死进程。
如果3秒内read返回（输入了密码），就会用`alarm(0)`取消alarm定时信号。

## 守护进程


[0]:https://stackoverflow.com/questions/16078985/why-zombie-processes-exist/16167157#16167157
[1]:https://stackoverflow.com/questions/40601337/what-is-the-use-of-ignoring-sigchld-signal-with-sigaction2/40601403#40601403
[2]:https://www.cnblogs.com/Harley-Quinn/p/7157579.html
[3]:https://stackoverflow.com/questions/17532632/linux-system-after-setting-sa-nocldwait-to-sigchld
[4]:https://www.cnblogs.com/tianlangshu/p/5200049.html
[5]:https://www.cnblogs.com/Anker/p/3271773.html

[10]:https://stackoverflow.com/questions/50591754/can-the-first-argument-to-setpgid-be-a-session-leader-or-a-group-leader?r=SearchResults
[11]:https://stackoverflow.com/questions/50591754/can-the-first-argument-to-setpgid-be-a-session-leader-or-a-group-leader