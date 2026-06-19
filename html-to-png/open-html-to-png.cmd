@echo off
powershell -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0html-to-png-gui.ps1"
if errorlevel 1 pause
