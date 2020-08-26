---
layout: post
title: 一个搜索类算法模型的实现

tagline: "Supporting tagline"
category : 算法
tags : [搜索问题, 算法]

---
{% include JB/setup %}

* toc
{:toc}

<hr />


本文的重点在于构建一个模型，该模型包含一个状态树数据结构，以及生成该状态树的接口与实现。

随后用这个模型解决一个搜索类问题：八皇后问题。

## 模型要求

一般搜索类问题都会形成一棵树状的结构。而其中最优解类问题通常不需要真正存储这棵树结构，
而往往使用栈（函数栈（递归）或者自定义栈（循环））来记录在数上各个节点间的遍历情况。

搜索最优类问题也可以分为两类：一是目标确定，要求路径最优，A star算法就是处理这类的，二是目标不确定，要求目标状态最优，
往往需要遍历所有状态。

而我们想要实现的搜索模型，是要将这棵树存储下来。这样在第二类目标不确定的时候，可以变更最优的语义，
反复利用生成的树。

当然，也有的图形类搜索问题，程序在接受图形的时候就需要将图形建立起来，后续的遍历实质上在该图形上
形成树，但这与我们的模型没有冲突，依然可以用我们的模型来处理这类问题，因为我们的模型只是记录树中节点的关系，节点的实际存储位置由使用者确定。

这样的一棵树我们这里称之为状态树（我不确定是否有现成的更专业的名字），就像人的思维过程：人思考一个复杂的事情的时候，就是会先思考一个状态，该状态下做某种决策导致的下一个状态。

在这样的树形结构中，每一个节点实际上代表一个状态，其子节点就是要转变的下一个状态。
我们允许两个节点有相同的下一个状态，因此共享同一个子节点，从而我们将树扩展到有向无环图（DAG）。
鉴于实现DAG的复杂性，本文给出的实现并未没有实现DAG，还是树。

生成树的过程中必须先确定当前节点状态才能获知下一步状态，因而生成树的过程不能是后续遍历的顺序。

因此生成与搜索是不一样的过程，建模中我们也需要将其分开。因此可以一次生成，多次搜索。

但是状态树的主要目的是客观的记录状态的演变过程，如何搜索、评估整体状态是使用者的事情。

对于生成过程中共享节点的实现，需要使用者自己实现一个节点ID算法，模型则通过检查是否存在该ID，来决定是否共享。

我们提供剪纸接口`prune`，使用者恰当的使用`prune`能使得DAG实质退化为栈。本文给出的实现并未实现`prune`接口。

## 模型实现
### 数据结构
![img](/assets/resources/states_tree.png)

基本数据结构比较简单，唯一需要注意到是每个状态节点上存储该状态下可以做出的决策而不是其子状态节点，通过决策找到其子状态节点。
每个状态与决策有ID标识。

区分决策与子状态节点是必要的，因为子状态是全局唯一的，因而ID也是唯一的，不同的状态上不同的决策可以到达同一个子状态，而决策ID只在同一个状态内是唯一的，不同的状态可能有相同的决策（视使用者语义而定），但我们不做联系或区分，换句话说，我们不对决策建模。

### 生成DAG的接口

```brush:python
class Node(object):
    @property
    def kind(self):
        return self._kind

    @kind.setter
    def kind(self, kind):
        self._class = kind

    @property
    def id(self):
        return self._id

    @id.setter
    def id(self, id):
        self._id = id

    @property
    def parent(self):
        return self._parent

    @property
    def decisions(self):
        return self._decisions

    def add_decision(self, decision):
        self._decisions.append(decision)

    @property
    def node_manager(self):
        return self._node_manager

    @node_manager.setter
    def node_manager(self, node_manager):
        self._node_manager = node_manager

class Decision(object):
    @property
    def id(self):
        return self._id

    @property
    def next_node_kind(self):
        return self._next_node_kind

    @property
    def next_node(self):
        return self._next_node

    @next_node.setter
    def next_node(self, node):
        self._next_node = node


class BaseKindManager(object):
    kind = None 
    @staticmethod
    def create_node(kind, parent, decision):
        pass

    @staticmethod
    def get_node_manager(model, node):
        pass

class search_model(object):
    @property    
    def root(self):
        return self._root

    def register_root_kind_manager(self,kind, manager):
		pass

    def register_kind_manager(self, kind, manager):
    	pass

    # all ancestor nodes on the path from root to node
    def path(self, node):
    	pass
    
    def add_decision(self, decision):
        pass

    def model(self):
    	pass
```

