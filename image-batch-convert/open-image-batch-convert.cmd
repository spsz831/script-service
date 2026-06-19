@echo off
setlocal
set /p TARGET=Enter source folder path: 
if "%TARGET%"=="" exit /b 0
set /p FORMAT=Enter output format (png/jpg/webp): 
if "%FORMAT%"=="" exit /b 0
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0image-batch-convert.ps1" -InputPath "%TARGET%" -OutputFormat "%FORMAT%"
if errorlevel 1 pause
