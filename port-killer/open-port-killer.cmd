@echo off
setlocal

:menu
echo.
echo [info] Current listening TCP ports:
powershell -NoProfile -ExecutionPolicy Bypass -Command "$rows = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue | Where-Object { $_.OwningProcess -gt 0 } | Sort-Object LocalPort, OwningProcess -Unique | ForEach-Object { $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue; [PSCustomObject]@{ Port = $_.LocalPort; PID = $_.OwningProcess; ProcessName = if ($proc) { $proc.ProcessName } else { '' } } }; if ($rows) { $rows | Format-Table -AutoSize } else { Write-Host 'No listening TCP ports found.' }"
echo.
set /p PORT=Enter port number to inspect ^(blank to exit^): 
if "%PORT%"=="" exit /b 0
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0port-killer.ps1" -Port %PORT%
if errorlevel 1 (
  echo.
  pause
)
echo.
set /p AGAIN=Inspect another port? [Y/n]: 
if /I "%AGAIN%"=="N" exit /b 0
goto :menu
