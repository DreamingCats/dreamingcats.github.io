---
layout:     post
title:   Microsoft E5和OneDrive使用指南
subtitle:   巨硬是我大哥！
date:       2022-01-19
author:    DreamCat
header-img: img/post-bg-debug.png
catalog: true
tags:
- 云盘
- 薅羊毛
---

# 送E5子账号

薅了个巨硬E5的羊毛，免费送15个E5的子账号，后缀是@earthol.onmicrosoft.com，要的带上你想要的英文用户名和邮箱私聊我
已刷API，之前续订过一次，应该不会翻车

包含：全套正版Office+5T的OneDrive

# 分享盘

## 效果展示

<a href="https://service-ibxnmgrp-1306118998.cd.apigw.tencentcs.com/release/OneManager" target="_blank">网盘云函数链接</a>

<a href="http://onemanager.httpp.xyz" target="_blank">301重定向到我的域名</a>

<a href="https://github.com/qkqpttgf/OneManager-php" target="_blank">OneManager-GitHub</a>

<a href="https://github.com/reruin/sharelist" target="_blank">ShareList-GitHub</a>

## 教程

使用腾讯云函数搭建
<a href="https://www.nbmao.com/archives/4076/comment-page-1" target="_blank">腾讯云无服务器云函数搭建onedrive网盘教程</a>

<a href="http://t.zoukankan.com/HGNET-p-14589759.html" target="_blank">阿里云盘+OneManager+Heroku+CFWorkers实现阿里云盘网络挂载</a>

可以不用Heroku，只不过云函数链接比较长，可以像我这样放到博客的右上角和友链里

# 能干什么？

除了上面的，还可以搭个分享盘什么的

关于到底能不能放NSFW，我去Google查了一下，看到几个官方回复

<a href="https://www.microsoft.com/en-us/servicesagreement/" target="_blank">巨硬的用户协议</a>

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/E5/EULA.png)

官方回复：

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/E5/official_answer.png)

个人推测会扫盘校验md5？想再加层保险的话就加密压缩包吧。

综上，个人看法是你可以存R18，但不要公开分享炼铜，私人使用没问题。

~~真要ghs还得TG~~

尽管如此，还是建议做好本地备份！买个机械移动硬盘当小姐姐~~们~~的大别墅。

# 搭建方法

[免费申请office E5开发者订阅，附无限续期+私人网盘教程](https://blog.devyi.com/archives/388/)

[查看E5到期时间](https://developer.microsoft.com/zh-cn/microsoft-365/profile)
注意要用申请E5的邮箱登录，是QQ，163什么的，不是onmicrosoft的

# 关闭双重认证

这玩意是默认开启的，需要使用微软验证器。

可把👴害惨了，非管理员账户可以让管理员给你强制重置，管理员就GG了

此外，为避免翻车，尽量在验证方式中添加邮箱和电话！

我已经给闭了，网上搜不到，自己找了半天

<a href="https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Properties" target="_blank">AAD属性</a>

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/E5/AAD.png)

# 续订

刚申请的E5有效期只有90天，续订的方法是刷API。

我调用了两个API，一个是那个自动刷API的网站，另一个是OneManager。

2021年12月更新

好耶！E5成功续订了！

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/E5/renew.png)

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/E5/dayleft.png)

# 文件迁移

## 下载又重新上传

官方让你这么做的。

实在是想不明白，为什么巨硬不做转存功能

## 使用Mover.io

<a href="https://mover.io" target="_blank">mover.io</a>

该网站被巨硬收购了，可以放心使用

要同时登录源云盘和目的云盘

不过，只有开放了api的OneDrive才能使用。

没有api怎么办？看这篇

<a href="https://www.onesrc.cn/p/how-to-call-api-for-onedrive-account-without-administrator.html" target="_blank">onedrive 无管理员账户如何调用 api</a>

## 使用Rclone

<a href="https://rclone.org/" target="_blank">rclone</a>

# 安全性

管理员可以改密码也可以直接删除用户，但用户可以在自己的设置里把管理员踢出去。

巨硬官方的回复：

<a href="https://answers.microsoft.com/zh-hans/msoffice/forum/all/%E4%BD%BF%E7%94%A8%E5%A4%A7%E5%AD%A6%E7%9A%84/7491b2ac-3965-4360-af01-48b451ce71bb" target="_blank">使用大学的邮箱，我上传到onedrive的文件会被管理员查看到吗？</a>

建议OneDrive当做同步盘使用，即使炸了不登录本地的数据也不会丢。
