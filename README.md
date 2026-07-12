# PingVPN Clash Generator

## English

!!! PingVPN service is not working, use 1vpn_clash.ps1

Simple PowerShell script that automatically fetches free proxy servers from PingVPN API and generates a ready-to-use Clash Verge / Mihomo YAML configuration.

### Features

- Automatically fetches proxy servers from PingVPN
- Generates Clash-compatible YAML config
- Supports authenticated proxies
- Auto proxy testing (`url-test`)
- GEOIP-based routing
- Russian traffic bypass (`DIRECT`)
- Local network bypass
- Ready for TUN mode
- Automatic GEO database updates

### Requirements

- PowerShell 7+
- Clash Verge Rev or compatible Clash/Mihomo client

### Usage

Run:

```
pingvpn_2_clash_verge.ps1
```

The generated YAML configuration file will be saved to your **Downloads** folder with the following naming format:

```
clash_profile_YYYYMMDD_HHMMSS.yaml
```

Import the generated YAML file into Clash Verge.

### Recommended Clash Settings

- Enable `TUN Mode`
- Set mode to `Rule`

### Routing Logic

- RU traffic → DIRECT
- Local networks → DIRECT
- Everything else → PROXY

## Disclaimer

Not affiliated with PingVPN. For educational purposes. May violate PingVPN ToS.

⭐ Star if useful!

---

## Русский

Простой PowerShell-скрипт, который автоматически получает бесплатные proxy-серверы через API PingVPN и генерирует готовый YAML-конфиг для Clash Verge / Mihomo.

### Возможности

- Автоматическое получение proxy-серверов из PingVPN
- Генерация YAML-конфига для Clash
- Поддержка proxy с авторизацией
- Автоматическая проверка proxy (`url-test`)
- GEOIP-маршрутизация
- Обход proxy для RU-трафика (`DIRECT`)
- Исключение локальной сети
- Готовность для TUN режима
- Автообновление GEO-баз

### Требования

- PowerShell 7+
- Clash Verge Rev или совместимый Clash/Mihomo клиент

### Использование

Запуск:

```
pingvpn_2_clash_verge.ps1
```

Сгенерированный YAML-файл конфигурации сохраняется в вашу папку **Загрузки** в следующем формате:

```
clash_profile_YYYYMMDD_HHMMSS.yaml
```

Импортируйте YAML-файл в Clash Verge.

### Рекомендуемые настройки Clash

- Включить `TUN Mode`
- Установить режим `Rule`

### Логика маршрутизации

- RU трафик → DIRECT
- Локальная сеть → DIRECT
- Остальной трафик → PROXY

## Отказ от ответственности

- Данный скрипт не связан с PingVPN и не аффилирован с ним.
- Использовать только в образовательных целях.
- Использование скрипта может нарушать условия (ToS) сервиса PingVPN.

⭐ Поставьте звезду, если пригодилось!
