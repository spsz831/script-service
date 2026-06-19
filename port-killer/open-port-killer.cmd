@echo off
setlocal
set /p PORT=Enter port number: 
if "%PORT%"=="" exit /b 0
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0port-killer.ps1" -Port %PORT%
if errorlevel 1 pause
