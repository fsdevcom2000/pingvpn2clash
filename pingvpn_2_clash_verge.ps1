<#

Simple PowerShell script that automatically fetches free proxy servers from PingVPN API and generates a ready-to-use Clash Verge / Mihomo YAML configuration.

Author: fsdevcom2000

Github: https://github.com/fsdevcom2000/pingvpn2clash

#>

function Get-LatestChromeUserAgent {
    try {
        $url = "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json"
        $response = Invoke-RestMethod -Uri $url -TimeoutSec 5
        $version = $response.channels.Stable.version
        return "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/$version Safari/537.36"
    }
    catch {
        return "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }
}

function Get-PingVpnProxies {
    $API_HOST = "https://api-2.pingvpn.com"
    $APP_ID = "1"

    $headers = @{
        "User-Agent" = Get-LatestChromeUserAgent
    }

    $signupUrl = "$API_HOST/v2/$APP_ID/private/user/customer/sign_up/free"
    $signupBody = @{ email=""; first_name=""; last_name="" } | ConvertTo-Json

    $signupResponse = Invoke-RestMethod -Uri $signupUrl -Method Post -Body $signupBody -ContentType "application/json" -Headers $headers
    $customerId = $signupResponse.customer_id

    $tokenUrl = "$API_HOST/v2/token"
    $tokenBody = "customer_id=$customerId"

    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $tokenBody -ContentType "application/x-www-form-urlencoded" -Headers $headers
    $accessToken = $tokenResponse.access_token

    $listUrl = "$API_HOST/v2/$APP_ID/private/user/customer/vpn_list"
    $authHeaders = $headers.Clone()
    $authHeaders["Authorization"] = "Bearer $accessToken"

    $serversResponse = Invoke-RestMethod -Uri $listUrl -Method Get -Headers $authHeaders

    return $serversResponse.regions
}

function Get-CountryByIp($ip) {
    Write-Host "[DEBUG] GeoIP for $ip" -ForegroundColor DarkYellow
    try {
        $url = "http://ip-api.com/json/{0}?fields=status,countryCode,message,query" -f $ip
        Write-Host "[DEBUG] URL: $url" -ForegroundColor DarkYellow

        $response = Invoke-RestMethod -Uri $url -TimeoutSec 5

        $raw = $response | ConvertTo-Json -Compress
        Write-Host "[DEBUG] Raw response: $raw" -ForegroundColor DarkYellow

        if ($response.status -eq "success" -and $response.countryCode) {
            return $response.countryCode.ToUpper()
        }
        else {
            $st = $response.status
            $msg = $response.message
            Write-Warning ("GeoIP failed for {0}: status={1} message={2}" -f $ip, $st, $msg)
        }
    }
    catch {
        $err = $_.Exception.Message
        Write-Warning ("GeoIP lookup exception for {0}: {1}" -f $ip, $err)
    }

    return "UNKNOWN"
}



function Build-ClashYaml($proxies) {

    $yaml = @"
mixed-port: 7890
allow-lan: false
mode: rule
log-level: info

ipv6: false

geo-auto-update: true
geo-update-interval: 24

dns:
  enable: true
  ipv6: false
  enhanced-mode: fake-ip

  nameserver:
    - 1.1.1.1
    - 8.8.8.8

  fallback:
    - tls://1.1.1.1:853
    - tls://8.8.8.8:853

proxies:
"@

    $names = @()

    $countryCounters = @{}

    foreach ($p in $proxies) {

        $country = Get-CountryByIp $p.ip_address

        
        if ($countryCounters.ContainsKey($country)) {
            $countryCounters[$country]++
        }
        else {
            $countryCounters[$country] = 1
        }

        $name = "$country-$($countryCounters[$country])"
        $names += $name

        Write-Host "[+] $($p.ip_address) -> $name" -ForegroundColor DarkGray

        $yaml += @"

  - name: $name
    type: http
    server: $($p.ip_address)
    port: $($p.squid_default_port)
    username: $($p.username)
    password: $($p.password)
"@
    }

    $yaml += @"

proxy-groups:
  - name: AUTO
    type: url-test
    url: http://www.gstatic.com/generate_204
    interval: 300
    tolerance: 50
    lazy: true
    proxies:
"@

    foreach ($n in $names) {
        $yaml += "`n      - $n"
    }

    $yaml += @"

rules:
  # localhost
  - IP-CIDR,127.0.0.0/8,DIRECT

  # local networks
  - IP-CIDR,10.0.0.0/8,DIRECT
  - IP-CIDR,172.16.0.0/12,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT
  - IP-CIDR,100.64.0.0/10,DIRECT

  # multicast/broadcast
  - IP-CIDR,224.0.0.0/4,DIRECT

  # ru traffic
  - GEOIP,RU,DIRECT

  # everything else
  - MATCH,AUTO
"@

    return $yaml
}

function Main {

    Write-Host "[+] Fetching proxies..." -ForegroundColor Cyan

    $raw = Get-PingVpnProxies

    if (-not $raw) {
        Write-Host "[!] No proxies received" -ForegroundColor Red
        return
    }

    Write-Host "[+] Total proxies: $($raw.Count)" -ForegroundColor Green

    $yaml = Build-ClashYaml $raw

    $file = "clash_profile_$(Get-Date -Format 'yyyyMMdd_HHmmss').yaml"

    $yaml | Out-File -FilePath $file -Encoding UTF8

    Write-Host "[+] YAML saved: $file" -ForegroundColor Green

    Write-Host "`n[+] First proxy preview:" -ForegroundColor Yellow
    $first = $raw[0]
    Write-Host "$($first.ip_address):$($first.squid_default_port)" -ForegroundColor Cyan

    return $file
}

Main