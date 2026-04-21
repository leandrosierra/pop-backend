@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0pop-cloudflare.ps1" %*
exit /b %ERRORLEVEL%
