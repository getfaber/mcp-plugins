#!/bin/sh
set -eu

plugin_root=${CLAUDE_PLUGIN_ROOT:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}

if sh "$plugin_root/scripts/launch-companion.sh" hook PreToolUse; then
  exit 0
fi

echo "Faber blocked this tool because its private-context policy could not be verified." >&2
exit 2
