---
layout: post
title: CLRS C.13--red black tree
description: ""
category: 算法
tags: [算法导论, 红黑树, 数据结构, 算法, 基础知识]
---
{% include JB/setup %}

* toc
{:toc}
<hr />

## balance of binary search tree
A random built binary search tree is not guaranteed to be balanced. While the operations cost depends on the tree height.
So a binary tree is more balanced, the performance is better.

## data structure
Unlike the represention of NULL node in Charpter 12. We use a sentinel node which key is arbitarry but not in the normal key range.
With this procedure, all normal node in a binary tree become internal nodes.

The advantage of sentinel node embodied in operations on node. We do not need to disginguish whether a node is root or normal leaf node.
For node x as example, We can safely reference  x.p, x.left.p, x.right.p, x.p.left, x.p.right, x.left.left, x.left.right, x.right.left, x.right.right
without checking where x.p, x.left, x.right is NULL. 

Be careful. **We can reference x.left.p or x.right.p safely but we should check before we assign the p field because we can't point p to another non-root node if x.left or x.right is T.nil.**

We use T.nil to represent the sentinel node.

## understand red-black tree properties

A red-black tree is a binary tree that satisfies the following red-black properties(named as p1 to p5):

1. Every node is either red or black.
2. The root is black.
3. Every leaf (NIL) is black.
4. If a node is red, then both its children are black.
5. For each node, all simple paths from the node to descendant leaves contain the same number of black nodes.

Note that P5 means every simple paths from any same node, not only from the root node but also any internal node, 
to descendant leaves contain the same number of black nodes.

We color the sentinel node black. Note that all leaves and root.p reference the sentinel node. The word leaf in P3 means the sentinel node.
With this procedure, all normal nodes become internal nodes.

The red-black tree poperties guarantee that the binary tree is almost balanced. How can we understand this intuitively? P5 means all simple paths from the root to descendant leaves contain the same number of black nodes. In a binary tree, if
all simple paths from the root to descendant leaves contain the same number of node, this must be a perfectly balanced tree.
Let's image all the black nodes form a tree, then it's balanced. P4 suppresses red nodes piling up. P4 and P5 imply the property that described in exercises 13.1-5：the longest simple path from root to a descendant leaf has length at most twice that of the shortest simple path from 
root to a descendant leaf. 

So, with red black tree properties, with binary tree balance, almost although.

Given fixed number of nodes in a binary tree, the more balanced, the shorter of tree height. Red-black tree properties make a binary tree is balanced enougn that a red-black tree with n internal nodes has height at most 2lg(n+1).

We define number of black nodes from a node x to a descendant leaf minus one as node x's black height bh(x).

**Note that the difference between black height and numbers of black nodes in one simple path. For example, two subtrees of one node may have different black height while simple paths from their roots absolutely contain same number of black nodes. Only the children are same color, we can say two subtrees has same black height.**

We can deduce following conclusions from red-black properties about black height:
* If one node is black and its parent is black, then its black height is one less than that of its parents.
* If one node is black and its parent is red, then its black height is equal to its parents' black height.
* If one node is red, its black height is equal to its parents' black height.

## maintains the red-black tree poperty

Most operations on a red black tree are same as on a general binary search tree. But modification will violate red-black tree properties.
A fixup must be made after the general insertion and deletion operation.

### rotations
Rotations are transformation of binary search tree while would't change binary-search-tree property(the keys relation that left subtree < root < right subtree).

If a node's left child is not T.nil, we can apply right-rotation on it. If a node's right child is not T.nil, we can apply left-rotation on it. 

![img](/assets/resources/bst-rotations.png)

**Rotations are not exchange of two subtrees, but choose a new node as the root node.** It can change the nodes distribution status of a binary tree and make it more balanced.

Only red links are modified in one rotations. Each link is bidirectional. We can simply preserve ε, x, y, β reference ahead and modify each bidirectional link top to bottom. Attations

