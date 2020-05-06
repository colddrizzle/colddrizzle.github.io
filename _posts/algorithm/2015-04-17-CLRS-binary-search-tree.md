---
layout: post
title: CLRS C.12--binary search tree
description: ""
category: 算法导论
tags: [算法导论, 二叉树, 数据结构, 算法, 基础知识]
---
{% include JB/setup %}

* toc
{:toc}
<hr />

## definition
A binary search tree is a binary tree with property as follows:

	Let x be a node in a binary search tree. If y is a node in the left subtree of x, then y:key ≤ x:key. If y is a node in the right subtree of x, then y:key ≥ x:key.

A binary search tree can not contain two same key.

### data structure

A node is a dict instance which has four parts:
<pre class="brush:python;">

node = {"p":None, "left":None, "right":None,"key":None}

</pre>

root is an reference of node.

Tree T is an reference of root node.

An empty tree is a tree who's root is None.

## tree walk

According to when to prints root node while prints a binary tree，there are three
tree walk strategy:

* inorder tree walk: visit left subtree -> visit root node -> visit right subtree
* preorder tree walk: visit root node -> visit left subtree -> visit right subtree
* postorder tree walk: visit left subtree -> visit right subtree -> visit root node

## operations

### maximum and minimum
<pre class="brush:python;">
def maximum(T):
	assert T != None
	r = T
	while r.right != None:
		r = r.right
	return r

def minimum(T):
	assert T != None
	r = T
	while r.left != None:
		r = r.left
	return r

</pre>

* the maximum node has no right subtree. If a node has no right child and is not null it must be a maximum node of a tree.

* the minimum node has no left subtree. If a node has no left child and is not null, it must be a minimum node of a tree.

### predecessor and successor

<pre class = "brush:python;">
def predecessor(x):
	assert x != None
	if x.left != None:
		return maximum(x.left)

	y = x.p
	while y != None and x == y.left
		x = y
		y = y.p

	return y

def successor(x):
	assert x != None
	if x.right != None:
		return minimum(x.right)

	y = x.p
	while y != None and x == y.right:
		x = y
		y = y.p

	return y

</pre>

![img](/assets/resources/clrs-bst-ps.png){:width="100%"}

For predecessor, if x has a left subtree, it's easy, otherwise x must be the minimum node of some subtree. Find the biggest subtree y which minimum node is x. Then y's root must be a right child or the root of whole tree. If y's root is the left child of node z, then subtree z's minimum node is x and subtree z is larger than y. If the biggest subtree y's root is a right child, then y.p is x's predecessor. If y's root is the root of whole tree, the x has no predecessor which means x is the minimum node of whole tree.

For successor, if x has a right subtree, it's easy, otherwise x must be the maximum node of some subtree. Find the biggest subtree y which maximum node is x. Then y's root must be a left child or the root of whole tree. If y's root is the left child of node z, then subtree z's maximum node is x and subtree z is larger than y. If the biggest subtree y's root is a left child, then y.p is x's successor. If y's root is the root of whole tree, the x has no successor which means x is the maximum node of whole tree.

### search

#### recursion
The argument of search is a key, not a node. For clearity, we use kx instead of x.
<pre class="brush:python;">
def search(T, kx):
	if T == None:
		return None

	if kx < T.key
		search(T.left)
	elif kx > T.key
		search(T.right)
	else:
		return T.root
</pre>

#### loop
<pre class="brush:python;">
def search(T, kx):
	r = T
	while r != None:
		if kx < r.key:
			r = r.left
		elif kx > r.key:
			r = r.right
		else:
			return r
	return None
</pre>
### insert
<pre class = "brush:python;">
def insert(T, x):
	if T == None:
		T = x
		return

	r = T
	while r != None:
		p = r
		if x.key < r.key:
			r = r.left
		elif x.key > r.key:
			r = r.rith
		else:
			raise Exception("same key")
	if p.key > x.key:
		p.left = x
	else:
		p.right = x

</pre>

First we find the position of x as child of p, then we compare x and p to determine which child x should be.

#### build binary search tree in a stream way

With insert operation, we can build a tree in a way that whenever a new key comes, we insert it in the tree.

If we build binary search tree in such a stream way, then there are properties as follows:
* the first come key becomes the root of whole tree.
* a new key always becomes a leave node, not a inner node.

### delete

We discuss deletion in three basic cases, let's assume we're going to delete z:
* if z has no child, then we just replace z's position with NULL in z.p.
* if z has one child, we replace z's position with this child in z.p.
* if z has two children, the basic strategy is to replace z with its successor--just like deletion in a liner table, and finding successor of z
become find minimum node of z's right subtree. But if successor has children, then where to put them will be a question. Remember that a successor always has no left child, so deleting successor falls in case 2 or we can use transplant process to replace successor with its right child.


If we examine the three basic cases, we'll find an operation always keep, that is replating a subtree with another one, we can name it transplant
figuratively.
So we first extract this operation as follows:

<pre class="brush:python;">
def transplant(T, u, v):
	if u.p == None:
		T.root = v
	elif u == u.p.left:
		u.p.left = v
	else:
		u.p.right = v

	if v != None:
		v.p = u.p
</pre>

There are two restrictions of u and v. Firstly, **The transplant() prodecure assumes v is not part of T. We must cut v from T ahead by ourselves.** Links in binary tree are bidirectional, transplant() only sets v.p and doesn't set field pointing to v in v.p. In fact, if u only one child v, there 
is no need to cut v from T, because transplant() does this automaticly.

Secondly, **u is not part of v**. Allowing this will form loops.


 
Then deletion process as follows(the argument is a node, not a key):
<pre class = "brush:python;">
def delete(T, x):
	r = None
	if x.left == None and x.right == None:
		pass
	elif x.left == None:
		r = x.right # x.right is successor and is cutted automaticly
	elif x.right == None:
		r = x.left # x.left is predecessor and is cutted automaticly
	else:
		r = minimum(x.right)
		delete(T, r, r.right)
		r.left = x.left
		r.right = x.right
	transplant(T, x, r)
</pre>

Unlike the book version, there is no need to distinguish whether r is x's right child. When r is x's right child,  the process is demenstrated below.
![img](/assets/resources/clrs-bst-delete.png){:width="100%"}

The book version delete process is not easy to understand, but let's try to figure it out.
<pre class="brush:python;">
def delete(T, x):
	if x.left == None:
		transplant(T, x, x.right)
	elif x.right ==  None:
		transplant(T, x, x.left)
	else:
		y = minimum(x.right)
		if y.p != x:
			transplant(T, y, y.right) 
			y.right = x.right # add y = y.right before this line
			y.right.p = y
		transplant(T, x, y)
		y.left = x.left
		y.left.p = y

</pre>

There is a problem in above code. After transplant(T, y, y.right) in line 9, which node does y reference?

According the transplant(T, y, y.right) subroutine, the reference of y in p is replaced by y.right. So y is 
freed, assignment to y.right in line 10 makes no sence. The right way to deal with this is adding `y = y.right` between
line 9 and line 10.

There are more than one delete strategy, but the basic idea is to replace target with its predecessor or successor, depends on which is convenient.

## random built binary search tree

to be continue

## exercise

### 12.1

### 12.2

### 12.3

