param(
    [switch]$WhatIf
)

$root = (Resolve-Path -Path (Join-Path $PSScriptRoot '..')).Path

$maps = @{
    'file_browser\filebrowser.db' = 'app-storages\file_browser\filebrowser.db'
    'file_browser\config.json'     = 'app-storages\file_browser\config.json'
    'linkstack\linkstack_data'     = 'app-storages\linkstack\linkstack_data'
    'portainer\data'               = 'app-storages\portainer\data'
    'stirling\trainingData'        = 'app-storages\stirling\trainingData'
    'stirling\extraConfigs'        = 'app-storages\stirling\extraConfigs'
    'stirling\logs'                = 'app-storages\stirling\logs'
    'tailscale\state'              = 'app-storages\tailscale\state'
    'uptime kuma\uptime_kuma_data' = 'app-storages\uptime_kuma\uptime_kuma_data'
    'nextcloud\postgres_data'      = 'app-storages\nextcloud\postgres_data'
    'nextcloud\nextcloud_data'     = 'app-storages\nextcloud\nextcloud_data'
    'tabby-web\data'               = 'app-storages\tabby-web\data'
}

$summary = @()

foreach ($srcRel in $maps.Keys) {
    $dstRel = $maps[$srcRel]
    $src = Join-Path -Path $root -ChildPath $srcRel
    $dst = Join-Path -Path $root -ChildPath $dstRel

    if (-not (Test-Path $src)) {
        $summary += "Not found: $src"
        continue
    }

    $dstDir = Split-Path -Path $dst -Parent
    if (-not (Test-Path $dstDir)) {
        if ($WhatIf) { Write-Output "Would create: $dstDir" } else { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
    }

    if (Test-Path $dst) {
        $summary += "Skipped (target exists): $dst"
        continue
    }

    $item = Get-Item -LiteralPath $src
    if ($item.PSIsContainer) {
        if ($WhatIf) {
            Write-Output "Would copy directory: $src -> $dst"
        } else {
            Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force
            $summary += "Copied directory: $src -> $dst"
        }
    } else {
        if ($WhatIf) {
            Write-Output "Would copy file: $src -> $dst"
        } else {
            Copy-Item -Path $src -Destination $dst -Force
            $summary += "Copied file: $src -> $dst"
        }
    }
}

Write-Output "`nMigration summary:`n"
$summary | ForEach-Object { Write-Output "- $_" }
Write-Output "`nSelesai. Pastikan kontainer dimatikan sebelum migrasi, lalu jalankan 'docker compose up -d' setelahnya."