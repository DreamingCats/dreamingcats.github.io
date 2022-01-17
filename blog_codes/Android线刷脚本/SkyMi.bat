@echo off
@mode con lines=30 cols=100&color 0F
for /r "bins" %%a in (*.name) do (
findstr /i "_VENUS_" "%%~a" >nul 2>nul && set "model=M11" && set "device=venus"
findstr /i "_ODIN_" "%%~a" >nul 2>nul && set "model=MIX4" && set "device=odin"
findstr /i "_STAR_" "%%~a" >nul 2>nul && set "model=Mi11Ultra" && set "device=star" && type nul>bins\STAR
findstr /i "_ALIOTH_" "%%~a" >nul 2>nul && set "model=Redmi_K40" && set "device=alioth"
findstr /i "_HAYDN_" "%%~a" >nul 2>nul && set "model=Redmi_K40Pro" && set "device=haydn"
findstr /i "_THYME_" "%%~a" >nul 2>nul && set "model=MI10S" && set "device=thyme"
findstr /i "_ELISH_" "%%~a" >nul 2>nul && set "model=MI5PRO_WIFI" && set "device=elish"
findstr /i "VENUSPRE" "%%~a" >nul 2>nul && set "model=M11" && set "device=venus"
findstr /i "ODINPRE" "%%~a" >nul 2>nul && set "model=MIX4" && set "device=odin"
findstr /i "STARPRE" "%%~a" >nul 2>nul && set "model=Mi11Ultra" && set "device=star" && type nul>bins\STAR
findstr /i "ALIOTHPRE" "%%~a" >nul 2>nul && set "model=Redmi_K40" && set "device=alioth"
findstr /i "HAYDNPRE" "%%~a" >nul 2>nul && set "model=Redmi_K40Pro" && set "device=haydn"
findstr /i "THYMEPRE" "%%~a" >nul 2>nul && set "model=MI10S" && set "device=thyme"
findstr /i "ELISHPRE" "%%~a" >nul 2>nul && set "model=MI5PRO_WIFI" && set "device=elish"
findstr /i "10.0.zip" "%%~a" >nul 2>nul && set "sdk=10.0"
findstr /i "11.0.zip" "%%~a" >nul 2>nul && set "sdk=11.0"
findstr /i "12.0.zip" "%%~a" >nul 2>nul && set "sdk=12.0"
)
for /f "tokens=1* delims= " %%a in (bins\version.txt) do ( 
set "build=%%a" 
)
title "%model% Android Tool-SkyMi ROM [v1.2.5] [64bits]"
set app_description=MIUI版本：%build%        安卓版本：%sdk%    
set cecho=bins\cecho.exe
:HOME
cls
set key=""
echo.
echo.
echo.
echo         ======================================================================
%cecho% 	-{06}%model% ROM Builder For MIUI{#} 		           {03}[by SkyMi]{#}
echo.
echo.
%cecho% 	-{4f}%app_description%{#}
echo.
echo         ======================================================================
echo.
echo.        -[01]-^>^> 一键制作卡刷包
echo.
echo.        -[02]-^>^> 线刷升级手机
echo.
echo.        -[03]-^>^> 线刷升级手机(双清)
echo.
echo.        -[04]-^>^> 退出
echo.
echo         ======================================================================
echo.
echo.
set /p key=-^-^-^-^-^> 请选择操作:
if "%key%"=="1" goto GO_ZIPROM
if "%key%"=="01" goto GO_ZIPROM
if "%key%"=="2" goto GO_USBFLASH
if "%key%"=="02" goto GO_USBFLASH
if "%key%"=="3" goto GO_USBFLASH2
if "%key%"=="03" goto GO_USBFLASH2
if "%key%"=="4" exit
if "%key%"=="04" exit

:GO_ZIPROM
if exist "bins\PAYEROFS" (
echo.
echo.===由于MIX4为erofs格式,MIX4暂时不支持卡刷包制作
echo.
timeout /t 6
goto HOME
)
cls
if not exist "out" md out >nul 2>nul
move bins\META-INF out\ >nul 2>nul
move bins\dynamic_partitions_op_list out\ >nul 2>nul
move images\boot.img out\ >nul 2>nul
move images\vendor_boot.img out\ >nul 2>nul
move images\super.img out\ >nul 2>nul
cls
echo.
echo.===正在分解super.img
echo.
bins\simg2img.exe out\super.img out\super.img.ext4 >nul 2>nul
bins\lpunpack.exe out\super.img.ext4 out >nul 2>nul
move out\super.img bins\ >nul 2>nul
del out\super.img.ext4 >nul 2>nul
del out\odm_b.img >nul 2>nul
del out\system_b.img >nul 2>nul
del out\vendor_b.img >nul 2>nul
del out\product_b.img >nul 2>nul
del out\system_ext_b.img >nul 2>nul
cls
echo.
echo.===正在转换镜像格式
echo.
bins\img2simg.exe out\odm_a.img out\odm.img >nul 2>nul
bins\img2simg.exe out\system_a.img out\system.img >nul 2>nul
bins\img2simg.exe out\vendor_a.img out\vendor.img >nul 2>nul
bins\img2simg.exe out\product_a.img out\product.img >nul 2>nul
bins\img2simg.exe out\system_ext_a.img out\system_ext.img >nul 2>nul
bins\img2simg.exe out\odm.img out\odm_new.img
del out\odm_a.img >nul 2>nul
del out\system_a.img >nul 2>nul
del out\vendor_a.img >nul 2>nul
del out\product_a.img >nul 2>nul
del out\system_ext_a.img >nul 2>nul
del out\odm.img >nul 2>nul
cls
echo.
echo.===正在将system.img转换为system.new.dat
echo.
bins\img2sdat.exe out\system.img -o out -v 4
del out\system.img >nul 2>nul
echo.
echo.===正在将vendor.img转换为vendor.new.dat
echo.
bins\img2sdat.exe out\vendor.img -o out -v 4 -p vendor
del out\vendor.img >nul 2>nul
echo.
echo.===正在将product.img转换为product.new.dat
echo.
bins\img2sdat.exe out\product.img -o out -v 4 -p product
del out\product.img >nul 2>nul
echo.
echo.===正在将system_ext.img转换为system_ext.new.dat
echo.
bins\img2sdat.exe out\system_ext.img -o out -v 4 -p system_ext
del out\system_ext.img >nul 2>nul
echo.
echo.===正在将odm.img转换为odm.new.dat
echo.
bins\img2sdat.exe out\odm_new.img -o out -v 4 -p odm
del /s /q out\odm_new.img >nul 2>nul
echo.
echo.  ------------------------------dat格式转换完成------------------------------
echo.
cls
echo.
echo.===正在压缩system.new.dat.br
echo.
bins\brotli.exe -j -q 5 out\system.new.dat
echo.
echo.===正在压缩vendor.new.dat.br
echo.
bins\brotli.exe -j -q 5 out\vendor.new.dat
echo.
echo.===正在压缩product.new.dat.br
echo.
bins\brotli.exe -j -q 5 out\product.new.dat
echo.
echo.===正在压缩system_ext.new.dat.br
echo.
bins\brotli.exe -j -q 5 out\system_ext.new.dat
echo.
echo.===正在压缩odm.new.dat.br
echo.
bins\brotli.exe -j -q 5 out\odm.new.dat
echo.
echo.  ------------------------------br格式转换完成------------------------------
echo.
echo.
cls
echo.
echo.===正在生成ROM卡刷包
echo.
echo.===这将花费一段时间，请耐心等待...
echo.
bins\7z.exe a out\yeren.zip .\out\*
ren "out\yeren.zip" "miui_%model%_%build%_yeren_%sdk%.zip" >nul 2>nul
echo.
echo.  ------------------------------ROM卡刷包制作完成------------------------------
echo.
move out\*.zip .\ >nul 2>nul
move out\firmware-update .\images >nul 2>nul
move out\boot.img .\images >nul 2>nul
move out\vendor_boot.img .\images >nul 2>nul
move .\odm.img images\ >nul 2>nul
move .\system.img images\ >nul 2>nul
move .\vendor.img images\ >nul 2>nul
move .\product.img images\ >nul 2>nul
move .\system_ext.img images\ >nul 2>nul
move bins\super.img images\ >nul 2>nul
rd /s /q out >nul 2>nul
cls

goto HOME

:GO_USBFLASH
cls
echo.
echo   ======================================================================
echo.   设备名称：%device%
echo.   设备型号：%model%
echo.   MIUI版本：%build%
echo.   安卓版本：%sdk%
echo.   直接升级手机系统输入!
echo   ======================================================================
echo.
cls
echo.
echo.===开始线刷...
echo.
echo.===请耐心等待，刷机过程请勿操作手机...
echo.
if not exist "bins\STAR" (
platform-tools-windows\fastboot %* getvar product 2>&1 | findstr /r /c:"^product: *alioth" || echo Missmatching image and device
platform-tools-windows\fastboot %* getvar product 2>&1 | findstr /r /c:"^product: *alioth" || exit /B 1
)
if exist images\vm-bootsys.img platform-tools-windows\fastboot %* flash vm-bootsys_ab images\vm-bootsys.img
platform-tools-windows\fastboot %* flash dsp_ab images\dsp.img
platform-tools-windows\fastboot %* flash xbl_config_ab images\xbl_config.img
platform-tools-windows\fastboot %* flash boot_ab images\boot.img
platform-tools-windows\fastboot %* flash modem_ab images\modem.img
platform-tools-windows\fastboot %* flash vbmeta_system_ab images\vbmeta_system.img
platform-tools-windows\fastboot %* flash tz_ab images\tz.img
platform-tools-windows\fastboot %* flash vbmeta_ab images\vbmeta.img
platform-tools-windows\fastboot %* flash bluetooth_ab images\bluetooth.img
platform-tools-windows\fastboot %* flash abl_ab images\abl.img
if exist images\cmnlib.img platform-tools-windows\fastboot %* flash cmnlib_ab images\cmnlib.img
if exist images\cmnlib64.img platform-tools-windows\fastboot %* flash cmnlib64_ab images\cmnlib64.img
if exist images\cpucp.img platform-tools-windows\fastboot %* flash cpucp_ab images\cpucp.img
platform-tools-windows\fastboot %* flash dtbo_ab images\dtbo.img
platform-tools-windows\fastboot %* flash featenabler_ab images\featenabler.img
if exist images\vendor_boot.img platform-tools-windows\fastboot %* flash vendor_boot_ab images\vendor_boot.img
platform-tools-windows\fastboot %* flash keymaster_ab images\keymaster.img
platform-tools-windows\fastboot %* flash uefisecapp_ab images\uefisecapp.img
platform-tools-windows\fastboot %* flash qupfw_ab images\qupfw.img
platform-tools-windows\fastboot %* flash xbl_ab images\xbl.img
platform-tools-windows\fastboot %* flash devcfg_ab images\devcfg.img
platform-tools-windows\fastboot %* flash hyp_ab images\hyp.img
platform-tools-windows\fastboot %* flash imagefv_ab images\imagefv.img
if exist images\shrm.img platform-tools-windows\fastboot %* flash shrm_ab images\shrm.img
platform-tools-windows\fastboot %* flash aop_ab images\aop.img
cls
echo.
echo.===开始刷入super.img...
echo.
echo.===请耐心等待，刷机过程请勿操作手机...
echo.
platform-tools-windows\fastboot %* flash super images\super.img
platform-tools-windows\fastboot set_active a
platform-tools-windows\fastboot reboot

goto HOME

:GO_USBFLASH2
cls
echo.
echo   ======================================================================
echo.   设备名称：%device%
echo.   设备型号：%model%
echo.   MIUI版本：%build%
echo.   安卓版本：%sdk%
echo.   双清刷入手机系统！
echo   ======================================================================
echo.
cls
echo.
echo.===开始线刷...
echo.
echo.===请耐心等待，刷机过程请勿操作手机...
echo.
if not exist "bins\STAR" (
platform-tools-windows\fastboot %* getvar product 2>&1 | findstr /r /c:"^product: *alioth" || echo Missmatching image and device
platform-tools-windows\fastboot %* getvar product 2>&1 | findstr /r /c:"^product: *alioth" || exit /B 1
)
if exist images\vm-bootsys.img platform-tools-windows\fastboot %* flash vm-bootsys_ab images\vm-bootsys.img
platform-tools-windows\fastboot %* flash dsp_ab images\dsp.img
platform-tools-windows\fastboot %* flash xbl_config_ab images\xbl_config.img
platform-tools-windows\fastboot %* flash boot_ab images\boot.img
platform-tools-windows\fastboot %* flash modem_ab images\modem.img
platform-tools-windows\fastboot %* flash vbmeta_system_ab images\vbmeta_system.img
platform-tools-windows\fastboot %* flash tz_ab images\tz.img
platform-tools-windows\fastboot %* flash vbmeta_ab images\vbmeta.img
platform-tools-windows\fastboot %* flash bluetooth_ab images\bluetooth.img
platform-tools-windows\fastboot %* flash abl_ab images\abl.img
if exist images\cmnlib.img platform-tools-windows\fastboot %* flash cmnlib_ab images\cmnlib.img
if exist images\cmnlib64.img platform-tools-windows\fastboot %* flash cmnlib64_ab images\cmnlib64.img
if exist images\cpucp.img platform-tools-windows\fastboot %* flash cpucp_ab images\cpucp.img
platform-tools-windows\fastboot %* flash dtbo_ab images\dtbo.img
platform-tools-windows\fastboot %* flash featenabler_ab images\featenabler.img
if exist images\vendor_boot.img platform-tools-windows\fastboot %* flash vendor_boot_ab images\vendor_boot.img
platform-tools-windows\fastboot %* flash keymaster_ab images\keymaster.img
platform-tools-windows\fastboot %* flash uefisecapp_ab images\uefisecapp.img
platform-tools-windows\fastboot %* flash qupfw_ab images\qupfw.img
platform-tools-windows\fastboot %* flash xbl_ab images\xbl.img
platform-tools-windows\fastboot %* flash devcfg_ab images\devcfg.img
platform-tools-windows\fastboot %* flash hyp_ab images\hyp.img
platform-tools-windows\fastboot %* flash imagefv_ab images\imagefv.img
if exist images\shrm.img platform-tools-windows\fastboot %* flash shrm_ab images\shrm.img
platform-tools-windows\fastboot %* flash aop_ab images\aop.img
cls
echo.
echo.===开始刷入super.img...
echo.
echo.===请耐心等待，刷机过程请勿操作手机...
echo.
platform-tools-windows\fastboot %* flash super images\super.img
platform-tools-windows\fastboot set_active a

platform-tools-windows\fastboot -w
platform-tools-windows\fastboot erase userdata
platform-tools-windows\fastboot erase metadata
platform-tools-windows\fastboot reboot

goto HOME
