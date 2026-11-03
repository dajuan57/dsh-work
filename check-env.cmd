@echo off
chcp 65001 >nul
rem 双击即可运行环境自检（绕过本机 Restricted 执行策略）
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-env.ps1"
echo.
pause
