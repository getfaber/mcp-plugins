#!/bin/sh
set -eu

plugin_root=${CLAUDE_PLUGIN_ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
version=$(tr -d '[:space:]' < "$plugin_root/VERSION")

case "$(uname -s)" in
  Darwin) target_os=darwin ;;
  Linux) target_os=linux ;;
  *) echo "Faber supports Cowork Desktop on macOS and Linux." >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64|amd64) target_arch=amd64 ;;
  arm64|aarch64) target_arch=arm64 ;;
  *) echo "Faber for Cowork supports amd64 and arm64 processors." >&2; exit 1 ;;
esac

companion="$plugin_root/bin/faber-companion_${target_os}_${target_arch}"
if [ ! -x "$companion" ]; then
  echo "The bundled Faber companion is missing or not executable: $companion" >&2
  exit 1
fi

export FABER_PRODUCT=claude-cowork
export FABER_PRODUCT_VERSION=$version
export FABER_MCP_TOOL_CATALOG="$plugin_root/tools/catalog.json"
export FABER_PUBLISH_SOURCE=local-file-ref
export FABER_KNOWLEDGE_MODE=host-background-agent
export FABER_SESSION_ADAPTER=none
exec "$companion" "$@"
