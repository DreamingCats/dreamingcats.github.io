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

本文最后更新于2024-11-12

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

```cpp
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

# 数据类型

## 数值

`numeric(a,b)`和`decimal(a,b)`完全等价(a为小数点前位数,b为小数点后位数)

## 字符串

`varying(n)`和`varchar(n)`完全等价(n为长度)  
varchar不写长度等价于text,一个单元格(一条数据中的一个字段)最大能存储1GB数据

## CAST

### 显式转换(强制转换)

写在代码中的
`CAST(column1 AS varchar)`
和
`column1::varchar`
完全等价，推荐使用后者，因为打字少

### 隐式转换(自动转换)

SQL语句自动转换的

```sql
--数值向decimal高精度转换
SELECT 1+0.1+0.2;

--向text转换
SELECT 'a'||1;
SELECT 1||2;  --Postgres报错,GaussDB(DWS)会转成'12'

--向时间戳转换
SELECT current_timestamp -current_date;
```


# JOIN

默认的`JOIN`为`INNER JOIN`

```sql
-- 创建 employees 表
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    department_id INT
);

-- 创建 departments 表
DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    department_name VARCHAR(50)
);

-- 插入示例数据
INSERT INTO employees (name, department_id) VALUES
('Alice', 1),
('Bob', 2),
('Charlie', NULL);

INSERT INTO departments (id, department_name) VALUES
(1, 'HR'),
(2, 'Finance');


-- 使用 INNER JOIN
SELECT employees.name, departments.department_name
FROM employees
INNER JOIN departments ON employees.department_id = departments.id;

-- 使用 LEFT JOIN
SELECT employees.name, departments.department_name
FROM employees
LEFT JOIN departments ON employees.department_id = departments.id;

-- 使用 RIGHT JOIN
SELECT employees.name, departments.department_name
FROM employees
RIGHT JOIN departments ON employees.department_id = departments.id;

-- 使用默认 JOIN（不指定类型）
SELECT employees.name, departments.department_name
FROM employees
JOIN departments ON employees.department_id = departments.id;

```


# bool

布尔值只能为true/false/null中的一个

## 判断
以下sql，结果为true的是，false的是，null的是，~~报错的是，没有返回值的是~~

```sql
SELECT 2::boolean AS A;  
```
<details>
<summary>A答案</summary>
A true,正整数返回true很好理解
</details>

```
SELECT (-1)::boolean AS B;  
```
<details>
<summary>B答案</summary>
B 强转boolean时，非0全是true  
</details>

```sql
SELECT (1.1)::boolean AS C;
```
<details>
<summary>C答案</summary>
C 报错，转boolean只支持整数
```sql
SELECT (1.0)::boolean AS C;  --1.0也报错,因为是通过numeric强转的
```
</details>

```sql
SELECT 0.1+0.2=0.3 AS D;
```
<details>
<summary>D答案</summary>
D true,因为默认以decimal存储，结果并不是float的0.30000000000000004
</details>


```sql
SELECT 'a'=1 AS E;  
```
<details>
<summary>E答案</summary>
E 使用=比较时尝试将'a'转为int，该语句实际为SELECT 'a'::int=1 AS E,报错  
因此,如果WHERE或LEFT JOIN使用码值,一定要把数字也加上单引号,避免这样的报错
</details>

```sql
SELECT null=null AS F;  
```
<details>
<summary>F答案</summary>
F 两个为止无法比较，应使用`SELECT null is null`
</details>

```sql
SELECT ' 1 '=1 AS G;  
```
<details>
<summary>G答案</summary>
G 尝试将' 1 '转换为int,自动去掉了前后的空格

```sql
SELECT ''=0 AS G0;  
```
Postgres报错(`''::int=0`也报错),GaussDB(DWS)会把空串或任意长度空格转为0
</details>

```
SELECT not null AS I;  
```
<details>
<summary>I答案</summary>
I 对未知取否还是未知
</details>

```sql
SELECT 'tr'::boolean AS J;  
```
<details>
<summary>J答案</summary>
J t、tr、tru、true、y、ye、yes无论大小写都能转换为true,也可以去前后的空格

```sql
SELECT ' yE '::boolean AS J; 
```
false同理 
</details>

```
SELECT null/0 AS K;  
```
<details>
<summary>I答案</summary>
K 返回null,实际未执行除法
</details>


## 存储

```sql
drop table if exists test_bool_length;
create table test_bool_length
(
test_true varchar(1),
test_false varchar(1)
);
insert into test_bool_length
(
test_true,
test_false
)
select 
1::boolean as test_true,  --换成'yes','no'也会转为'true','false'
0::boolean as test_false
;

