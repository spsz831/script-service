@echo off
setlocal
set "SCRIPT=%~dp0clean-npm-cli-update.ps1"
set "PWSH="
set "ARGS=-PackageName @openai/codex -CommandName codex -ProcessName codex -TempDirPattern .codex-* -SkipProcessStop %*"

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
  "%PWSH%" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %ARGS%
  set "EXITCODE=%ERRORLEVEL%"
) else (
  echo [error] pwsh lookup failed unexpectedly.
  pause
  exit /b 1
)
goto :done

:run_windows_powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%" %ARGS%
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
