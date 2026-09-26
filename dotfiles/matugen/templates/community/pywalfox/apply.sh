#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
if [ -n "$mode" ]; then
    if [ "$mode" = "dark" ] || [ "$mode" = "light" ]; then
        pywalfox "$mode"
    else
        echo "Warning: invalid mode '$mode'; expected dark or light" >&2
    fi
fi

pywalfox update
