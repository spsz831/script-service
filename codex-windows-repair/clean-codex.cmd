@echo off
setlocal
set "SCRIPT=%~dp0clean-codex-cli.ps1"
set "PWSH="
set "ARGS=%*"
set "SHOW_HELP="
set "REINSTALL_REQUESTED="
set "AUTOFIX_REQUESTED="
set "LAUNCH_REINSTALL_REQUESTED="

if "%~1"=="" goto :default_mode
echo %ARGS% | findstr /I /C:"-Help" /C:"--help" /C:"/?" >nul 2>nul
if %errorlevel%==0 set "SHOW_HELP=1"

echo %ARGS% | findstr /I /C:"-Reinstall" >nul 2>nul
if %errorlevel%==0 set "REINSTALL_REQUESTED=1"
echo %ARGS% | findstr /I /C:"-AutoFix" >nul 2>nul
if %errorlevel%==0 set "AUTOFIX_REQUESTED=1"
echo %ARGS% | findstr /I /C:"-LaunchReinstall" >nul 2>nul
if %errorlevel%==0 set "LAUNCH_REINSTALL_REQUESTED=1"

if defined SHOW_HELP goto :show_help
goto :after_mode_parse

:default_mode
echo [info] No explicit mode provided. Running default cleanup flow.
echo [info] Common modes:
echo        -Verify           Verify only
echo        -AutoFix          Auto repair by diagnosis
echo        -Reinstall        Reinstall in current window
echo        -LaunchReinstall  Open new window and reinstall
echo        -Help             Show usage
echo.
goto :after_mode_parse

:show_help
echo Codex Windows Repair
echo.
echo Usage:
echo   clean-codex.cmd
echo   clean-codex.cmd -Verify
echo   clean-codex.cmd -AutoFix
echo   clean-codex.cmd -Reinstall
echo   clean-codex.cmd -LaunchReinstall
echo.
echo Modes:
echo   default            Light cleanup without reinstall
echo   -Verify            Diagnose only, no cleanup, no reinstall
echo   -AutoFix           Choose repair action by current diagnosis
echo   -Reinstall         Reinstall Codex in current window
echo   -LaunchReinstall   Open a new PowerShell window and reinstall there
echo.
echo Notes:
echo   - Reinstall and AutoFix are blocked inside the current Codex session.
echo   - LaunchReinstall is the safe option when running from Codex.
echo.
echo Press any key to close...
pause >nul
exit /b 0

:after_mode_parse

if defined CODEX_THREAD_ID if defined REINSTALL_REQUESTED (
  echo [blocked] Detected current Codex session via CODEX_THREAD_ID.
  echo [blocked] Refusing to reinstall Codex from inside the running Codex session.
  echo [action] Open a new PowerShell window and run:
  echo          cd /d "%~dp0"
  echo          .\clean-codex.cmd -Reinstall
  echo.
  echo Press any key to close...
  pause >nul
  exit /b 2
)
if defined CODEX_THREAD_ID if defined AUTOFIX_REQUESTED (
  echo [blocked] Detected current Codex session via CODEX_THREAD_ID.
  echo [blocked] Refusing to run AutoFix from inside the running Codex session.
  echo [action] Open a new PowerShell window and run:
  echo          cd /d "%~dp0"
  echo          .\clean-codex.cmd -AutoFix
  echo.
  echo Press any key to close...
  pause >nul
  exit /b 2
)
if defined CODEX_THREAD_ID if defined LAUNCH_REINSTALL_REQUESTED (
  echo [info] LaunchReinstall will open a new PowerShell window.
)

if not exist "%SCRIPT%" (
  echo [error] Script not found: %SCRIPT%
  pause
  exit /b 1
)

where pwsh >nul 2>nul
if %errorlevel%==0 (
  for /f "delims=" %%I in ('where pwsh') do (
    set "PWSH=%%I"
    goto :run_pwsh
  )
)

where powershell >nul 2>nul
if %errorlevel%==0 (
  goto :run_windows_powershell
) else (
  echo [error] Neither pwsh nor powershell was found in PATH.
  pause
  exit /b 1
)

:run_pwsh
if defined PWSH (
  if defined REINSTALL_REQUESTED echo [mode] Reinstall
  if defined AUTOFIX_REQUESTED echo [mode] AutoFix
  if defined LAUNCH_REINSTALL_REQUESTED echo [mode] LaunchReinstall
  if not defined REINSTALL_REQUESTED if not defined AUTOFIX_REQUESTED if not defined LAUNCH_REINSTALL_REQUESTED echo [mode] Default cleanup
  "%PWSH%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -SkipCacheClean %ARGS%
  set "EXITCODE=%ERRORLEVEL%"
) else (
  echo [error] pwsh lookup failed unexpectedly.
  pause
  exit /b 1
)
goto :done

:run_windows_powershell
if defined REINSTALL_REQUESTED echo [mode] Reinstall
if defined AUTOFIX_REQUESTED echo [mode] AutoFix
if defined LAUNCH_REINSTALL_REQUESTED echo [mode] LaunchReinstall
if not defined REINSTALL_REQUESTED if not defined AUTOFIX_REQUESTED if not defined LAUNCH_REINSTALL_REQUESTED echo [mode] Default cleanup
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" -SkipCacheClean %ARGS%
set "EXITCODE=%ERRORLEVEL%"

:done
if not defined EXITCODE set "EXITCODE=0"
echo.
if "%EXITCODE%"=="0" (
  echo [done] Cleanup finished. Press any key to close...
) else (
  echo [failed] Exit code: %EXITCODE%
  echo Press any key to close...
)
pause ^>nul
exit /b %EXITCODE%
