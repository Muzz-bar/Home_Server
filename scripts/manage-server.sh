#!/bin/bash

# Warna untuk log biar estetik
HIJAU='\033[0;32m'
MERAH='\033[0;31m'
NORMAL='\033[0m'

# Kunci folder induk server secara absolut menggunakan direktori home lu
BASE_DIR="/home/muzz/my_serverku"

# Kumpulan folder cluster CORE (Wajib dikasih prefix $BASE_DIR)
CORE_SERVICES=(
    "$BASE_DIR/docker/core/tailscale"
    "$BASE_DIR/docker/core/cloudflare"
    "$BASE_DIR/docker/core/portainer"
)

# Kumpulan folder cluster APPS (Wajib dikasih prefix $BASE_DIR)
APP_SERVICES=(
    "$BASE_DIR/docker/apps/file_browser"
    "$BASE_DIR/docker/apps/linkstack"
    "$BASE_DIR/docker/apps/n8n"
    "$BASE_DIR/docker/apps/stirling"
    "$BASE_DIR/docker/apps/tabby-web"
    "$BASE_DIR/docker/apps/uptime kuma"
    "$BASE_DIR/docker/apps/perpus"
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