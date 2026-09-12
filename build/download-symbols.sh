#!/bin/bash
set -euo pipefail

# Helper script to pre-download Volatility 3 symbols on the host machine.
# This prevents downloading symbols inside the VM/container and keeps Docker images lean.
#
# Usage:
#   ./build/download-symbols.sh          # Downloads Windows symbols (~840MB)
#   ./build/download-symbols.sh all      # Downloads Windows, Linux, and Mac symbol packs

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SYMBOLS_DIR="${BASE_DIR}/symbols"

echo "=== Volatility 3 Symbol Pack Downloader ==="
echo "Target directory: ${SYMBOLS_DIR}"
mkdir -p "${SYMBOLS_DIR}"

TARGET="${1:-windows}"

download_pack() {
    local os="$1"
    local url="https://downloads.volatilityfoundation.org/volatility3/symbols/${os}.zip"
    local zip_file="${SYMBOLS_DIR}/${os}.zip"

    echo ""
    echo "[*] Downloading ${os} symbol pack (~840MB for Windows)..."
    if curl -f -L -# "${url}" -o "${zip_file}"; then
        echo "[*] Extracting ${os} symbols..."
        unzip -q -o "${zip_file}" -d "${SYMBOLS_DIR}/"
        rm -f "${zip_file}"
        echo "[+] ${os} symbols ready in ${SYMBOLS_DIR}/${os}"
    else
        echo "[!] Error downloading ${os} symbols. Please check your internet connection." >&2
        rm -f "${zip_file}"
        return 1
    fi
}

if [ "$TARGET" = "windows" ]; then
    download_pack "windows"
elif [ "$TARGET" = "all" ]; then
    download_pack "windows"
    download_pack "linux"
    download_pack "mac"
else
    echo "Usage: $0 [windows|all]" >&2
    exit 1
fi

echo ""
echo "=== Success! ==="
echo "Symbols are now cached on your host in: ${SYMBOLS_DIR}"
echo "- For Vagrant: 'vagrant up' will automatically detect, sync, and link them."
echo "- For Docker:  'docker compose' mounts this directory directly into the container."
