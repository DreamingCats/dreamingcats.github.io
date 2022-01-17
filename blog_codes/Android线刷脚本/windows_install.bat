@echo off

:Q1
set /p CHOICE1="Q1:你的设备是否已经为Simplicity系统？(Y/N) "
if /i "%CHOICE1%" == "y" (
    goto Q2
) else if /i "%CHOICE1%" == "n" (
    goto Q1_1
) else (
    goto Q1
)


:Q1_1
set /p CHOICE1_1="Q1-1:首次安装需要清除你的数据和内部存储。您是否同意？(Y/N) "
if /i "%CHOICE1_1%" == "y" (
    goto Q2
) else if /i "%CHOICE1_1%" == "n" (
    exit
) else (
    goto Q1_1
)

:Q2
set /p CHOICE2="Q2:您是否需要Magisk（ROOT）?(Y/N) "
if /i "%CHOICE2%" == "y" (
    goto MAIN
) else if /i "%CHOICE2%" == "n" (
    goto MAIN
) else (
    goto Q2
)
goto MAIN

:MAIN

if exist images\dsp.img (
platform-tools-windows\fastboot %* flash dsp_ab images\dsp.img
)
if exist images\vm-bootsys.img (
platform-tools-windows\fastboot %* flash vm-bootsys_ab images\vm-bootsys.img
)
if exist images\cmnlib64.img (
platform-tools-windows\fastboot %* flash cmnlib64_ab images\cmnlib64.img
)
if exist images\cmnlib.img (
platform-tools-windows\fastboot %* flash cmnlib_ab images\cmnlib.img
)
if exist images\xbl_config.img (
platform-tools-windows\fastboot %* flash xbl_config_ab images\xbl_config.img
)
if exist images\modem.img (
platform-tools-windows\fastboot %* flash modem_ab images\modem.img
)
if exist images\vbmeta_system.img (
platform-tools-windows\fastboot %* flash vbmeta_system_ab images\vbmeta_system.img
)
if exist images\tz.img (
platform-tools-windows\fastboot %* flash tz_ab images\tz.img
)
if exist images\vbmeta.img (
platform-tools-windows\fastboot %* flash vbmeta_ab images\vbmeta.img
)
if exist images\bluetooth.img (
platform-tools-windows\fastboot %* flash bluetooth_ab images\bluetooth.img
)
if exist images\abl.img (
platform-tools-windows\fastboot %* flash abl_ab images\abl.img
)
if exist images\cpucp.img (
platform-tools-windows\fastboot %* flash cpucp_ab images\cpucp.img
)
if exist images\dtbo.img (
platform-tools-windows\fastboot %* flash dtbo_ab images\dtbo.img
)
if exist images\featenabler.img (
platform-tools-windows\fastboot %* flash featenabler_ab images\featenabler.img
)
if exist images\vendor_boot.img (
platform-tools-windows\fastboot %* flash vendor_boot_ab images\vendor_boot.img
)
if exist images\keymaster.img (
platform-tools-windows\fastboot %* flash keymaster_ab images\keymaster.img
)
if exist images\uefisecapp.img (
platform-tools-windows\fastboot %* flash uefisecapp_ab images\uefisecapp.img
)
if exist images\qupfw.img (
platform-tools-windows\fastboot %* flash qupfw_ab images\qupfw.img
)
if exist images\xbl.img (
platform-tools-windows\fastboot %* flash xbl_ab images\xbl.img
)
if exist images\devcfg.img (
platform-tools-windows\fastboot %* flash devcfg_ab images\devcfg.img
)
if exist images\hyp.img (
platform-tools-windows\fastboot %* flash hyp_ab images\hyp.img
)
if exist images\imagefv.img (
platform-tools-windows\fastboot %* flash imagefv_ab images\imagefv.img
)
if exist images\shrm.img (
platform-tools-windows\fastboot %* flash shrm_ab images\shrm.img
)
if exist images\aop.img (
platform-tools-windows\fastboot %* flash aop_ab images\aop.img
)
if /i "%CHOICE2%" == "y" (
    platform-tools-windows\fastboot %* flash boot_ab images\boot_magisk.img
) else if /i "%CHOICE2%" == "n" (
    platform-tools-windows\fastboot %* flash boot_ab images\boot_official.img
)
if exist images\super.img (
platform-tools-windows\fastboot %* flash super images\super.img
)

if /i "%CHOICE1_1%" == "y" (
    platform-tools-windows\fastboot %* erase userdata
    platform-tools-windows\fastboot %* erase metadata
)
platform-tools-windows\fastboot %* set_active a
platform-tools-windows\fastboot %* reboot
echo.
echo.
echo. 已执行完毕，如需反馈BUG，请手动Ctrl+A后Ctrl+C复制日志和描述发送到report@lt2333.com
echo. 已执行完毕，如需反馈BUG，请手动Ctrl+A后Ctrl+C复制日志和描述发送到report@lt2333.com
echo. 已执行完毕，如需反馈BUG，请手动Ctrl+A后Ctrl+C复制日志和描述发送到report@lt2333.com
:Finish
goto Finish
:END