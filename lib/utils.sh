#!/usr/bin/env bash
# lib/utils.sh — Shared utilities for install scripts

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()          { echo -e "${GREEN}[+]${NC} $1"; }
warn()          { echo -e "${YELLOW}[!]${NC} $1"; }
error()         { echo -e "${RED}[x]${NC} $1"; exit 1; }
print_success() { echo -e "${GREEN}$1${NC}"; }

confirm() {
  read -rp "$1 [y/N] " r
  [[ "$r" =~ ^[Yy]$ ]]
}

backup() {
  local file="$1"
  if [[ -e "$file" && ! -L "$file" ]]; then
    warn "Backup: $file → $file.bak"
    cp -r "$file" "$file.bak"
  fi
}

make_symlink() {
  local src="$1" dest="$2"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink -f "$dest")"
    if [[ "$current" == "$(readlink -f "$src")" ]]; then
      warn "Symlink already exists: $dest"
      return
    fi
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    backup "$dest"
    rm -rf "$dest"
  fi

  ln -sf "$src" "$dest"
  info "Linked: $dest → $src"
}
