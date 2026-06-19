@echo off
setlocal
set /p TARGET=Enter folder path (blank for current folder): 
if "%TARGET%"=="" set "TARGET=."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0folder-size-report.ps1" -Path "%TARGET%"
if errorlevel 1 pause
