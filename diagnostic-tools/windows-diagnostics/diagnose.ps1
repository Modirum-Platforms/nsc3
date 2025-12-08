$TargetDomain = "saas.example.com"
$Ports = @(443,25204,25205,25206)
$LogDir = "./logs"
$LogFile = "$LogDir/diagnostic-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
If (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }
"=== SaaS NETWORK DIAGNOSTICS (Windows) ===" | Tee-Object -FilePath $LogFile -Append
"Target domain: $TargetDomain" | Tee-Object -FilePath $LogFile -Append
"" | Tee-Object -FilePath $LogFile -Append
"1) DNS CHECK" | Tee-Object -FilePath $LogFile -Append
try {
    $ip = (Resolve-DnsName $TargetDomain -ErrorAction Stop).IPAddress
    "OK: DNS returned $ip" | Tee-Object -FilePath $LogFile -Append
} catch {
    "FAIL: DNS lookup failed" | Tee-Object -FilePath $LogFile -Append
}
"" | Tee-Object -FilePath $LogFile -Append
"2) HTTPS CHECK (443)" | Tee-Object -FilePath $LogFile -Append
try {
    Invoke-WebRequest -Uri "https://$TargetDomain" -UseBasicParsing -TimeoutSec 5 | Out-Null
    "OK: HTTPS reachable" | Tee-Object -FilePath $LogFile -Append
} catch {
    "FAIL: HTTPS unreachable" | Tee-Object -FilePath $LogFile -Append
}
"" | Tee-Object -FilePath $LogFile -Append
"3) RAW TCP PORT CHECKS" | Tee-Object -FilePath $LogFile -Append
foreach ($p in $Ports) {
    $res = Test-NetConnection -ComputerName $TargetDomain -Port $p
    if ($res.TcpTestSucceeded) {
        "Port $p: OPEN" | Tee-Object -FilePath $LogFile -Append
    } else {
        "Port $p: BLOCKED" | Tee-Object -FilePath $LogFile -Append
    }
}
"" | Tee-Object -FilePath $LogFile -Append
"4) TRACEROUTE" | Tee-Object -FilePath $LogFile -Append
tracert $TargetDomain | Tee-Object -FilePath $LogFile -Append
"`n=== DONE ===" | Tee-Object -FilePath $LogFile -Append