Node、Decision比较好理解，分别对应状态树中的节点和边。

BaseKindManager是用来创建Node的，我们认为状态树中的一些节点属于同一种类，就是有相同创建或初始化行为、相同的
决策行为，这些Node由同一个KindManager来创建。每个KindManager有一个唯一的kind标志符，通常是个数字。

每个Node中包含一个NodeManager属性，同样由该Node的KindManager创建，该属性为一个迭代器，每次调用返回该Node表示的状态下可以做出的一个决策。决策包含导致下一个状态的行为以及下一个状态所属的kind，SearchModel根据这个决策来访问或创建（利用kind找到对应的KindManager）下一个Node。

NodeManager由使用者实现，因而由使用者决定以何种顺序来给出这些决策，当NodeManager返回一个决策的时候，SearchModel引擎
将根据这个决策直接访问或者创建后访问下一个状态Node，访问下一个的Node的动作就是再一次调用该Node的NodeManager。

也就说，NodeManager管理Node本身的自定义行为和决策访问顺序，在每一次给出决策前，NodeManager有机会获知整个状态树的情况（因为其引用了SearchModel）。NodeManager给出决策前，比如调用add_decision通知SearchModel有这样一种决策存在（SearchModel据此建立状态树）。

在NodeManager给出决策的过程中，可以通过给出-1来访问当前Node的parent，通过给出None来告知SearchModel停止继续决策。NodeManager本身是一个
迭代器，当抛出StopIteration异常时，视为给出-1，自动访问parent Node。

SearchModel的使用方法是先注册不同的KindManager，然后调用model就可以了。一般而言，需要两种KindManager，第一个用于初始化，其创建的NodeManager用于给出初始状态下有哪些决策。

### 遍历DAG的接口
构建中。

```brush:python
class BaseVisitor(object):

    def visit(self, node):
        pass

    def next(self):
        pass
```

### 完整代码

<pre class="brush:python;">
import gc

class Node(object):
    def __init__(self, kind, id, parent):
        self._kind = kind
        self._id = id
        self._parent = parent
        self._node_manager = None
        self._decisions = []

    @property
    def kind(self):
        return self._kind

    @kind.setter
    def kind(self, kind):
        self._class = kind

    @property
    def id(self):
        return self._id

    @id.setter
    def id(self, id):
        self._id = id

    @property
    def parent(self):
        return self._parent

    @property
    def decisions(self):
        return self._decisions
    @decisions.setter
    def decisions(self, decisions):
        self._decisions = decisions

    def add_decision(self, decision):
        self._decisions.append(decision)

    @property
    def node_manager(self):
        return self._node_manager

    @node_manager.setter
    def node_manager(self, node_manager):
        self._node_manager = node_manager

    def free(self):
        del self._parent
        del self._node_manager

class Decision(object):
    def __init__(self, kind, id):
        self._id = id
        self._next_node_kind = kind
        self._next_node = None

    @property
    def id(self):
        return self._id

    @property
    def next_node_kind(self):
        return self._next_node_kind

    @property
    def next_node(self):
        return self._next_node

    @next_node.setter
    def next_node(self, node):
        self._next_node = node
    def free(self):
        del self._id
        del self._next_node_kind
        self._next_node.free()
        _id = self._next_node.id
        del self._next_node

class BaseKindManager(object):
    kind = None 

    @staticmethod
    def create_node(kind, parent, decision):
        pass

    @staticmethod
    def get_node_manager(model, node):
        #model.add_node model.add_decision model.path
        pass


class BaseVisitor(object):

    def visit(self, node):
        pass

    def next(self):
        pass


