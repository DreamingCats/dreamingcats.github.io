---
layout:     post
title:      Postgresql中一些你可能不知道的用法
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
  用中文字段名怎么你了 varchar(100),
  🥰 varchar(100),
  【，；：“”】 varchar(100) --中文标点
);

SELECT 用中文字段名怎么你了,🥰,【，；：“”】 FROM 用中文表名怎么你了;
```

长度限制  
源码在
[./src/include/pg_config_manual.h NAMEDATALEN](https://github.com/postgres/postgres/blob/master/src/include/pg_config_manual.h)
这是人为规定的,你也可以改成100、128等  
预留1Byte用于字符串的结尾字符 \0  
```C
/*
 * Maximum length for identifiers (e.g. table names, column names,
 * function names).  Names actually are limited to one fewer byte than this,
 * because the length must include a trailing zero byte.
 *
 * Changing this requires an initdb.
 */
#define NAMEDATALEN 64
```
```sql
SELECT length('aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggggggggg'); --看下长度
DROP TABLE IF EXISTS aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggggggggg;  --每个字母有10个
CREATE TABLE aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggggggggg
(
    iwanttofindoutthemaxlengthofacloumniwanttofindoutthemaxlengthofacloumn varchar(70) --一句35Byte
);

--看下存储在数据库中的到底是什么
SELECT pg_get_tabledef('aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggggggggg');

--实际上查的都是同一个表.因此通过结尾部分区分表,一定要注意长度限制
SELECT * from aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggg_temp1;
SELECT * from aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggg_temp2;
```
```log
OK. No rows were affected
SQLWarning:
1) SQL State: 42622 --- identifier "aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffgggggggggg" will be truncated to "aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeffffffffffggg"
2) SQL State: 42622 --- identifier "iwanttofindoutthemaxlengthofacloumniwanttofindoutthemaxlengthofacloumn" will be truncated to "iwanttofindoutthemaxlengthofacloumniwanttofindoutthemaxlengthof"
```
# SELECT

## DISTINCT

```sql
--取客户最新日期的余额(每个客户只取一条)
SELECT DISTINCT ON (cust_id) 
    cust_id, 
    dt, 
    bal
FROM 
    table1
ORDER BY 
    cust, dt DESC;

--等价于
SELECT cust_id, dt, bal
FROM (
    SELECT 
        cust_id, 
        dt, 
        bal, 
        ROW_NUMBER() OVER (
          PARTITION BY cust_id 
          ORDER BY dt DESC) AS rn
    FROM 
        table1
) AS t
WHERE rn = 1;
```


# ORDER BY

## 规则

默认的排序方式为按照ASCII增序排列。
''(空串)小于任何一个字符串,null大于任何一个字符串

因此，在对数据进行降序排列时，可以加上`NULLS LAST`,把null放在最后

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

INSERT INTO people_name_table (name) VALUES 
('张三'), 
('李四'), 
('王五'),
('艾AA'),
('李白');

--人名按照汉语拼音A-Z升序排序
SELECT * FROM people_name_table
ORDER BY name COLLATE "zh_CN.utf8"; --注意是双引号,单引号报错 --如果没有可以换成这个 zh-Hans-CN-x-icu  ICU（International Components for Unicode）

--查看支持简体中文的排序方式
SELECT * FROM pg_collation
WHERE (
collname ilike '%zh-hans%'
or collname ilike '%cn%'
);

```

## 去重后排序

```sql
SELECT a,b FROM table1 ORDER BY c ASC; --这么写可以
SELECT DISTINCT a,b FROM table1 ORDER BY c ASC; --这么写报错
SELECT DISTINCT a,b,c FROM table1 ORDER BY c ASC; --如果去重,必须把排序字段SELECT出来
```

# CAST

## 显式转换（强制转换）

写在代码中的
```sql
CAST(column1 AS varchar)
```
和
```sql
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

## 真值表

### AND

| expr1 AND expr2 |  **TRUE**  | **FALSE** | **NULL**  |
|---------------|--------|-------|-------|
| **TRUE**      | TRUE   | FALSE | NULL  |
| **FALSE**     | FALSE  | FALSE |<font color='red'>FALSE</font>|
| **NULL**      | NULL   |<font color='red'>FALSE</font>| NULL  |

当 NULL 参与 AND 运算时，结果为 NULL，除非另一边的表达式是 FALSE，因为在 AND 操作中，只要有一方为 FALSE，结果就会是 FALSE。

### OR

| expr1 OR expr2 | **TRUE** | **FALSE**                     | **NULL**                      |
| -------------- | -------- | ----------------------------- | ----------------------------- |
| **TRUE**       | TRUE     | TRUE                          | TRUE                          |
| **FALSE**      | TRUE     | FALSE                         | <font color='red'>NULL</font> |
| **NULL**       | TRUE     | <font color='red'>NULL</font> | NULL                          |

只有当两个表达式都为 FALSE 时，结果才是 FALSE。如果任一表达式为 TRUE，结果为 TRUE。如果有 NULL 存在，结果则取决于另一方的值。

## null

表示unknown,
你想要它是什么它就是什么,
个人认为含义不应为‘空’，而是‘黑洞’

# WHERE

WHERE条件整体返回的是一个布尔值，
作用与每条该值仅在该条为true时返回，
false或null时不会返回

不用管网上说的`WHERE 1=1`增加耗时，放心写，**相信优化器**，不信你可以在后面加100个` and 1=1`试试
```sql
SELECT 'SELECT ''测试耗时'' WHERE 1 '||string_agg('AND 1=1', ' ') AS result
FROM generate_series(1, 100);
```
如果你连=都懒得写就直接写`WHERE 1`
(GaussDB,原生Postgres并不支持)

# ANALYSE

ANALYSE和ANALYZE完全等价  
正常用法ANALYSE表，但也可以作用在列或整个数据库

```sql
ANALYSE;  --整个数据库,耗时很长,慎用
ANALYSE table1;  --表
ANALYSE table1(column1);  --列
```

# EXPLAIN

# Random

## 随机取一条

```sql
SELECT column1 FROM table1 ORDER BY random() LIMIT 1;
```
## 生成随机序列

```sql
UPDATE table1 SET bal=random()*1000000;  --用于生成随机金额
UPDATE table1 SET cust_id='0'||LPAD((random()*1e9)::int::varchar,9,'0');  --用于生成随机客户号,以0开头,后9位随机如果长度不足用0补全左侧
```

# 系统表

## 系统表信息函数

[GaussDB系统表信息函数](https://support.huaweicloud.com/sqlreference-dws/dws_06_0341.html)

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

[ChatGPT](https://chatgpt.com/)



本博客的所有内容除特别声明外，均采用 [CC BY 4.0 许可协议](https://creativecommons.org/licenses/by/4.0/)。转载请注明[出处](https://dreamingcats.github.io/2024/07/17/Postgresql%E4%B8%AD%E4%B8%80%E4%BA%9B%E4%BD%A0%E5%8F%AF%E8%83%BD%E4%B8%8D%E7%9F%A5%E9%81%93%E7%9A%84%E7%94%A8%E6%B3%95/)。
