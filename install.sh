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

backup() {
  local file="$1"
  if [[ -e "$file" ]]; then
    warn "Backup: $file → $file.bak"
    cp -r "$file" "$file.bak"
  fi
}

# ─── 1. DEPENDENCIAS APT ────────────────────────────────────────────────────
info "Actualizando apt..."
sudo apt update -qq

APT_PKGS=(zsh curl git build-essential unzip)
for pkg in "${APT_PKGS[@]}"; do
  dpkg -s "$pkg" &>/dev/null || sudo apt install -y "$pkg"
done

# ─── 2. HOMEBREW (LINUXBREW) ────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Instalando Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Activar brew en esta sesión
if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  error "Homebrew instalado pero no encontrado. Reinicia el script."
fi

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
  brew list "$pkg" &>/dev/null \
    && warn "$pkg ya instalado, omitiendo." \
    || brew install "$pkg"
done

# ─── 4. ZSH COMO SHELL POR DEFECTO ──────────────────────────────────────────
ZSH_PATH="$(which zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  info "Cambiando shell a zsh ($ZSH_PATH)..."
  grep -qx "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
  chsh -s "$ZSH_PATH"
fi

# ─── 5. .ZSHRC ──────────────────────────────────────────────────────────────
backup "$HOME/.zshrc"
info "Copiando .zshrc..."
cp "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.zsh/cache"

# ─── 6. OH-MY-POSH THEME ────────────────────────────────────────────────────
THEME_DIR="$HOME/.cache/oh-my-posh/themes"
mkdir -p "$THEME_DIR"
info "Copiando tema oh-my-posh (probua.minimal)..."
cp "$DOTFILES_DIR/oh-my-posh/probua.minimal.omp.json" "$THEME_DIR/probua.minimal.omp.json"

# ─── 7. NEOVIM (LAZYVIM) ────────────────────────────────────────────────────
NVIM_CONFIG="$HOME/.config/nvim"
if [[ -d "$NVIM_CONFIG" ]]; then
  warn "~/.config/nvim existe — guardando backup en ~/.config/nvim.bak"
  backup "$NVIM_CONFIG"
fi
info "Copiando config de Neovim/LazyVim..."
cp -r "$DOTFILES_DIR/nvim" "$NVIM_CONFIG"

# ─── 8. KITTY (OPCIONAL) ────────────────────────────────────────────────────
if command -v kitty &>/dev/null || confirm "Kitty no detectado. ¿Copiar config de todos modos?"; then
  KITTY_DIR="$HOME/.config/kitty"
  backup "$KITTY_DIR/kitty.conf"
  mkdir -p "$KITTY_DIR"
  cp "$DOTFILES_DIR/kitty/kitty.conf"    "$KITTY_DIR/kitty.conf"
  cp "$DOTFILES_DIR/kitty/kanagawa.conf" "$KITTY_DIR/current-theme.conf"
  info "Kitty config copiado."
fi

# ─── 9. FASTFETCH (OPCIONAL) ────────────────────────────────────────────────
if command -v fastfetch &>/dev/null || confirm "Fastfetch no detectado. ¿Copiar config de todos modos?"; then
  FF_DIR="$HOME/.config/fastfetch"
  mkdir -p "$FF_DIR"
  cp "$DOTFILES_DIR/fastfetch/config.jsonc" "$FF_DIR/config.jsonc"
  info "Fastfetch config copiado."
fi

# ─── LISTO ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Instalación completa.                          ║${NC}"
echo -e "${GREEN}║   1. Abre nvim → lazy.nvim instala plugins solo  ║${NC}"
echo -e "${GREEN}║   2. Ejecuta: exec zsh                           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
