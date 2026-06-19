@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0clean-temp-files.ps1"
if errorlevel 1 pause
