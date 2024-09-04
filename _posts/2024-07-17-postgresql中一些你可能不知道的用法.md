---
layout:     post
title:      postgresql中一些你可能不知道的用法
subtitle:   不能这么用？还能这么用？
date:       2024-07-17
author:     DreamCat
header-img: img/post-bg-debug.png
catalog: true
tags:
    - SQL
    - Database
    - Postgres
    - GaussDB
---



# SELECT

# ORDER BY

默认的排序方式为按照ASCII增序排列。
''(空串)小于任何一个字符串,null大于任何一个字符串

因此，在对数据进行降序排列时，可以加上NULLS LAST,把null放在最后

Pgsu987! 5432

# bool

布尔值只能为true/false/null中的一个

## 判断
以下sql，结果为true的是，false的是，null的是，~~报错的是，没有返回值的是~~

```
SELECT 2::boolean AS A;  
```
<details>
<summary>A答案</summary>
A 显然是true，符合常识  
</details>

```
SELECT (-1)::boolean AS B;  
```
<details>
<summary>B答案</summary>
B 强转boolean时，非0全是true  
</details>

```
SELECT 'a'=1 AS C;  
```
<details>
<summary>C答案</summary>
C 数值类型强转的优先级更高，改语句实际为SELECT 'a'::int=1 AS C,报错  
</details>

```
SELECT null=null AS D;  
```
<details>
<summary>D答案</summary>
D 两个为止无法比较，应使用SELECT null is null 
</details>

```
SELECT ' 1 '=1 AS E;  
```
<details>
<summary>E答案</summary>
E 同C，隐式转换自动去掉了空格
</details>

```
SELECT null AS F WHERE null ;
```
<details>
<summary>F答案</summary>
F WHERE条件为false或null时不会返回
</details>

```
SELECT not null AS G;  
```
<details>
<summary>G答案</summary>
G 对未知取否还是未知
</details>

```sql
SELECT 'tr'::boolean AS H;  
```
<details>
<summary>H答案</summary>
H t、tr、tru、true无论大小写都能转换为true，false同理 
</details>
 
## 存储

```sql
drop table if exists test_bool_length;
create table test_bool_length
(
bool_storge_test_true varchar(1),
bool_storge_test_false varchar(1)
);
insert into test_bool_length
(
bool_storge_test_true,
bool_storge_test_false
)
select 
1::boolean as bool_storge_test_true,
0::boolean as bool_storge_test_false
;
```

<details>
<summary>长度说明</summary>
true实际上以'true' varchar(4)存储,
false是varchar(5)

```sql
select 
bool_storge_test_true::varchar,
length(bool_storge_test_true),
bool_storge_test_false::varchar,
length(bool_storge_test_false)
from test_bool_length
;
```

我不理解

</details>

## null

表示unknown,
你想要它是什么它就是什么,
个人认为含义不应为‘空’，而是‘黑洞’

# WHERE

WHERE条件整体返回的是一个布尔值，
作用与每条该值仅在该条为true时返回，
false或null时不会返回

不用管网上说的WHERE 1=1增加耗时，放心写，**相信优化器**，
如果你连=都懒得写就直接写WHERE 1

# ANALYSE

ANALYSE和ANALYZE完全等价  
正常用法ANALYSE表，但也可以作用在列或整个数据库

```
ANALYSE;  --整个数据库,耗时很长,慎用
ANALYSE table1;  --表
ANALYSE table1(column1);  --列
```

# EXPLAIN

# Special Thanks

[postgres/postgres-Github](https://github.com/postgres/postgres)