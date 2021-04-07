@echo off
SETLOCAL DisableDelayedExpansion EnableExtensions
title TSET Arduino CMD line build
rem *******************************
rem Frank Bösing 11/2018
rem Windows Batch to compile Arduino sketches

rem Usage:
rem compile.cmd 0 : compile sketch
rem compile.cmd 1 : compile & upload sketch
rem compile.cmd 2 : rebuild & upload sketch
rem - Attention: Place compile.cmd in Sketch folder!
rem
rem Edit these paths:

set arduino=C:\arduino-1.8.13
set TyTools=C:\Program Files\TyQt
rem set TyTools=D:\GitHub\tytools\build\win64_new\Release
set libs=C:\Users\kurte\Documents\Arduino\libraries
set tools=D:\GitHub\Tset

rem *******************************
rem Set Teensy-specific variables here:
rem


REM defragster was here 

set model=teensy41
set speed=600
set opt=o2std
set usb=serial2
cd..
set sketchcmd=~

rem set keys=de-de
set keys=en-us

rem *******************************
rem Don't edit below this line
rem *******************************

if EXIST %sketchcmd% (
  set sketchname=%sketchcmd%
) ELSE for %%i in (*.ino) do set sketchname=%%i

if "%sketchname%"=="" (
  echo No Arduino Sketch found!
  exit 1
)

set myfolder=.\
set ino="%myfolder%%sketchname%"
set temp1="%temp%\\arduino_build_%sketchname%"
set temp2="%temp%\\arduino_cache_%sketchname%"
set fqbn=teensy:avr:%model%:usb=%usb%,speed=%speed%,opt=%opt%,keys=%keys%

rem Comment line below to build prior to TeensyDuino 1.50
if "%model%"=="teensy31" set model=teensy32

if "%1"=="2" (
  echo Temp: %temp1%
  echo Temp: %temp2%
  del /s /q %temp1%>NUL
  del /s /q %temp2%>NUL
  echo Temporary files deleted.
)

if not exist %temp1% mkdir %temp1%
if not exist %temp2% mkdir %temp2%

REM if not exist %temp1%\pch mkdir %temp1%\pch
REM if exist userConfig.h copy userConfig.h %temp1%\pch

echo Building Sketch: %ino%
"%arduino%\arduino-builder" -verbose=1 -warnings=more -compile -logger=human -hardware "%arduino%\hardware" -hardware "%LOCALAPPDATA%\Arduino15\packages" -tools "%arduino%\tools-builder" -tools "%arduino%\hardware\tools\avr" -tools "%LOCALAPPDATA%\Arduino15\packages" -built-in-libraries "%arduino%\libraries" -libraries "%libs%" -fqbn=%fqbn% -build-path %temp1% -build-cache "%temp2%"  %ino%

if not "%1"=="0" (
	REM Use TyComm with IDE to reboot for TeensyLoader Update // tycmd reset -b
  if "%errorlevel%"=="0" (
REM when TyComm integrated this .model. file will exist
    if EXIST "%temp1%\%sketchname%.%model%.hex" (
      "%TyTools%\TyCommanderC.exe" upload --autostart --wait  "%temp1%\%sketchname%.%model%.hex" )
REM this fights with TeensyLoader     else ( "%TyTools%\TyCommanderC.exe" upload --autostart --wait  "%temp1%\%sketchname%.hex" )
    "%arduino%\hardware\tools\arm\bin\arm-none-eabi-gcc-nm.exe" -n "%temp1%\%sketchname%.elf" | "%tools%\imxrt_size.exe"
    REM start "%tools%\GDB.cmd" "%arduino%\hardware\tools\arm\bin\arm-none-eabi-gdb.exe" "%temp1%\%sketchname%.elf"
  )  
)

if "%1x"=="x%1" PAUSE
if not "%1x"=="x%1" exit %errorlevel%


rem "T:\arduino-1.8.12\hardware\tools\arm\bin\arm-none-eabi-gdb.exe" "T:\TEMP\arduino_build_breakpoint_test.ino\breakpoint_test.ino.elf"
rem "T:\arduino-1.8.12\hardware\tools\arm\bin\arm-none-eabi-gdb-py.exe"
REM   "%arduino%\hardware\tools\arm\bin\arm-none-eabi-gdb.exe" "%temp1%\%sketchname%.%model%.elf"

rem  "%tools%\GDB.cmd" "%arduino%\hardware\tools\arm\bin\arm-none-eabi-gdb-py.exe" "%temp1%\%sketchname%.elf" --tui
rem (gdb) target remote \\.\com21