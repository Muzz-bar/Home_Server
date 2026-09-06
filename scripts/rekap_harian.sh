#!/bin/bash

# --- 1. KREDENSIAL BOT TELEGRAM ---
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
    . "$SCRIPT_DIR/.env"
fi
: "${TELEGRAM_BOT_TOKEN:?TELEGRAM_BOT_TOKEN belum diisi di scripts/.env}"
: "${TELEGRAM_CHAT_ID:?TELEGRAM_CHAT_ID belum diisi di scripts/.env}"

TOKEN="$TELEGRAM_BOT_TOKEN"
CHAT_ID="$TELEGRAM_CHAT_ID"

# --- 2. PENENTUAN TARGET FILE ---
TANGGAL=$(date '+%Y-%m-%d')
FILE_TARGET="/tmp/rekap_${TANGGAL}.txt"

# Saring log murni hanya untuk tanggal hari ini
grep "$TANGGAL" ~/my_serverku/scripts/server_kritis.log > "$FILE_TARGET"

# --- 3. ANALISIS DATA (Hanya jalan jika file tidak kosong) ---
if [ -s "$FILE_TARGET" ]; then
    # Cari baris dengan Suhu Tertinggi
    PEAK_SUHU=$(sort -k 11 -n -r "$FILE_TARGET" | head -n 1)
    
    # Cari baris dengan RAM Sisa Terendah
    PEAK_RAM=$(sort -k 8 -n "$FILE_TARGET" | head -n 1)

    # Bedah data Suhu Tertinggi
    WAKTU_SUHU=$(echo "$PEAK_SUHU" | awk '{print $2}' | tr -d ']')
    NILAI_SUHU=$(echo "$PEAK_SUHU" | awk '{print $11}')
    BIANG_SUHU=$(echo "$PEAK_SUHU" | awk '{print $15}')

    # Bedah data RAM Terendah
    WAKTU_RAM=$(echo "$PEAK_RAM" | awk '{print $2}' | tr -d ']')
    NILAI_RAM=$(echo "$PEAK_RAM" | awk '{print $8}')
    BIANG_RAM=$(echo "$PEAK_RAM" | awk '{print $17}')

    # --- 4. RAKIT PESAN (Menggunakan Enter Asli & Fallback Data) ---
    # Tanda ${VAR:-Teks} berfungsi agar kalau datanya kosong, dia menampilkan teks alternatif
    CAPTION="📁 *Laporan Harian Server Acer* 📁
Tanggal: $TANGGAL

🔥 *PUNCAK PANAS TERKUTUK:* $NILAI_SUHU pada $WAKTU_SUHU
👉 Dalang CPU: ${BIANG_SUHU:-"Tidak Tercatat (Log Lama)"}

🚨 *SISA RAM PALING SEKARAT:* $NILAI_RAM pada $WAKTU_RAM
👉 Dalang RAM: ${BIANG_RAM:-"Tidak Tercatat (Log Lama)"}"

    # --- 5. KIRIM KE TELEGRAM ---
    curl -s -F document=@"$FILE_TARGET" \
         -F caption="$CAPTION" \
         "https://api.telegram.org/bot$TOKEN/sendDocument?chat_id=$CHAT_ID&parse_mode=Markdown" > /dev/null
fi

# --- 6. BERSIHKAN FILE SEMENTARA ---
rm -f "$FILE_TARGET"
