---
layout:     post
title:    Android-开机、Root到救砖
subtitle:   尽量从零开始吧
date:       2023-11-01
author:    DreamCat
header-img: img/post-bg-debug.png
catalog: true
tags:
- root
- Android
---

# 前言

<font color=red>如果你不是很明确的知道这步的操作是什么，以及出现问题如何解决，就不要这样做</font>

# Android简介

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/Android/Android_logo_2023.png)

<a href="https://developer.android.google.cn/?hl=zh-cn" target="_blank">Android Developers</a>

## Source Code

Android基于<a href="https://github.com/torvalds/linux" target="_blank">torvalds/linux</a>

<a href="https://source.android.google.cn/?hl=zh-cn" target="_blank">Android 开源项目</a>

## Version

Android按照甜点来命名，首字母按递增顺序排列

<a href="https://zh.wikipedia.org/wiki/Android版本列表" target="_blank">Android版本列表 - wikipedia.org</a>


| 代号 | 甜点名                           |   版本号    |    发行日期    | API等级 |
| ---- | :------------------------------- | :---------: | :------------: | :-----: |
| 1.0  |                                  |     1.0     | 2008年9月23日  |    1    |
| 1.1  |                                  |     1.1     |  2009年2月9日  |    2    |
| C    | Cupcake(纸杯蛋糕)                |     1.5     | 2009年4月27日  |    3    |
| D    | Donut(甜甜圈)                    |     1.6     | 2009年9月15日  |    4    |
| E    | Eclair(闪电泡芙)                 |  2.0 – 2.1  | 2009年10月26日 |  5 – 7  |
| F    | Froyo(冻酸奶)                    | 2.2 – 2.2.3 | 2010年5月20日  |    8    |
| G    | Gingerbread(姜饼)                | 2.3 – 2.3.7 | 2010年12月6日  | 9 – 10  |
| H    | Honeycomb(蜂巢)                  | 3.0 – 3.2.6 | 2011年2月22日  | 11 – 13 |
| I    | Ice Cream Sandwich(冰淇淋三明治) | 4.0 – 4.0.4 | 2011年10月18日 | 14 – 15 |
| J    | Jelly Bean(果冻豆)               | 4.1 – 4.3.1 |  2012年7月9日  | 16 – 18 |
| K    | KitKat(奇巧巧克力)               | 4.4 – 4.4.4 | 2013年10月31日 | 19 – 20 |
| L    | Lollipop(棒棒糖)                 | 5.0 – 5.1.1 | 2014年11月12日 | 21 – 22 |
| M    | Marshmallow(棉花糖)              | 6.0 – 6.0.1 | 2015年10月5日  |   23    |
| N    | Nougat(牛轧糖)                   | 7.0 – 7.1.2 | 2016年8月22日  | 24 – 25 |
| O    | Oreo(奥利奥)                     |  8.0 – 8.1  | 2017年8月21日  | 26 – 27 |
| P    | Pie(派)                          |      9      |  2018年8月6日  |   28    |
| Q    | Quince Tart(昆斯馅饼)            |     10      |  2019年9月3日  |   29    |
| R    | Red Velvet Cake(红丝绒蛋糕)      |     11      |  2020年9月8日  |   30    |
| S    | Snow Cone(刨冰)                  |  12 – 12L   | 2021年10月4日  | 31 – 32 |
| T    | Tiramisu(提拉米苏)               |     13      | 2022年8月15日  |   33    |
| U    | Upside Down Cake(翻转蛋糕)       |     14      | 2023年10月4日  |   34    |

Google在Android10开始取消了公开的甜点名，但仍内部使用，看到的这些是曝光的

## 更新机制

### Stable
### Beta
### Dev
### Canary
<font color=red>很不稳定，不建议小白使用</font>

为什么软件工程中"金丝雀"会用做版本名？

# 底层

## 架构

<a href="https://zh.wikipedia.org/wiki/Android#" target="_blank">Android-Wikipedia</a>

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/Android/The-Android-software-stack.png)

## SELinux

