<#
Generate Clash Verge / Mihomo YAML from 1VPN proxy data

Author: fsdevcom2000

Github: https://github.com/fsdevcom2000/pingvpn2clash

#>


$username = "a2epfq5ugq0u"
$password = "ptkx3fqg6v7n"


$locations = @{

    ams = @{
        city = "Amsterdam"
        hosts = @(
            "free-amsterdam-https-5.cloudflingcdn.com",
            "free-amsterdam-https-1.cloudburstcdn.com",
            "free-amsterdam-https-3.cloudflaracdn.com",
            "free-amsterdam-https-4.cloudflaracdn.com",
            "free-amsterdam-https-2.cloudflingcdn.com"
        )
    }


    sgp = @{
        city = "Singapore"
        hosts = @(
            "free-singapore-https-3.weathercloudapp.com",
            "free-singapore-https-2.cloudtimecdn.com",
            "free-singapore-https-1.cloudburstcdn.com"
        )
    }


    lax = @{
        city = "Los Angeles"
        hosts = @(
            "free-los-angeles-https-3.cloudflaracdn.com",
            "usa-west-free-https-1.weathercloudapp.com",
            "free-los-angeles-https-1.cloudburstcdn.com",
            "free-los-angeles-https-2.cloudtimecdn.com",
            "free-los-angeles-https-4.cloudflaracdn.com",
            "free-los-angeles-https-5.cloudflingcdn.com"
        )
    }

}



function Build-ClashYaml {


$yaml = @"
mixed-port: 7890
allow-lan: false
mode: rule
log-level: info

ipv6: false

dns:
  enable: true
  ipv6: false
  enhanced-mode: fake-ip

  nameserver:
    - 1.1.1.1
    - 8.8.8.8


proxies:

"@


$names = @()


foreach($location in $locations.Keys){

    $city = $locations[$location].city
    $counter = 1


    foreach($proxyhost in $locations[$location].hosts){

        $name = "$location-$counter"
        $names += $name


        Write-Host "[+] $city -> $host" -ForegroundColor Cyan


        $yaml += @"

  - name: $name
    type: http
    server: $proxyhost
    port: 443
    username: $username
    password: $password
    tls: true

"@


        $counter++

    }

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



foreach($name in $names){

    $yaml += "      - $name`n"

}



$yaml += @"

rules:

  # localhost
  - IP-CIDR,127.0.0.0/8,DIRECT

  # private networks
  - IP-CIDR,10.0.0.0/8,DIRECT
  - IP-CIDR,172.16.0.0/12,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT

  # Russia direct
  - GEOIP,RU,DIRECT

  # all other traffic
  - MATCH,AUTO

"@


return $yaml

}




function Main {


Write-Host "[+] Building Clash YAML..." -ForegroundColor Green


$yaml = Build-ClashYaml



$file = Join-Path `
    $env:USERPROFILE `
    "Downloads\1vpn_clash_$(Get-Date -Format yyyyMMdd_HHmmss).yaml"



$yaml | Out-File `
    -FilePath $file `
    -Encoding UTF8



Write-Host ""
Write-Host "[+] Saved:"
Write-Host $file -ForegroundColor Yellow


}



Main