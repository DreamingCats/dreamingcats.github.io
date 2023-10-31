---
layout:     post
title:   如何将非Steam的图片上传到Steam云？
subtitle:   你问我为啥要这么折腾?
date:       2021-11-06
author:    DreamCat
header-img: img/post-bg-debug.png
catalog: true
tags:
    - 游戏
    - 云盘
---

最近鸡3上Steam了，我想把原来的截图导进来,所以有了这个教程。


我查到了这个：  
[教你如何将非STEAM的图片上传至STEAM云](https://www.bilibili.com/read/cv5632717/)

1.首先你需要打开游戏,按<font color=red>F12</font>截一张图,然后退出,这时会弹出一个窗口,点击<font color=red>在硬盘中查看</font>

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/SteamPicture/Step1.png)

2.然后导入你要上传的<font color=red>JPG</font>图片 ，复制到\...\screenshots下
注：PNG等其它格式不行，不要放在thumbnails下

3.然后将这些图片全部复制一份，依然放到本目录下，得到xxx - Copy.jpg

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/SteamPicture/Step2.png)

4.将这些图片批量重命名，推荐使用[Everything](https://www.voidtools.com/zh-cn/)

在安装时,选择<font color=red>将Everything集成到右键</font>

然后在这个文件夹空白处,右键打开Everything

Ctrl+A全选，然后按<font color=red>F2</font>

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/SteamPicture/Step3.png)

原文件格式(注意-之间有空格)：
```
%1 - Copy.jpg
```

新文件格式：
```
%1_vr.jpg
```

点击确定

不更改图片名，更改配置文件的方法：

<a href="https://www.bilibili.com/read/cv952991/" target="_blank">教你如何在STEAM云中上传非steam截图</a>

5.<font color=red>重启Steam</font>

再回到你要上传截图的游戏,点击<font color=red>管理我的%d张截图</font>

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/SteamPicture/Step4.png)

全选,点击上传

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/SteamPicture/Step5.png)

直连应该可以，不行就挂加速器

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/SteamPicture/Upload.png)

6.全部上传成功后，本地图片就可以删了，注意<font color=red>不要</font>顺手把在Steam云删除勾上，教程结束

![](https://github.com/DreamingCats/dreamingcats.github.io/raw/main/img/SteamPicture/Step6.png)

<font color="red">
经测试，图片扩展名必须为jpg，

可以上传中文文件名的图片
</font>

注：这个教程在2022年7月8日依然有效，如果出错了建议回去看看<font color=red>红字部分</font>




