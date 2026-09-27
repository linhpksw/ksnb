# start_tunnel.ps1 - Khoi dong Local Server va Cloudflare Tunnel
$workspaceRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
Set-Location $workspaceRoot

$logFile = "$env:TEMP\cloudflared_p_du_an.log"

# 1. Kiem tra Python
$pyCmd = (Get-Command python -ErrorAction SilentlyContinue)
if (-not $pyCmd) {
    Write-Output '{"status":"error","message":"Python chua duoc cai dat hoac chua co trong PATH."}'
    exit 1
}

# 2. Kiem tra va khoi chay HTTP Server o cong 8000 neu chua chay
$portInUse = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Listen' }
if (-not $portInUse) {
    Start-Process -FilePath "python" -ArgumentList "-m http.server 8000 --bind 127.0.0.1" -WorkingDirectory $workspaceRoot -WindowStyle Hidden
    Start-Sleep -Seconds 2
}

# 3. Xac dinh duong dan cloudflared.exe
$cfExe = "C:\Program Files (x86)\cloudflared\cloudflared.exe"
if (-not (Test-Path $cfExe)) {
    $cfExe = (Get-Command cloudflared -ErrorAction SilentlyContinue).Source
}
if (-not $cfExe -or -not (Test-Path $cfExe)) {
    Write-Output '{"status":"error","message":"cloudflared chua duoc cai dat tren he thong."}'
    exit 1
}

# 4. Kiem tra cloudflared process
$cfProc = Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue
if (-not $cfProc) {
    if (Test-Path $logFile) { Remove-Item $logFile -Force }
    Start-Process -FilePath $cfExe -ArgumentList "tunnel --url http://127.0.0.1:8000 --logfile `"$logFile`"" -WindowStyle Hidden
    Start-Sleep -Seconds 4
}

# 5. Trich xuat URL tu log file
$url = $null
if (Test-Path $logFile) {
    for ($i = 0; $i -lt 15; $i++) {
        $content = Get-Content $logFile -Raw -ErrorAction SilentlyContinue
        if ($content -match '(https://[a-zA-Z0-9-]+\.trycloudflare\.com)') {
            $url = $matches[1]
            break
        }
        Start-Sleep -Seconds 1
    }
}

if ($url) {
    [PSCustomObject]@{
        status = "running"
        url = $url
        port = 8000
        message = "Cloudflare Tunnel da khoi dong thanh cong"
    } | ConvertTo-Json -Compress
} else {
    if ($cfProc) {
        [PSCustomObject]@{
            status = "running"
            url = $null
            port = 8000
            message = "Tunnel dang chay ngam nhung khong doc duoc URL moi tu log"
        } | ConvertTo-Json -Compress
    } else {
        [PSCustomObject]@{
            status = "failed"
            message = "Khong the tao Cloudflare Tunnel"
        } | ConvertTo-Json -Compress
    }
}
