#!/bin/bash

# Warna untuk log biar estetik
HIJAU='\033[0;32m'
MERAH='\033[0;31m'
NORMAL='\033[0m'

# Kumpulan folder cluster CORE (Wajib nyala duluan)
CORE_SERVICES=(
    "docker/core/tailscale"
    "docker/core/cloudflare"
    "docker/core/portainer"
)

# Kumpulan folder cluster APPS
APP_SERVICES=(
    "docker/apps/file_browser"
    "docker/apps/linkstack"
    "docker/apps/nextcloud"
    "docker/apps/stirling"
    "docker/apps/tabby-web"
    "docker/apps/uptime kuma"
)

case "$1" in
    up)
        echo -e "${HIJAU}=== MENYALAKAN CLUSTER CORE ===${NORMAL}"
        for service in "${CORE_SERVICES[@]}"; do
            if [ -d "$service" ]; then
                echo -e "Memulai: $service"
                (cd "$service" && docker compose up -d)
            fi
        done

        echo -e "${HIJAU}=== MENYALAKAN CLUSTER APPS ===${NORMAL}"
        for service in "${APP_SERVICES[@]}"; do
            if [ -d "$service" ]; then
                echo -e "Memulai: $service"
                (cd "$service" && docker compose up -d)
            fi
        done
        ;;
    down)
        echo -e "${MERAH}=== MEMATIKAN CLUSTER APPS ===${NORMAL}"
        for service in "${APP_SERVICES[@]}"; do
            if [ -d "$service" ]; then
                echo -e "Mematikan: $service"
                (cd "$service" && docker compose down)
            fi
        done

        echo -e "${MERAH}=== MEMATIKAN CLUSTER CORE ===${NORMAL}"
        for service in "${CORE_SERVICES[@]}"; do
            if [ -d "$service" ]; then
                echo -e "Mematikan: $service"
                (cd "$service" && docker compose down)
            fi
        done
        ;;
    *)
        echo "Cara pakai: ./manage-server.sh [up|down]"
        exit 1
        ;;
esac