select 
test_true::varchar,
length(test_true),
test_false::varchar,
length(test_false)
from test_bool_length
;
```

<details>
<summary>长度说明</summary>
true实际上以'true' varchar(4)存储,
false是varchar(5)
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

### NOT

| expr1 | NOT expr1 |
| ----- | --------- |
| TRUE  | FALSE     |
| FALSE | TRUE      |
| NULL  | NULL      |

```sql
--我需要保留以下结果
SELECT * 
FROM test_table 
WHERE a=1 AND b=2 AND c=3;

--不满足这些条件的全部删除,只需前面加个NOT并括起来就行了
DELETE FROM test_table 
WHERE NOT (a=1 AND b=2 AND c=3);

--等价于
DELETE FROM test_table 
WHERE (a!=1 OR b !=2 OR c!=3);
```

### 优先级

```sql
SELECT true AND true OR false AND false;  --该语句按什么顺序执行?返回的是什么?
SELECT ((true AND true) OR false) AND false;  --按顺序从左向右?
SELECT (true AND true) OR (false AND false);  --先AND再OR?
```

可以看到AND的优先级更高(先运算)。  
因此写WHERE条件时，强烈建议<font color=red>有OR就用括号括起来</font>，防止范围扩大。  
全是AND或全是OR则无所谓(满足交换律)  

优先级:`NOT>AND>OR`

## null

表示unknown,
你想要它是什么它就是什么,
个人认为含义不应为‘空’，而是‘黑洞’

# WHERE

## 返回结果

WHERE条件整体返回的是一个布尔值，
作用与每条该值仅在该条为true时返回，
false或null时不会返回

```sql
SELECT null AS H WHERE null ;
```
<details>
<summary>H答案</summary>
H WHERE条件为false或null时不会返回
</details>

```sql
SELECT null/0 AS I;
```
<details>
<summary>I答案</summary>
I 不报错,返回null
</details>

## 1=1

不用管网上说的`WHERE 1=1`增加耗时，放心写，**相信优化器**，不信你可以在后面加100个` and 1=1`试试

```sql
--加上100个试试
SELECT 'SELECT ''测试耗时'' WHERE 1=1 '||string_agg('AND 1=1', ' ') AS result
FROM generate_series(1, 100);
```

如果你连=都懒得写就直接写`WHERE 1`
(GaussDB(DWS),原生Postgres并不支持)

## 短路

```sql
SELECT (0=1 AND (1/0)=1) AS K;
```
<details>
<summary>K答案</summary>
K 返回false,因为第一个`0=1`结果为false导致WHERE短路,执行到`false AND`就退出了,不会执行后面的`(1/0)=1`,如果写成`SELECT ((1/0)=1 AND 0=1) AS K2;`就报错了.

同理

```sql
SELECT (1=1 OR (1/0)=1) AS K3;

SELECT 'test_short_circuit' 
WHERE (1=1 OR (1/0)=1);
```
结果为true.

</details>

写WHERE条件时,建议把重要的条件放前面,能减少判断次数.

[SQL常见100面试题解析-第12条](https://mp.weixin.qq.com/s/dKe8BEJU8O1XnTO61wrydw)


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
    cust_id, dt DESC;

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
('HKD')   -- 港币
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

# ANALYSE

ANALYSE和ANALYZE完全等价  
正常用法ANALYSE表，但也可以作用在列或整个数据库

```sql
ANALYSE;  --整个数据库,耗时很长,慎用
ANALYSE table1;  --表
ANALYSE table1(column1);  --列
```

# 分布及压缩

[行列存压缩-GaussDB(DWS)](https://support.huaweicloud.com/tg-dws/dws_16_0164.html)

以下是一个GaussDB(DWS)表的压缩数据供参考:  
列存表,约1000万条数据，包含客户号、日期、金额、备注等字段

| 压缩级别 | 大小(GB) | 压缩比(与上一级相比,%) | 压缩比(与未压缩相比,%) |
| -------- | -------- | ---------------------- | ---------------------- |
| no       | 43.44    | 100.00                 | 100.00                 |
| low      | 7.07     | 16.28                  | 16.28                  |
| middle   | 3.38     | 47.81                  | 7.78                   |
| high     | 2.99     | 88.46                  | 6.88                   |

[ALTER TABLE_数据仓库服务 GaussDB(DWS)](https://support.huaweicloud.com/sqlreference-dws/dws_06_0142.html)

不重建表直接修改压缩级别

```sql
ALTER TABLE compressed_table
SET(
  compression=high
);
```
>修改表的压缩特性。表压缩特性的改变只会影响后续批量插入的数据的存储方式，对已有数据的存储毫无影响。也就是说，表压缩特性的修改会导致该表中同时存在着已压缩和未压缩的数据。

不重建表直接修改分布
```sql
ALTER TABLE hash_table
distribute by roundrobin;  --hash(hash_column)
```
>修改表的分布方式，在修改表分布信息的同时会将表数据在物理上按新分布方式重新分布，修改完成后建议对被修改表执行ANALYZE，以便收集全新的统计信息。  
>1. 本操作属于重大变更操作，涉及表分布信息的修改以及数据的物理重分布，修改过程中会阻塞业务，修改完成后原有业务的执行计划会发生变化，请按照正规变更流程进行。  
>2. 本操作属于资源密集操作，针对大表的分布方式修改，建议在计算和存储资源充裕情况下进行，保证整个集群和原表所在表空间有足够的剩余空间能存储一张与原表同等大小且按照新分布方式进行分布的表。

# Random

## 随机取一条

```sql
SELECT column1 FROM table1 ORDER BY random() LIMIT 1;
```

## 生成随机序列

```sql
UPDATE table1 SET bal=random()*1000000;  --用于生成随机金额