<a href="https://source.android.google.cn/docs/security/features/selinux?hl=zh-cn" target="_blank">Android 中的安全增强型 Linux</a>

SELinux(Security-Enhanced Linux)分为三种状态：

### Enforcing

强制模式（严格模式），默认状态
```
setenforce 1
```

### Permissive

宽容模式，一般仅调试使用
```
setenforce 0 #重启后变回Enforcing
```

### Disabled

禁用

<font color=red>极其不推荐把SELinux置为后两种状态！极为危险！</font>

## Bootloader

简称BL锁，想要获取root必须将其干掉

MIUI可在开机第一屏的屏幕正上方中间位置查看BL锁状态

<a href="https://www.coolapk.com/feed/32067805?shareKey=OTA0OTAyN2FkZTMxNjFiOTgzY2Y~&shareFrom=com.coolapk.market_11.4.6" target="_blank">浅谈底层固件安全性（强解BL，隐藏ID机等等背后的真相）</a>  
转载自酷安@Jpnx49Db0

以小米为例，说下解锁方法：
登录小米账号168小时（一周整）后，下载<a href="https://www.miui.com/unlock/download.html" target="_blank">miflash-unlock</a>申请解锁，
<font color=red>注意解锁会清除全部数据，一定先备份！</font>

## 分区

## AB分区

### 1.A-Only
<a href="https://source.android.google.cn/docs/core/ota/nonab?hl=zh-cn" target="_blank">非 A/B 系统更新</a>

### 2.A/B
<a href="https://source.android.google.cn/docs/core/ota/ab?hl=zh-cn" target="_blank">A/B（无缝）系统更新</a>

### 3.V-A/B
<a href="https://source.android.google.cn/docs/core/ota/virtual_ab?hl=zh-cn" target="_blank">虚拟 A/B 概览</a>

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/Android/current_slot.jpg)

# Root

## 获取root

曾经：各种一键root的app、SuperSU、Xposed

现在：MagiskSU、KernelSU

### Magisk
<a href="https://github.com/topjohnwu/Magisk" target="_blank">topjohnwu/Magisk-Github</a>  
名称来源于Magic Mask

#### 使用方法
该程序可按照文件名选择功能，非常强
*.zip是卡刷包（除uninstall.zip）
*.apk是应用程序安装包
uninstall.zip是卸载包

#### 作用原理
<a href="https://blog.csdn.net/qq_39441603/article/details/124996277" target="_blank">【Android安全】Android root原理及方案 | Magisk原理</a>

<a href="https://sspai.com/post/53043#!" target="_blank">每个 Android 玩家都不可错过的神器（一）：Magisk 初识与安装-少数派</a>

通过Systemless方式实现



### Xposed

#### Xposed
<a href="https://github.com/rovo89/Xposed" target="_blank">rovo89/Xposed-Github</a>

直接修改系统(System方式)，不安全

#### EdXposed
<a href="https://github.com/ElderDrivers/EdXposed" target="_blank">ElderDrivers/EdXposed-Github</a>

适配Android 8+、System方式改为Systemless。
作用域默认全局，很方便，但会造成一个后果：卡。

#### LSPosed
<a href="https://github.com/LSPosed/LSPosed" target="_blank">LSPosed/LSPosed-Github</a>

为了解决EdXposed的缺点而生，需选择每个模块的作用域

## sudo!

### 多系统

### 强制降级系统或app

### 超频

#### GPU
#### 屏幕刷新率

### 移除温控，提升充电功率

### 修改内核

更高性能或更省电

### 文件权限管理

### 修改开机动画

### 物理按键修改

### 扫描任意app内存并修改

修改微信性别和地址为空白
![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/Android/weixin_gender.jpg)

## 过root检测
~~我有root，用户app没有，优势在我~~

有些app检测出root后会导致功能受限、弹窗强制退出甚至直接闪退的情况，因此需要隐藏root

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/Android/bcm_root_check.jpg)

Magisk采用随机包名安装，并且配置排除列表，或刷入Shamiko模块，
建议弄到这步就够了，大多数应用已经可以正常使用了

