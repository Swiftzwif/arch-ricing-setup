#!/bin/bash
# Swift i3 Ricing Setup Entrypoint
# This script ensures dotfiles/install.sh runs from the correct directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/dotfiles"
exec ./install.sh "$@" 