UPDATE table1 SET cust_id='0'||LPAD((random()*1e9)::int::varchar,9,'0');  --用于生成随机客户号,以0开头,后9位随机如果长度不足用0补全左侧

UPDATE table1 SET flow_id=UPPER(MD5(random()));  --用于生成流程号,大小写不敏感时使用
```

## 随机生成YYYYMMDD日期

```sql
DROP TABLE IF EXISTS test_random_date;
CREATE TABLE test_random_date(
  dt varchar(10),
  insert_timestamp timestamp(0) without time zone
);

--插入生成数据
INSERT INTO test_random_date
WITH random_date AS(
  SELECT 
    to_char(current_date - (interval '10 years')*random() ,'YYYYMMDD') AS dt  --生成随机每日
    --to_char((date_trunc('month',(current_date - (interval '10 years')*random() )) + interval '1 month' - interval '1 day'),'YYYYMMDD') AS dt --生成随机月末
    --to_char(current_date - (interval '10 years')*random() ,'YYYY')||'1231' AS dt --生成随机年末
  FROM generate_series(1,${num}) --生成数量,生成较慢,不要写太大
)
SELECT 
  dt AS dt,
  current_timestamp AS insert_timestamp
FROM random_date;

--查看生成结果
SELECT dt,count(*)
FROM test_random_date
GROUP BY dt
ORDER BY dt ASC;
```

```sql
--生成随机省份信息,这么写可以确保每一条都是随机出来的
UPDATE users
SET province = CASE FLOOR(RANDOM() * 34) --FLOOR向下取整
    WHEN 0 THEN '北京'
    WHEN 1 THEN '天津'
    WHEN 2 THEN '河北'
    WHEN 3 THEN '山西'
    WHEN 4 THEN '内蒙古'
    WHEN 5 THEN '辽宁'
    WHEN 6 THEN '吉林'
    WHEN 7 THEN '黑龙江'
    WHEN 8 THEN '上海'
    WHEN 9 THEN '江苏'
    WHEN 10 THEN '浙江'
    WHEN 11 THEN '安徽'
    WHEN 12 THEN '福建'
    WHEN 13 THEN '江西'
    WHEN 14 THEN '山东'
    WHEN 15 THEN '河南'
    WHEN 16 THEN '湖北'
    WHEN 17 THEN '湖南'
    WHEN 18 THEN '广东'
    WHEN 19 THEN '广西'
    WHEN 20 THEN '海南'
    WHEN 21 THEN '重庆'
    WHEN 22 THEN '四川'
    WHEN 23 THEN '贵州'
    WHEN 24 THEN '云南'
    WHEN 25 THEN '西藏'
    WHEN 26 THEN '陕西'
    WHEN 27 THEN '甘肃'
    WHEN 28 THEN '青海'
    WHEN 29 THEN '宁夏'
    WHEN 30 THEN '新疆'
    WHEN 31 THEN '香港'
    WHEN 32 THEN '澳门'
    WHEN 33 THEN '台湾'
END;
```

# 批量生成

```sql
--批量生成YYYYMMDD日期序列
WITH T1 AS(
  SELECT to_char(dt,'YYYYMMDD') AS date_series
  FROM generate_series(
    date('${begin_date}'),  --开始时间
    date('${end_date}'),  --结束时间
    '1 day'  --间隔
  ) AS dt
)
SELECT T1.date_series
FROM T1
  WHERE extract(day from date(date_series)+1) = 1  --只要月末
  --WHERE to_char(date_series,'DD') = '01'  --只要每月1日
  --WHERE to_char(date_series,'MMDD') = '1231' --只要年末
```

# 系统表

## 系统表信息函数

[GaussDB(DWS)系统表信息函数](https://support.huaweicloud.com/sqlreference-dws/dws_06_0341.html)

## 快速获取表字段名

```sql
SELECT cloumn_name,*
FROM information_schema.columns
WHERE 1=1
  AND table_schema='your_schema'
  AND table_name='your_table_name'
```

查出来默认就是建表顺序

## sudo
pg_tables其实是视图,使用root权限(postgres)可以DROP.  
如果**不小心**删了可以按照原义建回来

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

