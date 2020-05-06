---
layout: post
title: java collections framework 之 Map
description: ""
category: java
tags: [java]
---
{% include JB/setup %}

* toc
{:toc}

</hr>
本文依据的JDK版本为12.
http://hg.openjdk.java.net/貌似挂掉了。

## java.util.Map


## AbstractMap

### 几个方法

* get
<pre class="brush:java;">
    public V get(Object key) {
        Iterator<Entry<K,V>> i = entrySet().iterator();
        if (key==null) {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (e.getKey()==null)
                    return e.getValue();
            }
        } else {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (key.equals(e.getKey()))
                    return e.getValue();
            }
        }
        return null;
    }
</pre>

* containsKey
<pre class="brush:java;">
	    public boolean containsKey(Object key) {
        Iterator<Map.Entry<K,V>> i = entrySet().iterator();
        if (key==null) {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (e.getKey()==null)
                    return true;
            }
        } else {
            while (i.hasNext()) {
                Entry<K,V> e = i.next();
                if (key.equals(e.getKey()))
                    return true;
            }
        }
        return false;
    }
</pre>

可以看到默认的get()、containsKey()方法就是一个遍历，效率是比较低的。AbstractMap虽然虽然目的是为了代码重用，但是大部分要求效率的场合可能不合适。


### key不存在与key为null
从get()方法中可以看出，在AbstractMap中，null是一个合法的key。
若想表示key不存在，当如何?

### 值不存在与值为null
从上面containsKey()的逻辑还可以看出，在AbstractMap中，null是一个合法值。
若想表示值不存在，当如如？

### 以上两种策略没什么问题吗？


### putIfAbsent系列

## HashMap

### load_factor

### rehash

### treeifyBin

### splitor?