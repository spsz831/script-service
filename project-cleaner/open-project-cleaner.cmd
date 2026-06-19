@echo off
setlocal
set /p TARGET=Enter project root path (blank for current folder): 
if "%TARGET%"=="" set "TARGET=."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0project-cleaner.ps1" -Path "%TARGET%"
if errorlevel 1 pause