<pre class="brush:python;">
def left_rotation(T, x):
	assert x.right != T.nil
	e = x.p
	y = x.right
	b = y.left

	# first link
	if e.left = x:
		e.left = y
	else:
		e.right = y
	y.p = e

	#second link
	y.left = x
	x.p = y

	#third link
	x.right = b
	if b != T.nil #Be careful. b should't be T.nil
		b.p = x
</pre>

right_rotation(T, x) is similar.

### rotation's effect on red-black properties

From property 5, we can know that if one subtree meets the condition of P5, then its subtrees do. 
Combine this feature with every situation of rotations, let's try analysis the effect of rotations.

Note that we are talking about black nodes in a simple path instead of black height. So let's define
bnn(x) as black nodes number contained in simple paths from node x to its descendant leaves.

If root node x is red, then bh(x) = bnn(x), else bh(x) + 1 = bnn(x).

In following graphs, we use α, β, γ represent a whole subtree and bnn(α) as its black number nodes from root to descendant leaves.
Whether the letter in bnn() brackets is a node or a subtree can be determined by the context. If we say there is one recoloring solution,
we means in a small range a solution exists. The small range is consist of five nodes including node x, y, α、β、γ’s roots.

#### case 1: upper node is red and nether node is red
If x is red and r is red, right and left rotation don't change any bnn of any node apparently
![img](/assets/resources/rotations-rr.png)

#### case 2: upper node is black and nether node is black
![img](/assets/resources/rotations-bb.png)

For left side of above graph, let bnn(x) = H, then we have:
* bnn(y) = H - 1. 
* bnn(γ) = H - 1.
* bnn(α) = bnn(β) = H - 2.

For right side of above graph, three subtrees don't change their internal structure. so we still have:
* bnn(γ) = H - 1.
* bnn(α) = bnn(β) = H - 2.

node x and y exchange their position, so we should have:

* bnn(y) = H.
* bnn(x) = H - 1.

But it's easy to check neither of them keep. 
* For y, bnn(α)+1 ≠ bnn(β)+2. 
* For x, bnn(γ)+1 ≠ bnn(β)+1. 

Subtree rooted at x and y violates P5.

The question is how to color α, β, γ's root nodes making subtree x and y meet P5.
Note that y's left subtree bnn is too small and x's right subtree bnn is too large.

There is one solution for right rotation when α, β's root is red and γ‘s root is black. 
We can change α, β's roots to black and x's color to red.

![img](/assets/resources/rotations-bbr-solution.png) 

While β,γ's root nodes are red, there is one solution for left rotation:

![img](/assets/resources/rotations-bbl-solution.png) 

#### case 3: upper node is black and nether node is red
When x is black and y is red, right rotation is as follows:
![img](/assets/resources/rotations-brr.png)

There is one solution under codition:

![img](/assets/resources/rotations-brr-solution.png)

Note that the solution change γ's parent color from black to red, it require γ's root is black.

Left rotation is similar.

![img](/assets/resources/rotations-brl.png)

And the solution is:

![img](/assets/resources/rotations-brl-solution.png)

Note that the solution change α's parent color from black to red, it require α's root is black.

#### case 4: upper node is red and nether node is black
When x is red and y is black, right rotation and left rotation are as follow:
![img](/assets/resources/rotations-rbl.png)

![img](/assets/resources/rotations-rbr.png)

Case 4 not only violates P5 but also p4. It's easy to check there are no color solution for this case.

Note that only P5 has been violated in case 2 and case 3.

We should clearly realize that there are four situations from case 1 to case 3 in which a rotation with recoloring will violate neither binary-search-tree property nor 
red-black properties. We'll use these rotation with recoloring in insertion and deletion operations on red black trees.

### insert
In order to figure out how red black tree insertion works, let's first check what insert do if we treat red black tree as a
general binary search tree and color the new node red.