class search_model(object):
    def __init__(self):
        self._root = None
        self._kind_map = dict()
        self._auto_prune = False

        self._node_total = 0

    @property    
    def root(self):
        return self._root
    
    @property
    def node_total(self):
        return self._node_total

    def register_root_kind_manager(self,kind, manager):
        manager.kind = kind
        self._root_kind_manager = manager
        self._kind_map[kind] = manager

    def register_kind_manager(self, kind, manager):
        manager.kind = kind
        self._kind_map[kind] = manager

    # all ancestor nodes on the path from root to node
    def path(self, node):
        path = []
        while node != self._root:
            path.insert(0, node)
            node = node.parent
        return path
    
    def add_decision(self, decision):
        self.cur_node.add_decision(decision)

    @staticmethod
    def _check_decision(node, decision):
        for d in node.decisions:
            if decision.id == d.id:
                return True
        return False

    @staticmethod
    def _to_parent(decision):
        return decision == -1

    @staticmethod
    def _is_finish(decision):
        return decision == None

    def _has_parent(self):
        return self.cur_node.parent != None

    def _delete_children(self, node):

        for d in node.decisions:
            d.free()
            self._node_total -= 1
        del d
        node.decisions = []

    def _goto_parent(self):
        self.cur_node = self.cur_node.parent
        self.cur_node_manager = self.cur_node.node_manager

        if self._auto_prune:
            self._delete_children(self.cur_node)
            gc.collect()

    def model(self, prune=False):
        self._auto_prune = prune
        #init root node
        self._root = self._root_kind_manager.create_node(self._root_kind_manager.kind, None, None)
        self._node_total += 1
        root_manager = self._root_kind_manager.get_node_manager(self, self._root)
        self._root.node_manager = root_manager

        self.cur_node = self._root
        self.cur_node_manager = self._root.node_manager

        while True:
            try:
                decision = self.cur_node_manager.next()
            except StopIteration:#if stopiteration exception occurs, goto parent node automaticlly
                if self._has_parent():
                    self._goto_parent()
                    continue
                print "No more ancestor. Finish"
                break

            if search_model._to_parent(decision):
                if self._has_parent():
                    self._goto_parent()
                    continue
                print "No more ancestor. Finish"
                break              
 
            if search_model._is_finish(decision):
                print "No more decision. Finish."
                break
            
            if not search_model._check_decision(self.cur_node, decision):
                print "decision should be added before being choiced"
                break

            #normal decision goes bellow
            #the node has been created
            if decision.next_node:
                self.cur_node = decision.next_node
                self.cur_node_manager = self.cur_node.node_manager
            else:# it's the first time to this node, so create it
                kind_manager = self._kind_map[decision._next_node_kind]
                next_node = kind_manager.create_node(self, self.cur_node, decision)
 
                decision.next_node = next_node
                self._node_total += 1

                self.cur_node = next_node
                self.cur_node_manager = kind_manager.get_node_manager(self, self.cur_node)

                self.cur_node.node_manager = self.cur_node_manager
        
</pre>

## 应用
### 八皇后问题

