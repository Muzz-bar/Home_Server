#!/usr/bin/env bash
set -euo pipefail

PROGNAME=$(basename "$0")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SRC="$HOME/my_serverku"
DEFAULT_DST="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  cat <<EOF
Usage: $PROGNAME [options]

Options:
  -s, --source PATH     Source root (old structure). Default: $DEFAULT_SRC
  -d, --dest PATH       Destination Home_Server root. Default: $DEFAULT_DST
  -n, --dry-run         Show actions without copying.
  -v, --verbose         Verbose output.
  -h, --help            Show this help.

Examples:
  $PROGNAME --dry-run
  $PROGNAME -s ~/my_serverku -d /opt/Home_Server
EOF
}

# defaults
src="$DEFAULT_SRC"
dst="$DEFAULT_DST"
dry_run=0
verbose=0

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--source) src="$2"; shift 2 ;;
    -d|--dest) dst="$2"; shift 2 ;;
    -n|--dry-run|--whatif) dry_run=1; shift ;;
    -v|--verbose) verbose=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if [[ $verbose -eq 1 ]]; then
  echo "Source: $src"
  echo "Destination: $dst"
  echo "Dry-run: $dry_run"
fi

# mappings: source-relative -> destination-relative
declare -A maps=(
  ["file_browser/filebrowser.db"]="app-storages/file_browser/filebrowser.db"
  ["file_browser/config.json"]="app-storages/file_browser/config.json"
  ["linkstack/linkstack_data"]="app-storages/linkstack/linkstack_data"
  ["portainer/data"]="app-storages/portainer/data"
  ["stirling/trainingData"]="app-storages/stirling/trainingData"
  ["stirling/extraConfigs"]="app-storages/stirling/extraConfigs"
  ["stirling/logs"]="app-storages/stirling/logs"
  ["tailscale/state"]="app-storages/tailscale/state"
  ["uptime_kuma/uptime_kuma_data"]="app-storages/uptime_kuma/uptime_kuma_data"
  ["nextcloud/postgres_data"]="app-storages/nextcloud/postgres_data"
  ["nextcloud/nextcloud_data"]="app-storages/nextcloud/nextcloud_data"
  ["tabby-web/data"]="app-storages/tabby-web/data"
)

summary=()

for srcRel in "${!maps[@]}"; do
  srcPath="$src/$srcRel"
  dstRel="${maps[$srcRel]}"
  dstPath="$dst/$dstRel"

  if [[ ! -e "$srcPath" ]]; then
    summary+=("Not found: $srcPath")
    continue
  fi

  dstDir=$(dirname "$dstPath")
  if [[ $dry_run -eq 1 ]]; then
    [[ $verbose -eq 1 ]] && echo "[DRY-RUN] Ensure dir: $dstDir"
  else
    mkdir -p "$dstDir"
  fi

  if [[ -e "$dstPath" ]]; then
    summary+=("Skipped (target exists): $dstPath")
    continue
  fi

  if [[ -d "$srcPath" ]]; then
    if command -v rsync >/dev/null 2>&1; then
      if [[ $dry_run -eq 1 ]]; then
        rsync -a --dry-run --itemize-changes "$srcPath/" "$dstPath/"
        summary+=("[DRY-RUN] Would copy directory: $srcPath -> $dstPath")
      else
        rsync -a "$srcPath/" "$dstPath/"
        summary+=("Copied directory: $srcPath -> $dstPath")
      fi
    else
      if [[ $dry_run -eq 1 ]]; then
        echo "[DRY-RUN] Would copy directory (cp -a): $srcPath -> $dstPath"
        summary+=("[DRY-RUN] Would copy directory: $srcPath -> $dstPath")
      else
        cp -a "$srcPath" "$dstPath"
        summary+=("Copied directory (cp): $srcPath -> $dstPath")
      fi
    fi
  else
    # file
    if command -v rsync >/dev/null 2>&1; then
      if [[ $dry_run -eq 1 ]]; then
        rsync -a --dry-run "$srcPath" "$dstPath"
        summary+=("[DRY-RUN] Would copy file: $srcPath -> $dstPath")
      else
        rsync -a "$srcPath" "$dstPath"
        summary+=("Copied file: $srcPath -> $dstPath")
      fi
    else
      if [[ $dry_run -eq 1 ]]; then
        echo "[DRY-RUN] Would copy file (cp -a): $srcPath -> $dstPath"
        summary+=("[DRY-RUN] Would copy file: $srcPath -> $dstPath")
      else
        cp -a "$srcPath" "$dstPath"
        summary+=("Copied file (cp): $srcPath -> $dstPath")
      fi
    fi
  fi

done

echo
printf "Migration summary:\n"
for item in "${summary[@]}"; do
  printf "- %s\n" "$item"
done

echo
if [[ $dry_run -eq 1 ]]; then
  echo "This was a dry-run. Re-run without --dry-run to perform actual copy."
fi

echo "Stop containers before running this script. After migration, restart stacks with 'docker compose up -d'."

exit 0