<pre class="brush:python;">
def rb_general_insert(T, x):
	if T.root = T.nil:
		T.root = x
		x.p = T.nil
		return

	c = T.root
	p = c.p
	while c != T.nil:
		p = c
		if x.key < c.key:
			c = c.left
		elif x.key > c.key:
			c = c.right
		else:
			raise Exception("same key")

	if x.key < p.key:
		p.left = x
	else:
		p.right = x
	x.p = p
	x.color = red

</pre>

Why do we color new node red? This question has been mentioned in exercises 13.3-1, but I can't agree with [some answer][0] saying black node violates
P5, because red new node may also violate red-black properties that is P4. So violating P5 is not an reason. I don't know whether there is a way to fixup red-black properties if we color new node black, but there is one good reason not to do this. That is cost. Recall that half nodes at least in red black tree is black nodes. Only new node's parent is red, a fixup is needed. By contrast, every time a new black node join in, a fixup must be done.

To understand what we will do to fixup red-black properties, firstly let's figure out how does insert procedure violates red black properties.

If T is an empty tree, then x become red root and violates P2. It's easy to fixup with recoloring x red.

If x becomes a child of one red node, this insertion violates P4, then there are three cases. The CLRS book explains those cases very well, so we skip the illustration and just show the code.

<pre class = "brush:python;">
def rb_insert_fixup(T, x):
	while x.p.color == red: # if x is root, then x.p.color must be black
		if x.p == x.p.p.left: # given x.p is not root, so x.p.p exists
			y = x.p.p.right
			if y.color = red:
				x.p.color = black
				x.p.p.color = red
				y.color = black

				x = x.p.p # a new red node occurs without knowing its parents' color
			else: # in this branch, there is no new red node become child of color-unknow node
				if x = x.p.right:
					# after rotation, x takes position of original x.p
					left_rotation(x.p) # this rotation is described in case 1 above

				# after rotation, x.p takes position of original y
				# x takes position of original x.p.p
				right_rotation(x.p) # this rotation and recoloring below is described in case 3 above
				x.color = black
				x.right.color = red
		# opposite completely
		else x.p == x.p.p.right:
			y = x.p.p.left:
			if y.color = red:
				x.p.color = black
				x.p.p.color = red
				y.color = black

				x = x.p.p
			else:
				if x = x.p.left:
					right_rotation(x.p)

				left_rotation(x.p)

				# x take position of original x.p.p
				x.color = black
				x.left.color = red

	T.root.color = black
</pre>

Just add this procedure at the end of general_insert function.

### delete
As insertion, let's first give out the general deletion code, then check which property the procedure violates and fix it.

This function just just rebuild v and u's parent relation and doesn't process relation between u's children and v.
<pre class = "brush:python;">
def rb_transplant(T, u, v):
	if u == T.root:
		T.root = v
	elif u == u.p.left:
		u.p.left = v
	else:
		u.p.right = v
	v.p = u.p
</pre>

The restrictions of transplant() are same as charpter 12.

The book version is not correct. 
<pre class ="brush:python;">
def rb_general_delete(T, x):
	r = None
	if x.left == T.nil:
		r = x.right
	elif x.right == T.nil:
		r = x.left
	else:
		r = minimum(x.right) # x's successor must be in x's right subtree
		if r.p == x: # then x's successor r is x.right and r has no children
			r.right.p = x  # just delete r
			
		else: # then r must only have none or one right child
			transplant(T, r, r.right) # delete r.right automaticly and r is free

		transplant(T, x, r) # delete x and rebuild links between x's children and r
		r.left = x.left
		x.left.p = r
		r.right = x.right
		x.right.p = r

		r.color = x.color
</pre>

Now let's see how red-black properties are violated. 

If x has at most one child:
* If x is black, deleting x violates P5. 
* If x's parent and the only child of x are both red, then violates P4. This can only happens when x is black.
* If x is red, no violations.

If x has two children, x's replacer inherits x's color. We only need to inspect moving of x's successor. 
As x's successor has at most one right child, the viloation is same as above.

