---
layout: post
title: 使用setjmp实现分时调度的用户级多线程

tagline: "Supporting tagline"
category : c&cpp
tags : [linux, setjmp, 用户级线程]

---
{% include JB/setup %}

* toc
{:toc}

<hr/>

使用setjmp来实现用户级多线程，分时调度。核心点如下：

* 使用信号来打断线程的执行 
* 使用setjmp来实现线程间跳转
* 通过将每个线程RBP至RSP之间的内容保存下来来模拟每个线程栈

注意，因为第三点的存在，使得这个实现是一个“不怎么漂亮”的实现，因为
线程切换要来回拷贝栈内容，线程函数调用过深时线程切换代价很大。不过无妨，
本实现还是有助于理解setjmp、c函数调用栈、用户级多线程等概念。

[这里《Linux C实现纯用户态抢占式多线程》](https://blog.csdn.net/dog250/article/details/89642905)有人利用sigaction可以指定栈的方法实现了用户级多线程，要漂亮的多，可以参考。

平台：ubuntu 18.04 x86-64 一个简单实现，不可移植

实现的线程库如下的API
```
thread_create();
thread_sleep();
thread_join_all();
```
使用前要在main函数第一行调用`thread_lib_init`初始化线程库（注意必须在main函数第一行调用，这与我们保存主线程RBP的方式有关）。

因为是个原理验证性的实现，我们使用了一个滑稽的抛硬币调度算法：对于一个runnable状态的线程，通过抛硬币
决定是否让其获得CPU。因此，如果某个线程调用了阻塞IO函数，其他线程也未必会获得CPU。实际上我们的调度算法也根本无从得知
该线程是否阻塞在IO上。

完整代码：

```brush:c
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <setjmp.h>

#include <signal.h>
#include <sys/time.h>
#include <unistd.h>
#include <execinfo.h>

#define MAX_THREAD 10
typedef struct __THREAD{
    int tid;
    int status; //0:init 1:runnable 2:suspend
    jmp_buf context;
    long int * stack_copy;
    long int *rbp;
    long int *rsp;
    void (*func)(); //func=NULL则是主线程
    int sleep;
    int jmp_flag;   // if thread.status = 1 and jmp_flag = 0,
                    //then it begin to run for the first time
    int lock_jmp_buf; // no shchedule nest
}__THREAD;

#define SCHED_TICK 2000

__THREAD * __THREAD_LIST[MAX_THREAD];

__THREAD * main_thread;
__THREAD * current;

//#define VERBOSE
#ifdef VERBOSE
#define v(...) fprintf(stderr, __VA_ARGS__)
#else
#define v(...)
#endif

#define SAVE_RSP(_rsp) asm volatile ( "movq %%rsp, %%rax;":"=a"(_rsp) )
#define SAVE_RBP(_rbp) asm volatile ( "movq %%rbp, %%rbx;":"=b"(_rbp) )

void pop_to_copy(__THREAD * t){
    size_t size = (t->rbp - t->rsp + 1)* sizeof(long int);
    t->stack_copy = (long int *)malloc(size);
    memcpy(t->stack_copy, t->rsp, size);
}
void pop_copy(__THREAD * t){
    size_t size = (t->rbp - t->rsp + 1)* sizeof(long int);
    memcpy(t->rsp, t->stack_copy, size);
    free(t->stack_copy);
    t->stack_copy = NULL;
}

int availabel_thread_id(){
    for(int i = 0; i < MAX_THREAD; i++){
        if(__THREAD_LIST[i] == NULL){
            return i;
        }
    }
    return -1;
}

void schedule();

void thread_destroy(__THREAD * t){
    if(t->stack_copy)
        free(t->stack_copy);
    __THREAD_LIST[t->tid] = NULL;
    free(t);
    
}
void thread_wrapper(__THREAD * t){
    t->func();
    thread_destroy(t);
    
    //since this thread finish
    //choose main thread to run
    current = main_thread;
    longjmp(main_thread->context, 1);
}

int thread_create(void (*func)()){
    if(func == NULL){
        fprintf(stderr, "need a function\n");
        return -1;
    }

    int tid = availabel_thread_id();
    if (tid < 0){
        fprintf(stderr, "thread quantity limit\n");
        return -1;
    }

    __THREAD * new = (__THREAD *)malloc(sizeof(__THREAD));
    new->func = func;
    new->status = 0;
    new->sleep = 0;
    new->jmp_flag = 0;
    new->lock_jmp_buf = 0;
    new->tid = tid;

    __THREAD_LIST[tid] = new;

    return tid;
}

//通过抛硬币的概率方式来决定一个线程是否获得CPU
int flip_a_coin(){
    long int ret = random();
    if(ret <= RAND_MAX/2){
        return 0;
    }
    return 1;
}


void schedule(){
    current->lock_jmp_buf = 1;
    v("tid %d enter sched\n", current->tid);
    SAVE_RSP(current->rsp);
    pop_to_copy(current);
    v("tid %d saved rsp:%p\n", current->tid, current->rsp);

    if( setjmp(current->context) == 0 ){
        //确保该分支中代码的所有出口都是longjmp
        current->jmp_flag = 1;
        for(int i = 0; i < MAX_THREAD; i++){
            __THREAD * t = __THREAD_LIST[i];
            if(t != NULL && t->status > 0){
                if(t->status == 1){
                    if(flip_a_coin()){
                        current = t;
                        if(t->jmp_flag){
                            v("tid %d got cpu\n", current->tid);
                            longjmp(t->context, 1);
                        }else{
                            v("tid %d begin run\n", current->tid);
                            SAVE_RBP(t->rbp);
                            thread_wrapper(t);
                        }
                    }
                }else if(t->status == 2){
                    t->sleep -= SCHED_TICK;
                    if(t->sleep <= 0){
                        t->sleep = 0;
                        t->status = 1;
                        if(t->jmp_flag != 1){
                            fprintf(stderr,"fatal no jum_buf\n");
                            exit(1);
                        }
                    }
                }
            }        
        }
        v("no thread selected\n");
        longjmp(current->context, 1);
    }else{
        pop_copy(current);
    }

    v("tid %d exit sched\n", current->tid);
    current->lock_jmp_buf = 0;

    long int *rsp;
    SAVE_RSP(rsp);
    v("setjmp %d saved rsp:%p\n", current->tid, rsp);
}

int thread_start(int tid){
    if(__THREAD_LIST[tid] == NULL){
        fprintf(stderr, "no such thread\n");
        return -2;
    }
    __THREAD_LIST[tid]->status = 1;
    schedule();
    return 0;
}

void sigvtalrm_handler(){
    v("tid %d got alrm\n", current->tid);
    if(current->lock_jmp_buf){
        return;
    }
    schedule();
}

void thread_lib_init(){
    //add main thread
    int tid = availabel_thread_id();
    __THREAD * new = (__THREAD *)malloc(sizeof(__THREAD));
    new->status = 1;
    new->sleep = 0;
    new->func = NULL;
    new->jmp_flag = 0;
    new->lock_jmp_buf = 0;
    new->tid = tid;

    SAVE_RBP(new->rbp);
    
    __THREAD_LIST[tid] = new;
    current = new;
    main_thread = new;

    struct sigaction action;
    memset(&action, 0, sizeof(action));  
    sigemptyset(&action.sa_mask); /* 将参数set信号集初始化并清空 */  
    action.sa_flags = SA_RESTART;
    action.sa_handler = sigvtalrm_handler;

    if(sigaction(SIGVTALRM, &action, NULL)){
        fprintf(stderr, "sigaction failed %s\n", strerror(errno));
        exit(1);
    }

    struct itimerval itv;
    itv.it_value.tv_sec = 0;
    itv.it_value.tv_usec = 1;
    itv.it_interval.tv_sec = 0;
    itv.it_interval.tv_usec = SCHED_TICK;
    setitimer(ITIMER_VIRTUAL, &itv, NULL);
}

void thread_sleep(int sec){
    v("begin sleep\n");
    current->sleep = sec*1000*1000;
    current->status = 2;
    schedule();
    v("exit sleep\n");
}
//exclude main thread
int has_thread_alive(){
    for(int i = 0; i < MAX_THREAD; i++){
        __THREAD * t = __THREAD_LIST[i];
        if(t != NULL && t->func != NULL ){
            return 1;
        }
    }
    return 0;
}

void thread_join_all(){
    while(has_thread_alive()){
    }
}

void func(){
    for(int i=0;i<10;i++){
        fprintf(stderr, "tid:%d i:%d\n", current->tid, i);
        thread_sleep(1);
    }
}

int main(void){
    thread_lib_init();
    int t1 = thread_create(func);
    thread_start(t1);

    int t2 = thread_create(func);
    thread_start(t2);

    thread_join_all();
    return 0;
}

```