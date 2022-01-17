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
set app_description=MIUI�汾��%build%        ��׿�汾��%sdk%    
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
echo.        -[01]-^>^> һ��������ˢ��
echo.
echo.        -[02]-^>^> ��ˢ�����ֻ�
echo.
echo.        -[03]-^>^> ��ˢ�����ֻ�(˫��)
echo.
echo.        -[04]-^>^> �˳�
echo.
echo         ======================================================================
echo.
echo.
set /p key=-^-^-^-^-^> ��ѡ�����:
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
echo.===����MIX4Ϊerofs��ʽ,MIX4��ʱ��֧�ֿ�ˢ������
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
echo.===���ڷֽ�super.img
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
echo.===����ת�������ʽ
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
echo.===���ڽ�system.imgת��Ϊsystem.new.dat
echo.
bins\img2sdat.exe out\system.img -o out -v 4
del out\system.img >nul 2>nul
echo.
echo.===���ڽ�vendor.imgת��Ϊvendor.new.dat
echo.
bins\img2sdat.exe out\vendor.img -o out -v 4 -p vendor
del out\vendor.img >nul 2>nul
echo.
echo.===���ڽ�product.imgת��Ϊproduct.new.dat
echo.
bins\img2sdat.exe out\product.img -o out -v 4 -p product
del out\product.img >nul 2>nul
echo.
echo.===���ڽ�system_ext.imgת��Ϊsystem_ext.new.dat
echo.
bins\img2sdat.exe out\system_ext.img -o out -v 4 -p system_ext
del out\system_ext.img >nul 2>nul
echo.
echo.===���ڽ�odm.imgת��Ϊodm.new.dat
echo.
bins\img2sdat.exe out\odm_new.img -o out -v 4 -p odm
del /s /q out\odm_new.img >nul 2>nul
echo.
echo.  ------------------------------dat��ʽת�����------------------------------
echo.
cls
echo.
echo.===����ѹ��system.new.dat.br
echo.
bins\brotli.exe -j -q 5 out\system.new.dat
echo.
echo.===����ѹ��vendor.new.dat.br
echo.
bins\brotli.exe -j -q 5 out\vendor.new.dat
echo.
echo.===����ѹ��product.new.dat.br
echo.
bins\brotli.exe -j -q 5 out\product.new.dat
echo.
echo.===����ѹ��system_ext.new.dat.br
echo.
bins\brotli.exe -j -q 5 out\system_ext.new.dat
echo.
echo.===����ѹ��odm.new.dat.br
echo.
bins\brotli.exe -j -q 5 out\odm.new.dat
echo.
echo.  ------------------------------br��ʽת�����------------------------------
echo.
echo.
cls
echo.
echo.===��������ROM��ˢ��
echo.
echo.===�⽫����һ��ʱ�䣬�����ĵȴ�...
echo.
bins\7z.exe a out\yeren.zip .\out\*
ren "out\yeren.zip" "miui_%model%_%build%_yeren_%sdk%.zip" >nul 2>nul
echo.
echo.  ------------------------------ROM��ˢ���������------------------------------
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
echo.   �豸���ƣ�%device%
echo.   �豸�ͺţ�%model%
echo.   MIUI�汾��%build%
echo.   ��׿�汾��%sdk%
echo.   ֱ�������ֻ�ϵͳ����!
echo   ======================================================================
echo.
cls
echo.
echo.===��ʼ��ˢ...
echo.
echo.===�����ĵȴ���ˢ��������������ֻ�...
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
echo.===��ʼˢ��super.img...
echo.
echo.===�����ĵȴ���ˢ��������������ֻ�...
echo.
platform-tools-windows\fastboot %* flash super images\super.img
platform-tools-windows\fastboot set_active a
platform-tools-windows\fastboot reboot

goto HOME

:GO_USBFLASH2
cls
echo.
echo   ======================================================================
echo.   �豸���ƣ�%device%
echo.   �豸�ͺţ�%model%
echo.   MIUI�汾��%build%
echo.   ��׿�汾��%sdk%
echo.   ˫��ˢ���ֻ�ϵͳ��
echo   ======================================================================
echo.
cls
echo.
echo.===��ʼ��ˢ...
echo.
echo.===�����ĵȴ���ˢ��������������ֻ�...
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
echo.===��ʼˢ��super.img...
echo.
echo.===�����ĵȴ���ˢ��������������ֻ�...
echo.
platform-tools-windows\fastboot %* flash super images\super.img
platform-tools-windows\fastboot set_active a

platform-tools-windows\fastboot -w
platform-tools-windows\fastboot erase userdata
platform-tools-windows\fastboot erase metadata
platform-tools-windows\fastboot reboot

goto HOME
