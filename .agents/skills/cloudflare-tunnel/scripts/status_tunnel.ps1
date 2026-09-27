# status_tunnel.ps1 - Kiem tra trang thai va lay URL hien tai
$logFile = "$env:TEMP\cloudflared_p_du_an.log"

$cfProc = Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue
$portConn = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Listen' }

$url = $null
if (Test-Path $logFile) {
    $content = Get-Content $logFile -Raw -ErrorAction SilentlyContinue
    if ($content -match '(https://[a-zA-Z0-9-]+\.trycloudflare\.com)') {
        $url = $matches[1]
    }
}

[PSCustomObject]@{
    server_running = [bool]$portConn
    tunnel_running = [bool]$cfProc
    url = $url
} | ConvertTo-Json -Compress