```brush:python

from search_model import BaseKindManager
from search_model import Node
from search_model import search_model
from search_model import Decision

def node_id():
    _id = 0
    while True:
        yield _id
        _id += 1

get_node_id = node_id()

class MyNode(Node):
    def __init__(self, kind, id, parent, position, order):
        super(MyNode, self).__init__(kind, id, parent)
        self._position = position
        self._order = order

    @property
    def position(self):
        return self._position

    @property
    def order(self):
        return self._order

class MyDecision(Decision):
    def __init__(self, kind, id, position):
        super(MyDecision, self).__init__(kind, id)
        self._position = position

    @property
    def position(self):
        return self._position

class RootKindManager(BaseKindManager):

    @staticmethod
    def create_node(kind, parent, decision):
        return MyNode(kind, get_node_id.next(), parent, None, 0)

    @staticmethod
    def get_node_manager(model, node):
        def node_manager():
            for i in range(1, 9):
                d = MyDecision(1, i, (1, i))
                model.add_decision(d)
                yield d
        return node_manager()

solution_count = 1

class NormalKindManager(BaseKindManager):
    @staticmethod
    def create_node(kind, parent, decision):
        return MyNode(kind, get_node_id.next(), parent, decision.position, parent.order+1)

    @staticmethod
    def in_lean_lines(node, position):
        return abs(node.position[0]-position[0]) == abs(node.position[1]-position[1])

    @staticmethod 
    def in_vertical_horizontal_lines(node, position):
        return node.position[0] == position[0] or node.position[1] == position[1]

    @staticmethod
    def get_node_manager(model, node):
        
        def node_manager(model, node):
            path = model.path(node)
            #find all the valid position
            """
            _ * * * _ _ _ _
            _ * + * _ _ _ _
            _ * * * _ _ _ _

            Say + position is (x, y)
            then (x+n, y+n) (x+n, y-n) (x-n, y+n) (x-n, y-n) will not be available for a const number n
            also (x+n, y) (x-n, y) (x, y+n) (x, y-n) will not be available
            so a queue can detemine four dead lines on which positions are not available
            """

            for i in xrange(1, 9):
                available = True
                for p in path:
                    if NormalKindManager.in_lean_lines(p, (node.order+1, i)) or \
                        NormalKindManager.in_vertical_horizontal_lines(p, (node.order+1, i)):
                        available = False
                
                if available:
                    if node.order + 1 == 8:# then we find a solution
                        global solution_count
                        print "solution ", solution_count
                        for p in path:
                            print p.position
                        print (node.order+1, i)
                        print "---------"
                        solution_count += 1
                        yield -1
                    else:
                        d = MyDecision(1, i, (node.order+1, i))
                        model.add_decision(d)
                        yield d
            yield -1 # all positions are't available, we may prune at the moment 

        return node_manager(model, node)

if __name__ == "__main__":
    sa = search_model()
    sa.register_root_kind_manager(0, RootKindManager)
    sa.register_kind_manager(1, NormalKindManager)
    sa.model()
```
对于八皇后问题，正确的解中八个皇后必然不同行不同列。因此我们一行一行的来摆放8个皇后。
RootKindManager出个第一个皇后可以放置的位置，用`(1,1) (1,2)...`来表示。可做的决策就是下一个
皇后可以摆放的位置。比如第一个放在`(1,2)`，则第二个就放在第二行但不包括`(2,1) (2,2)`这两个位置的地方。

