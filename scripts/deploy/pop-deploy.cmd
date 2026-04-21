@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0pop-deploy.ps1" %*
exit /b %ERRORLEVEL%
