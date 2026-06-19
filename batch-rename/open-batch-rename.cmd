@echo off
setlocal
set /p TARGET=Enter folder path: 
if "%TARGET%"=="" exit /b 0
set /p PREFIX=Enter prefix (blank allowed): 
set /p SUFFIX=Enter suffix (blank allowed): 
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0batch-rename.ps1" -Path "%TARGET%" -Prefix "%PREFIX%" -Suffix "%SUFFIX%"
if errorlevel 1 pause
