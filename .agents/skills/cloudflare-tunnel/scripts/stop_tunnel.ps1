# stop_tunnel.ps1 - Dung Cloudflare Tunnel va Python Server
$cfProcs = Get-Process -Name "cloudflared" -ErrorAction SilentlyContinue
$cfStopped = $false
if ($cfProcs) {
    $cfProcs | Stop-Process -Force
    $cfStopped = $true
}

$portConn = Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | Where-Object { $_.State -eq 'Listen' }
$pyStopped = $false
if ($portConn) {
    $pidToKill = $portConn.OwningProcess | Select-Object -Unique
    foreach ($p in $pidToKill) {
        $proc = Get-Process -Id $p -ErrorAction SilentlyContinue
        if ($proc -and $proc.ProcessName -match "python") {
            Stop-Process -Id $p -Force
            $pyStopped = $true
        }
    }
}

$logFile = "$env:TEMP\cloudflared_p_du_an.log"
if (Test-Path $logFile) {
    Remove-Item $logFile -Force -ErrorAction SilentlyContinue
}

[PSCustomObject]@{
    status = "stopped"
    cloudflared_stopped = $cfStopped
    server_stopped = $pyStopped
    message = "Da tat Cloudflare Tunnel va Local Server thanh cong"
} | ConvertTo-Json -Compress
