#!/usr/bin/env bash
# install.sh — FSX dotfiles bootstrap
# Tested on: Ubuntu 24.04 / Debian-based distros
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

info()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[x]${NC} $1"; exit 1; }
confirm() { read -rp "$1 [y/N] " r; [[ "$r" =~ ^[Yy]$ ]]; }

# ─── 1. DEPENDENCIAS APT ────────────────────────────────────────────────────
info "Actualizando apt..."
sudo apt update -qq

APT_PKGS=(zsh curl git build-essential unzip)
for pkg in "${APT_PKGS[@]}"; do
  if ! dpkg -s "$pkg" &>/dev/null; then
    info "Instalando $pkg..."
    sudo apt install -y "$pkg"
  fi
done

# ─── 2. HOMEBREW (LINUXBREW) ────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Instalando Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
info "Brew: $(brew --version | head -1)"

# ─── 3. PAQUETES BREW ───────────────────────────────────────────────────────
BREW_PKGS=(
  oh-my-posh
  lsd
  neovim
  bat
  btop
  fzf
  zoxide
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

info "Instalando paquetes brew..."
for pkg in "${BREW_PKGS[@]}"; do
  if ! brew list "$pkg" &>/dev/null; then
    brew install "$pkg"
  else
    warn "$pkg ya instalado, omitiendo."
  fi
done

# ─── 4. ZSH COMO SHELL POR DEFECTO ──────────────────────────────────────────
ZSH_PATH="$(which zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  info "Cambiando shell a zsh ($ZSH_PATH)..."
  if ! grep -qx "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  chsh -s "$ZSH_PATH"
fi

# ─── 5. .ZSHRC ──────────────────────────────────────────────────────────────
if [[ -f "$HOME/.zshrc" ]]; then
  warn "~/.zshrc existe — guardando backup en ~/.zshrc.bak"
  cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
info "Copiando .zshrc..."
cp "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# ─── 6. OH-MY-POSH THEME ────────────────────────────────────────────────────
THEME_DIR="$HOME/.cache/oh-my-posh/themes"
mkdir -p "$THEME_DIR"
info "Copiando tema oh-my-posh (probua.minimal)..."
cp "$DOTFILES_DIR/oh-my-posh/probua.minimal.omp.json" "$THEME_DIR/probua.minimal.omp.json"

# ─── 7. KITTY (OPCIONAL) ────────────────────────────────────────────────────
if command -v kitty &>/dev/null || confirm "Kitty no detectado. ¿Copiar config de todos modos?"; then
  KITTY_DIR="$HOME/.config/kitty"
  mkdir -p "$KITTY_DIR"
  cp "$DOTFILES_DIR/kitty/kitty.conf"   "$KITTY_DIR/kitty.conf"
  cp "$DOTFILES_DIR/kitty/kanagawa.conf" "$KITTY_DIR/current-theme.conf"
  info "Kitty config copiado."
fi

# ─── 8. FASTFETCH (OPCIONAL) ────────────────────────────────────────────────
if command -v fastfetch &>/dev/null || confirm "Fastfetch no detectado. ¿Copiar config de todos modos?"; then
  FF_DIR="$HOME/.config/fastfetch"
  mkdir -p "$FF_DIR"
  cp "$DOTFILES_DIR/fastfetch/config.jsonc" "$FF_DIR/config.jsonc"
  info "Fastfetch config copiado."
fi

# ─── 9. DIRECTORIO CACHE ZSH ────────────────────────────────────────────────
mkdir -p "$HOME/.zsh/cache"

# ─── LISTO ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Instalación completa. Reinicia     ║${NC}"
echo -e "${GREEN}║   tu shell o ejecuta: exec zsh       ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
