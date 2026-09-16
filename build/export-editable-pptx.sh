#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Slidev Editable PPTX Exporter (Powered by Slidev PR #2722 / v52.20.0+)
#
# Walks the rendered presentation DOM in Chromium to generate native PowerPoint
# shapes and text boxes rather than flattening slides into background images.
#
# Requirements:
#   - Node.js >= 22.12.0 (for Slidev v53+)
#   - @slidev/cli >= 52.20.0
#   - playwright-chromium
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
SLIDES_DIR="${BASE_DIR}/slides"
DEFAULT_OUTPUT="${SLIDES_DIR}/dist/pv204-presentation-editable.pptx"

OUTPUT="${DEFAULT_OUTPUT}"
RANGE=""
WITH_CLICKS="true"
TIMEOUT="60000"
WAIT_TIME="0"

print_help() {
    cat <<EOF
Usage: $(basename "$0") [options]

Export Slidev presentation into an editable PowerPoint (.pptx) file.

Options:
  -o, --output <path>    Output .pptx file path (default: slides/dist/pv204-presentation-editable.pptx)
  -r, --range <range>    Slide range to export (e.g. 1-10, 1,3,5)
  --no-clicks            Collapse click animations into single slides (--with-clicks false)
  --timeout <ms>         Timeout per slide in milliseconds (default: 60000)
  --wait <ms>            Wait time after slide load in ms (default: 0)
  -h, --help             Show this help message

Notes on Editable PPTX Export:
  - Native Elements: Text headings, paragraphs, lists, and boxes are native shapes.
  - Rasterized Elements: SVG icons, Mermaid diagrams, <canvas>, and CSS gradients
    cannot be mapped to native Office shapes and are exported as individual images.
  - Fonts: Font files are not embedded in the .pptx. Ensure referenced fonts
    (e.g., Inter, Fira Code) are installed on recipient systems.
  - Safety Valve: If any individual slide fails layout reconstruction, it automatically
    falls back to standard image export for that slide only.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -r|--range)
            RANGE="$2"
            shift 2
            ;;
        --no-clicks)
            WITH_CLICKS="false"
            shift
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --wait)
            WAIT_TIME="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "[-] Unknown option: $1" >&2
            print_help
            exit 1
            ;;
    esac
done

echo "======================================================================"
echo "         Slidev Editable PPTX Export (PR #2722 / v52.20.0+)           "
echo "======================================================================"

# 1. Check Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "[-] Error: node is not installed or not in PATH." >&2
    exit 1
fi
NODE_VERSION="$(node -v | tr -d 'v')"
echo "[*] Using Node.js: v${NODE_VERSION}"

# 2. Check Package Manager (prefer pnpm)
PKG_MGR="pnpm"
if ! command -v pnpm >/dev/null 2>&1; then
    if command -v npm >/dev/null 2>&1; then
        PKG_MGR="npm"
    else
        echo "[-] Error: neither pnpm nor npm found in PATH." >&2
        exit 1
    fi
fi

# 3. Check @slidev/cli version
if [ ! -d "${SLIDES_DIR}/node_modules/@slidev/cli" ]; then
    echo "[!] @slidev/cli not found in ${SLIDES_DIR}/node_modules. Installing dependencies..."
    (cd "${SLIDES_DIR}" && ${PKG_MGR} install)
fi

SLIDEV_VER=$(node -e "try { console.log(require('${SLIDES_DIR}/node_modules/@slidev/cli/package.json').version); } catch(e) { console.log('0.0.0'); }")
echo "[*] Detected @slidev/cli version: ${SLIDEV_VER}"

# Ensure version is >= 52.20.0
REQUIRED_MAJOR=52
REQUIRED_MINOR=20
CURRENT_MAJOR=$(echo "${SLIDEV_VER}" | cut -d. -f1)
CURRENT_MINOR=$(echo "${SLIDEV_VER}" | cut -d. -f2)

if [ "${CURRENT_MAJOR}" -lt "${REQUIRED_MAJOR}" ] || \
   { [ "${CURRENT_MAJOR}" -eq "${REQUIRED_MAJOR}" ] && [ "${CURRENT_MINOR}" -lt "${REQUIRED_MINOR}" ]; }; then
    echo "[!] @slidev/cli version ${SLIDEV_VER} is below 52.20.0. Updating to latest..."
    (cd "${SLIDES_DIR}" && ${PKG_MGR} install)
fi

# 4. Check Playwright Chromium
PW_INSTALLED=$(node -e "try { require.resolve('playwright-chromium', { paths: ['${SLIDES_DIR}'] }); console.log('yes'); } catch(e) { console.log('no'); }")
if [ "${PW_INSTALLED}" != "yes" ]; then
    echo "[!] playwright-chromium is required for Slidev headless browser export. Installing..."
    (cd "${SLIDES_DIR}" && ${PKG_MGR} add -D playwright-chromium)
fi

# Ensure OUTPUT is an absolute path
if [[ "${OUTPUT}" != /* ]]; then
    OUTPUT="$(pwd)/${OUTPUT}"
fi
mkdir -p "$(dirname "${OUTPUT}")"

# 5. Build export command arguments
EXPORT_ARGS=(
    "export"
    "slides.md"
    "--format" "pptx-editable"
    "--output" "${OUTPUT}"
    "--timeout" "${TIMEOUT}"
    "--wait" "${WAIT_TIME}"
)

if [ "${WITH_CLICKS}" = "false" ]; then
    EXPORT_ARGS+=("--with-clicks" "false")
fi

if [ -n "${RANGE}" ]; then
    EXPORT_ARGS+=("--range" "${RANGE}")
fi

echo ""
echo "[*] Slides source:    ${SLIDES_DIR}/slides.md"
echo "[*] Output target:    ${OUTPUT}"
echo "[*] With click steps: ${WITH_CLICKS}"
[ -n "${RANGE}" ] && echo "[*] Slide range:      ${RANGE}"
echo "[*] Executing Slidev export..."
echo ""

cd "${SLIDES_DIR}"
if [ "${PKG_MGR}" = "pnpm" ]; then
    pnpm exec slidev "${EXPORT_ARGS[@]}"
else
    npx slidev "${EXPORT_ARGS[@]}"
fi

echo ""
echo "======================================================================"
echo "[+] Editable PPTX export completed successfully!"
echo "[+] Output file: ${OUTPUT}"
echo ""
echo "Recipients / Editing Hints:"
echo "  • Text boxes, titles, and layout containers are native PowerPoint shapes."
echo "  • Diagrams (Mermaid), icons, and complex SVG elements are saved as images."
echo "  • Ensure presentation fonts (e.g., Inter, Fira Code) are installed"
echo "    on target editing machines to prevent PowerPoint font substitution."
echo "======================================================================"
