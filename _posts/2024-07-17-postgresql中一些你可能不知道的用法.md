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
    - Postgresql
    - GaussDB
---

# 名称

表名、字段名支持unicode。可以，但不建议。
```sql
DROP TABLE IF EXISTS 用中文表名怎么你了;
CREATE TABLE 用中文表名怎么你了
(
  用中文字段名怎么你了 varchar(1000),
  🥰 varchar(100)
);

SELECT 用中文字段名怎么你了,🥰 FROM 用中文表名怎么你了;
```

# SELECT

## DISTINCT

# ORDER BY

默认的排序方式为按照ASCII增序排列。
''(空串)小于任何一个字符串,null大于任何一个字符串

因此，在对数据进行降序排列时，可以加上NULLS LAST,把null放在最后

## 指定内容排序

```sql
DROP TABLE IF EXISTS ccy_table;
CREATE TABLE ccy_table
(
  ccy varchar(3)
);
INSERT INTO ccy_table (ccy)
VALUES 
('CNY'),  -- 人民币
('USD'),  -- 美元
('EUR'),  -- 欧元
('JPY'),  -- 日元
('GBP'),  -- 英镑
('AUD'),  -- 澳大利亚元
('CAD'),  -- 加拿大元
('HKD'),  -- 港币
;

--币种表人民币排最前,美元第二,其余按照字母排序
SELECT *
FROM ccy_table
ORDER BY
  CASE 
    WHEN ccy = 'CNY' THEN 1
    WHEN ccy = 'USD' THEN 2
    ELSE 3
  END,
  ccy ASC
;
```

```sql
DROP TABLE IF EXISTS people_name_table;
CREATE TABLE people_name_table (
    name varchar(50)
);

INSERT INTO people_name_table (name) VALUES ('张三'), ('李四'), ('王五'),('艾AA'),('李白');

--人名按照汉语拼音A-Z升序排序
SELECT * FROM people_name_table
ORDER BY name COLLATE "zh_CN.utf8"; --注意是双引号

--查看支持中文的排序
SELECT * FROM pg_collation
WHERE (
collname ilike '%zh%'
or collname ilike '%han%'
or collname ilike '%cn%'
);

```



# CAST

## 显式转换（强制转换）

写在代码中的
```
CAST(column1 AS varchar)
```
和
```
column1::varchar
```
完全等价，推荐使用后者，因为打字少

## 隐式转换

SQL语句自动转换的,  


# bool

布尔值只能为true/false/null中的一个

## 判断
以下sql，结果为true的是，false的是，null的是，~~报错的是，没有返回值的是~~

```
SELECT 2::boolean AS A;  
```
<details>
<summary>A答案</summary>
A true  
</details>

```
SELECT (-1)::boolean AS B;  
```
<details>
<summary>B答案</summary>
B 强转boolean时，非0全是true  
</details>

```sql
SELECT (1.1)::boolean
```
<details>
<summary>答案</summary>
 报错，转boolean只支持整数
</details>

```sql
SELECT 0.1+0.2=0.3
```
<details>
<summary>答案</summary>
 true,因为默认以decimal存储，结果并不是float的0.30000000000000004
</details>


```sql
SELECT 'a'=1 AS C;  
```
<details>
<summary>C答案</summary>
C 数值类型强转的优先级更高，该语句实际为SELECT 'a'::int=1 AS C,报错  
</details>

```sql
SELECT null=null AS D;  
```
<details>
<summary>D答案</summary>
D 两个为止无法比较，应使用SELECT null is null 
</details>

```sql
SELECT ' 1 '=1 AS E;  
```
<details>
<summary>E答案</summary>
E 同C，隐式转换自动去掉了空格
</details>

```sql
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

不用管网上说的WHERE 1=1增加耗时，放心写，**相信优化器**，不信你可以在后面加100个and 1=1试试
```sql
SELECT 'SELECT ''测试耗时'' WHERE 1 '||string_agg('AND 1=1', ' ') AS result
FROM generate_series(1, 100);
```
如果你连=都懒得写就直接写WHERE 1(GaussDB,原生Postgres并不支持)

# ANALYSE

ANALYSE和ANALYZE完全等价  
正常用法ANALYSE表，但也可以作用在列或整个数据库

```
ANALYSE;  --整个数据库,耗时很长,慎用
ANALYSE table1;  --表
ANALYSE table1(column1);  --列
```

# EXPLAIN

# Random

## 随机取一条

```sql
SELECT column1 FROM table1 ORDER BY random() LIMIT 1；
```
## 生成随机序列

```sql
UPDATE table1 SET bal=random()*1000000;  --用于生成随机金额
UPDATE table1 SET cust_id='0'||LPAD((random()*1e9)::int::varchar,9,'0');  --用于生成随机客户号,以0开头,后9位随机如果长度不足用0补全左侧
```

# 系统表

## sudo
pg_tables其实是视图,使用root权限(postgres)可以DROP.  
如果***不小心**删了可以按照原义建回来

```sql
DROP VIEW pg_tables;

SELECT * FROM pg_tables;

CREATE VIEW pg_tables AS
  SELECT n.nspname as schemaname,
         c.relname as tablename,
         pg_get_userbyid(c.relowner) as tableowner,
         t.spcname as tablespace,
         c.relhasindex as hasindexes,
         c.relhasrules as hasrules,
         c.relhastriggers as hastriggers
    FROM pg_class c
         LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
         LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
   WHERE c.relkind = 'r';
```

# Ref

[PostgreSQL](https://www.postgresql.org/)

[postgres-cn/pgdoc-cn-Github](https://github.com/postgres-cn/pgdoc-cn)

[GaussDB(DWS)-doc](https://support.huaweicloud.com/sqlreference-910-dws/dws_06_0001.html)