运行代码可以解出92个解，与[wiki](https://www.wanweibaike.com/wiki-%E5%85%AB%E7%9A%87%E5%90%8E%E9%97%AE%E9%A2%98)上的说法一致。

### 跳房子游戏

跳房子游戏是一个棋盘类跳棋游戏：共有15颗一样的棋子，棋盘如下

![img](/assets/resources/skip_house.png)

规则如下：
1. 任意拿走一个棋子，形成一个空位
2. 如果一个棋子与一个空位的仅仅间隔一个棋子，则该棋子可以跳到该空位，并拿掉间隔棋子
3. 重复第2步，直到棋盘上仅剩下一颗棋子

显然跳房子游戏可以用搜索来解。每走一步形成的棋盘格局就是节点状态。完整代码如下：

```brush:python
import sys

from search_model import BaseKindManager
from search_model import Node
from search_model import search_model
from search_model import Decision

def node_id():
    _id = 0
    while True:
        yield _id
        _id += 1

get_node_id = node_id()

last_node_id = -1

#CB: checkerboard
class CB:
    #node which order is o and position at (i, j)
    #(i, j) means row j, cols i
    j_2_o={
        0:[1],
        1:[2, 3],
        2:[4, 5, 6],
        3:[7, 8, 9, 10],
        4:[11, 12, 13, 14, 15]
    }
    o_2_j=dict()
    @staticmethod
    def init():
        for j in CB.j_2_o:
            for o in CB.j_2_o[j]:
                CB.o_2_j[o] = j
    
    @staticmethod
    def at(i, j):
        if i<0 or j<0:
            return None

        if j in CB.j_2_o:
            if i < len(CB.j_2_o[j]):
                return CB.j_2_o[j][i]
        return None
    
    @staticmethod
    def location(o):
        assert (o > 0 and o < 16)
        o_j = CB.o_2_j[o]
        o_i = CB.j_2_o[o_j].index(o)
        return (o_i, o_j)

     #clockwise. from left-top
    @staticmethod
    def around(o):
        o_i, o_j = CB.location(o)
        ret = []
        ret.append(CB.at(o_i-1, o_j-1))
        ret.append(CB.at(o_i, o_j-1))
        ret.append(CB.at(o_i+1, o_j))
        ret.append(CB.at(o_i+1, o_j+1))
        ret.append(CB.at(o_i, o_j+1))
        ret.append(CB.at(o_i-1, o_j))
        return ret
        
    @staticmethod
    def compute_source(dest, skip):
        l_dest = CB.location(dest)
        l_skip = CB.location(skip)
        s_i = l_skip[0]+(l_skip[0]-l_dest[0])
        s_j = l_skip[1]+(l_skip[1]-l_dest[1])
        return CB.at(s_i, s_j)

    @staticmethod
    def candidates(empty):
        ret = []
        for hole in empty:
            around = CB.around(hole)
            for a in around:
                if a and a not in empty:
                    s = CB.compute_source(hole, a)
                    if s and s not in empty:
                        ret.append((s, a, hole))
        return ret
    @staticmethod
    def print_cb(empty):
        pat = ["         1        ",\
               "       2   3      ",\
               "     4   5   6    ",\
               "   7   8   9  10  ",\
               "11  12  13  14  15"]
        for j in range(5):
            p = pat[j]
            r = p
            for hole in (set(empty).intersection(set(CB.j_2_o[j]))):
                if str(hole) in p:
                    r = r.replace(str(hole), " "*len(str(hole)))
            print r

class MyNode(Node):
    def __init__(self, kind, id, parent, decision, holes):
        super(MyNode, self).__init__(kind, id, parent)
        self._decision = decision
        self._holl = None
        self._holes = holes
    @property
    def decision(self):
        return self._decision
    @property
    def holes(self):
        return self._holes

class InitDecision(Decision):
    def __init__(self, kind, id, hole):
        super(InitDecision, self).__init__(kind, id)
        self._hole = hole
    @property
    def hole(self):
        return self._hole

class SkipDecision(Decision):
    def __init__(self, kind, id, source, skip, dest, holes):
        super(SkipDecision, self).__init__(kind, id)
        self._source = source 
        self._skip = skip 
        self._dest = dest
        self._holes = holes
    
    @property
    def source(self):
        return self._source
    @property
    def skip(self):
        return self._skip
    @property
    def dest(self):
        return self._dest
    @property
    def holes(self):
        return self._holes
    

class RootKindManager(BaseKindManager):

    @staticmethod
    def create_node(kind, parent, decision):
        return MyNode(kind, get_node_id.next(), parent, decision, None)

    @staticmethod
    def get_node_manager(model, node):
        def node_manager():
            for i in range(15):
                d = InitDecision(1, i, i+1)
                model.add_decision(d)
                yield d
        return node_manager()

solution_count = 0
class NormalKindManager(BaseKindManager):

    @staticmethod
    def create_node(kind, parent, decision):
        last_node_id = get_node_id.next()
        if isinstance(decision, InitDecision):
            return MyNode(kind, last_node_id, parent, decision, [decision.hole])
        elif isinstance(decision, SkipDecision):
            #compute empty
            node_holes = []
            node_holes.extend(decision.holes)

            node_holes.remove(decision.dest)
            node_holes.extend([decision.source, decision.skip])
            return MyNode(kind, last_node_id, parent, decision, node_holes)

    @staticmethod
    def print_path(path):
        print "-"*20
        for n in path:
            CB.print_cb(n.holes)
        print "-"*20

    @staticmethod
    def get_node_manager(model, node):
        def node_manager():
            if model.node_total > 100 or model.node_total<0:
                print "nodes number limit"
                sys.exit()

            if len(node.holes) == 14:
                #global solution_count
                #solution_count += 1
                #print solution_count
                NormalKindManager.print_path(model.path(node))
                yield None #stop while found first solution
        
            candidates = CB.candidates(node.holes)
            decision_id = 0
            for c in candidates:
                d = SkipDecision(1, decision_id, c[0], c[1], c[2], node.holes)
                model.add_decision(d)
                decision_id += 1
                yield d
            yield -1
        return node_manager()



if __name__ == "__main__":  
    CB.init()
    sa = search_model()
    sa.register_root_kind_manager(0, RootKindManager)
    sa.register_kind_manager(1, NormalKindManager)
    sa.model(prune=True)
```

上面的代码很容易求出一个解，也可以启用注释部分来找出所有的解的数目。有意思的是，给定棋盘位置编号并且不考虑旋转、对称的情况下，
跳房子游戏的解法竟然高达48万。

推测是跳房子的解法中存在大量的重复状态，然而我们的模型还不支持DAG。

支持DAG是一个留待解决的问题。

## MORE
剪枝

并行搜索

桌游场景复杂判断