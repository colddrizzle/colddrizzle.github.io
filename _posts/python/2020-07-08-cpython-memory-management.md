---
layout: post
title: cpython内存管理
description: ""
category: python
tags: [python, cpython, memory management]
---
{% include JB/setup %}

* toc
{:toc}

<br />

本文是[Memory management in Python][0]的要点笔记。该博客下其他python相关文章质量也很高，推荐关注。

Everything in Python is an object. Some objects can hold other objects, such as lists, tuples, dicts, classes, etc. Because of dynamic Python's nature, such an approach requires a lot of small memory allocations. To speed-up memory operations and reduce fragmentation Python uses a special manager on top of the general-purpose allocator, called PyMalloc.

To reduce overhead for small objects (less than 512 bytes) Python sub-allocates big blocks of memory. Larger objects are routed to standard C allocator. Small object allocator uses three levels of abstraction — arena, pool, and block.

Block is a chunk of memory of a certain size. 

Normally, the size of the pool is equal to the size of a memory page, i.e., 4Kb. Limiting pool to the fixed size of blocks helps with fragmentation. If an object gets destroyed, the memory manager can fill this space with a new object of the same size.

The arena is a chunk of 256kB memory allocated on the heap, which provides memory for 64 pools

[0]:https://rushter.com/blog/python-memory-managment/