#!/bin/bash
# Simplified Multi-Architecture Docker Builder for PV204
#
# Usage:
#   ./build/build-multiarch-docker.sh          # Fast native build loaded into local Docker
#   ./build/build-multiarch-docker.sh --push   # Multi-arch build (amd64 + arm64) pushed to registry

set -euo pipefail

IMAGE_REPO="${IMAGE_REPO:-valorcz/pv204_memory_analysis}"
DATE_TAG="$(date +%Y-%m-%d)"
TAG_DATE="${IMAGE_REPO}:${DATE_TAG}"
TAG_LATEST="${IMAGE_REPO}:latest"

PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64}"
BUILDER="pv204-builder"
ACTION="--load"

if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
  echo "Usage: $0 [--push]"
  echo ""
  echo "Tags generated:"
  echo "  - ${TAG_DATE} (immutable date snapshot)"
  echo "  - ${TAG_LATEST} (rolling latest pointer)"
  echo ""
  echo "Modes:"
  echo "  (no args)  Build native host image and load into local Docker daemon"
  echo "  --push     Build multi-arch image (${PLATFORMS}) and push both tags to registry"
  exit 0
fi

if [[ "${1:-}" == "--push" ]]; then
  ACTION="--push"
  # Check if foreign architecture emulation is needed and registered in Linux kernel
  if [ ! -f /proc/sys/fs/binfmt_misc/qemu-aarch64 ] && [ ! -f /proc/sys/fs/binfmt_misc/qemu-arm ]; then
    echo "[*] Registering QEMU binfmt support for cross-compilation..."
    docker run --privileged --rm tonistiigi/binfmt --install all >/dev/null
  fi
fi

# Ensure container-based buildx instance is active (needed for multi-platform / cache)
docker buildx inspect "$BUILDER" >/dev/null 2>&1 || docker buildx create --name "$BUILDER" --driver docker-container --use >/dev/null
docker buildx use "$BUILDER" >/dev/null

if [[ "$ACTION" == "--push" ]]; then
  echo "[*] Building multi-arch image (${PLATFORMS})..."
  echo "    Tags to publish:"
  echo "      - ${TAG_DATE}"
  echo "      - ${TAG_LATEST}"
  docker buildx build \
    --platform "$PLATFORMS" \
    --tag "$TAG_DATE" \
    --tag "$TAG_LATEST" \
    --push \
    .
  echo "[+] Successfully published multi-arch manifest with tags:"
  echo "    - ${TAG_DATE}"
  echo "    - ${TAG_LATEST}"
else
  echo "[*] Building native image and loading into local Docker daemon..."
  echo "    Tags applied:"
  echo "      - ${TAG_DATE}"
  echo "      - ${TAG_LATEST}"
  docker buildx build \
    --tag "$TAG_DATE" \
    --tag "$TAG_LATEST" \
    --load \
    .
  echo "[+] Native image ready! Test with: docker run --rm -it ${TAG_LATEST} /bin/bash"
  echo "    (To build and publish both amd64 and arm64, run: $0 --push)"
fi