Let D be the removed node which at most has one child in above two cases. We need to record the node z which takes D's position and record D's original color in the delete procudure, then call fixup procedure when D's original color is black. Highlight lines are newly added.

<pre class ="brush:python;highlight:[3,4,11,12,27,28];">
def rb_delete(T, x):

	z = None
	D_original_color = x.color
	if x.left == T.nil:
		transplant(T, x, x.right) # x.right is freed automaticly and reestablished
		z = x.right
	elif x.right == T.nil:
		transplant(T, x, x.left)
		z = x.left
	else:
		r = minimum(x.right) # x's successor must be in x's right subtree
		z = r
		D_original_color = r.color
		if r.p == x: # then x's successor r is x.right and r has no children
			r.right.p = x  # just delete r
			
		else: # then r must only have none or one right child
			transplant(T, r, r.right) # delete r.right automaticly and r is free

		transplant(T, x, r) # delete x and reestablish links between x's children and r
		r.left = x.left
		x.left.p = r
		r.right = x.right
		x.right.p = r

		r.color = x.color

	if S_original_color = black:
		rb_delete_fixup(T, z)
</pre>

Note that when x has two children and successor is not x's right child, node x is replaced with its successor's key and value field but not p,left,right,color field. This is different with deleting x. While x's successor is really deleted from its original position. So there is only 
one deletion operation in such a case.

Let's examine what happens after D's successor z takes position of D. There is a little trick when processing deletion of D. We think z carries an extra color coming from D, so z has two color, one is its and one is from D. Under such condition, P5 keeps but not P1. What we will do is to move the two color node until:

* the two color node becomes T.root, we can safely remove the extra color and all properties keep. This is described in case 2 of CLRS 13.4.

![img](/assets/resources/rb_deletion_case2.png){:width="100%"}

* its parent and uncle is red and grandfather is black. The extra color can move to its parent while its grandfather's black move to the uncle.
This is described in case 4 of CLRS 13.4. 

![img](/assets/resources/rb_deletion_case4.png){:width="100%"} 

While case 1 and case 3 can be translated to case 2 or case 4, which can be found in the CLRS 13.4. In case 1 or case 3, the original color of
node A and B don't matter.

<pre class="brush:python;">
def rb_delete_fixup(T, z):
	w = None
	while z != Y.nil and z.color == black:
		if z == z.p.left:
			w = z.p.right
			# case 1
			if w.color == red:
				w.color = black
				z.p.color = red # set z.p's color without care its original color
				left_rotation(T, z.p)
				w = z.p.right # after rotation, z's sibling changed.
				assert w.color == black

			# case 2
			if w.left.color == black and w.right.color = black:
				w.color = red
				z = z.p # move x upwards 
			
			else:
				# case 3
				if w.right.color = black:
					w.color = red
					w.left.color = black
					right_rotation(T, w)
					w = z.p.right
				#case 4
				assert w.right.color == red
				w.color = z.p.color
				z.p.color = black
				w.right.color =  black
				left_rotation(T, z.p)

				z = T.root

		else:
			w = z.p.left
			# case 1
			if w.color == red:
				w.color = black
				z.p.color = red # set z.p's color without care its original color
				right_rotation(T, z.p)
				w = z.p.left # after rotation, z's sibling changed.
				assert w.color == black

			# case 2
			if w.left.color == black and w.right.color = black:
				w.color = red
				z = z.p # move x upwards 
			
			else:
				# case 3
				if w.left.color = black:
					w.color = red
					w.right.color = black
					left_rotation(T, w)
					w = z.p.left
				#case 4
				assert w.left.color == red
				w.color = z.p.color
				z.p.color = black
				w.left.color =  black
				right_rotation(T, z.p)
				
				z = T.root

	z.color = black
</pre>

## exercises
[answer](https://walkccc.github.io/CLRS/Chap13/13.1/)


[0]:https://walkccc.github.io/CLRS/Chap13/13.3/
