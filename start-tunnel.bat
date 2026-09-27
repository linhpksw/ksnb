@echo off
chcp 65001 >nul
title Cloudflare Tunnel - KTKS Phong Du An
echo ===================================================================
echo     DANG KHOI CHAY LOCAL SERVER VA CLOUDFLARE TUNNEL
echo ===================================================================
echo.

set "PATH=C:\Program Files (x86)\cloudflared;%PATH%"

netstat -ano | findstr :8000 >nul
if errorlevel 1 (
    echo [1/2] Dang khoi dong Python HTTP server o cong 8000...
    start /B python -m http.server 8000 --bind 127.0.0.1
    timeout /t 2 /nobreak >nul
) else (
    echo [1/2] Local server da dang chay o cong 8000.
)

echo [2/2] Dang mo Cloudflare Tunnel...
echo Duong dan public trycloudflare.com se xuat hien ben duoi:
echo -------------------------------------------------------------------
cloudflared.exe tunnel --url http://127.0.0.1:8000
pause