想要最大程度隐藏的话，看这个：
<a href="https://www.coolapk.com/feed/48282566?shareKey=NjcxZDExYWI5NDhkNjU0MTE0MWU~&shareFrom=com.coolapk.market_13.3.6" target="_blank">Momo提示解决方法大全</a> 



# 调试

## ADB

Android Debug Bridge

<a href="https://developer.android.google.cn/studio/releases/platform-tools?hl=zh-cn" target="_blank">platform-tools下载</a>

配PATH：<a href="https://zhuanlan.zhihu.com/p/433391556" target="_blank">Win11怎么配置ADB环境变量 Win11配置ADB环境变量教程</a>

<a href="https://dreamingcats.github.io/2021/11/05/%E5%B8%B8%E7%94%A8adb%E6%8C%87%E4%BB%A4/" target="_blank">常用adb指令</a>


## 手机性能测试

最好用的软件是<a href="https://perfdog.qq.com" target="_blank">Perfdog</a>，鹅厂出品，内测时免费用了一年多，现在收费很贵了

<a href="https://perfdog.qq.com/case_detail/1286356" target="_blank">我测的一次原神</a>


# 刷机与救砖
~~砖了一次后，什么都会了~~

## 刷机方式

### 线刷
因使用数据线连接其他设备刷机而得名。
需要进入Fastboot模式(引导模式)刷机
```
fastboot flash 分区名称 镜像文件名.img
```
例：刷入boot分区 
```
fastboot flash boot boot.img
```

### 卡刷
远古版本中，在SD卡中刷机而得名，现已在内部存储中刷机。刷机包的扩展名为zip
需要进入Recovery模式(REC,恢复模式)刷机


### sideload
使用线刷的方式在其他设备中刷卡刷包

```
adb sideload 卡刷包.zip
```



## ROM选择

### 官方

### 官改

### 原生

AOSP

### 类原生

一个例子：
```
#EvolutionX #Alioth #U #unofficial #Aliothin #Rom #A14,
EvolutionX-EOL Chaitanya Edition v8.0| Unofficial 
Last build of  "@Chaitanyakm"
Updated: 30/10/23

▪️ Download - Index (https://dev.chaitanya.workers.dev/0:/evolution_alioth-ota-up1a.231005.007.a1-10282159-community-unsigned.zip?a=view) | Drive (https://drive.google.com/uc?id=1bwEd87SyfqH7Z8-YpnWyoWMYZU27i-UN&export=download) 
▪️Support Group  (https://t.me/chaitanyabuilds)
▪️Screenshot (https://t.me/chaitanyabuilds/21652?single) 

 Notes:
    • Initial A14 build and EOL build
    • Leica included 
    • Need to be on latest MIUI 14
         Regional FW.
    • Use a14 supported recovery 

By @Chaitanyakm
Follow @PocoF3GlobalUpdates
Join @PocoF3GlobalOfficial
```

### 移植

移植其他厂商的ROM，或相同厂商最新机型的ROM来用

一个例子：
<a href="https://www.coolapk.com/feed/50601031?shareKey=OWM0MTM0MWQzNTdiNjU0MWI5M2I~&shareFrom=com.coolapk.market_13.3.6" target="_blank">HyperOS移植包测试发布免费下载</a>

## 救砖

"砖"指的是手机无法正常使用，就像砖头一样，英文为"brick",作动词用

### Magisk模块问题

disable有问题的模块，
如果不确定哪个有问题，或者是模块冲突，禁用全部模块

### Magisk本身问题

刷卸载包uninstall.zip

### ROM问题

确定ROM本身是否有问题，
双清重刷

### 某分区问题
把修改前备份的分区刷回来

解锁bl后，只要Fastboot(位于hboot分区)还在问题就不大，如果连fastboot都进不去，
9008(高通)、SPflash(联发科)还可以再尝试下(一般只有售后有这两个的权限)

未解锁bl的情况下变砖建议直接售后

### systemui问题

adb卸载作用域为systemui的模块