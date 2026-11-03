# wp.ps1 — обёртка для WP-CLI в Docker
# Использование: . .\wp.ps1   (точка + пробел — чтобы функция попала в текущую сессию)
#               wp plugin list
#               wp db export backup.sql

function wp {
    # Запоминаем, откуда вызвана команда
    $originalLocation = Get-Location

    # Переходим в корень проекта (где лежит этот скрипт и docker-compose.yml)
    $projectRoot = Split-Path -Parent $PSCommandPath
    Set-Location $projectRoot

    try {
        # Проверяем, что контейнер wpcli запущен
        $running = docker compose ps --services --filter "status=running" 2>$null
        if ($running -notcontains "wpcli") {
            Write-Host "⚠ Контейнер wpcli не запущен. Поднимаю..." -ForegroundColor Yellow
            docker compose up -d wpcli | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Не удалось запустить wpcli"
                return
            }
        }

        # Передаём все аргументы в WP-CLI внутри контейнера
        docker compose exec wpcli wp @args
    }
    finally {
        # Возвращаемся туда, откуда пришли
        Set-Location $originalLocation
    }
}