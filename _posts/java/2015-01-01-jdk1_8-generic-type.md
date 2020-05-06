泛型背后的设计思想是什么

参数化类型是一种特殊的类型
上面是assignable，下面又不能通过Integer数组列表来初始化
```
        ArrayList<Integer> arr_i = new ArrayList<Integer>();
        ArrayList<Number> arr_n = new ArrayList<Number>();
        // 说是不变的，但是isAssignable又是可以的
        System.out.println(arr_n.getClass().isAssignableFrom(arr_n.getClass()));
        arr_n.add(new Integer(1));
        //arr_n = new ArrayList<Integer>();
```
或者说isAssignable在泛形时有特殊规定？

泛型为什么要不协变啊