#!/bin/bash

# --- KONFIGURASI TELEGRAM ---
TOKEN="8832742963:AAFmZgyO1Fx9cMzDcJD4OvjLlCTY1phG9iw"
CHAT_ID="1520748566"
MSG_ID="19"

# 1. Ambil Data Sistem Kernel
WAKTU=$(date '+%Y-%m-%d %H:%M:%S')
UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime)
JAM=$((UPTIME_SEC / 3600))
MENIT=$(( (UPTIME_SEC % 3600) / 60 ))
DETIK=$((UPTIME_SEC % 60))
UPTIME_FORMAT=$(printf "%02d:%02d:%02d" $JAM $MENIT $DETIK)
SISA_RAM=$(free -m | awk 'NR==2{print $7}')
SUHU=$(sensors | grep 'Core 0' | awk '{print $3}')

# 2. Tulis ke log lokal sebagai backup forensik di hard disk
echo "[$WAKTU] Uptime: $UPTIME_FORMAT | RAM Sisa: ${SISA_RAM}MB | Suhu: $SUHU" >> ~/my_serverku/scripts/server_kritis.log

# 3. Ambil 10 baris riwayat napas terakhir
LOG_DATA=$(tail -n 10 ~/my_serverku/scripts/server_kritis.log)

# 4. PUSH data ke Telegram dengan cara mengedit pesan (Live Update)
curl -s -X POST "https://api.telegram.org/bot$TOKEN/editMessageText" \
    -d chat_id="$CHAT_ID" \
    -d message_id="$MSG_ID" \
    -d text="📊 *LIVE DASHBOARD ACER SERVER*
Pembaruan terakhir: $WAKTU

$LOG_DATA" \
    -d parse_mode="Markdown" > /dev/null


# --- FITUR ALERT (SUHU > 75 atau RAM < 200MB) ---
# 1. Bersihkan teks suhu (Ubah '+61.0°C' menjadi angka bulat '61')
SUHU_INT=$(echo "$SUHU" | tr -dc '0-9.' | awk -F. '{print $1}')
SUHU_INT=${SUHU_INT:-0}

BATAS_SUHU=75
BATAS_RAM=200

if [ "$SUHU_INT" -gt "$BATAS_SUHU" ] || [ "$SISA_RAM" -lt "$BATAS_RAM" ]; then
    # Cek apakah ada file lock Anti-Spam berumur kurang dari 30 menit
    if [ ! -f /tmp/alert_lock ] || test $(find /tmp/alert_lock -mmin +30); then
        PESAN_ALERT="🚨 *URGENT ALERT SERVER ACER* 🚨%0A%0ASuhu Kritis: $SUHU%0ARAM Sisa: ${SISA_RAM}MB%0AServer hampir kehabisan nafas!"
        
        # Tembak pesan BARU ke Telegram (Bukan edit, biar muncul notif di HP lu)
        curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
            -d chat_id="$CHAT_ID" \
            -d text="$PESAN_ALERT" \
            -d parse_mode="Markdown" > /dev/null
            
        # Perbarui file lock agar bot diam selama 30 menit ke depan
        touch /tmp/alert_lock
    fi
fi
