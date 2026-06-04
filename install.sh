#!/usr/bin/env bash
# install.sh — FSX dotfiles bootstrap (multi-distro)
# Supports: Arch/CachyOS, Fedora, Debian/Ubuntu
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/lib/utils.sh"
source "$DOTFILES_DIR/lib/detect.sh"

# ─── PACKAGE LISTS ──────────────────────────────────────────

PACMAN_PKGS=(
  zsh curl git base-devel unzip
  lsd neovim bat btop fzf zoxide fd ripgrep fastfetch
  zsh-autosuggestions zsh-syntax-highlighting zsh-completions
  zsh-history-substring-search
  pkgfile
)

DNF_PKGS=(
  zsh curl git gcc make unzip util-linux-user
  lsd neovim bat btop fzf zoxide fd-find ripgrep fastfetch
  zsh-autosuggestions zsh-syntax-highlighting
)

APT_PKGS=(
  zsh curl git build-essential unzip
)

BREW_PKGS=(
  lsd neovim bat btop fzf zoxide fd ripgrep fastfetch
  zsh-autosuggestions zsh-syntax-highlighting zsh-completions
)

# ─── MAIN ───────────────────────────────────────────────────

main() {
  echo ""
  info "FSX Dotfiles — Bootstrap"
  info "========================"
  echo ""

  detect_distro
  echo ""

  install_packages
  install_oh_my_posh
  set_default_shell
  create_symlinks
  install_nerd_font

  echo ""
  echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║   Instalación completa.                          ║${NC}"
  echo -e "${GREEN}║   1. Abrí nvim → lazy.nvim instala plugins solo  ║${NC}"
  echo -e "${GREEN}║   2. Ejecutá: exec zsh                           ║${NC}"
  echo -e "${GREEN}║   3. Configurá la Nerd Font en tu terminal       ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
}

# ─── INSTALL PACKAGES ──────────────────────────────────────

install_packages() {
  case "$DISTRO_FAMILY" in
    arch)
      info "Instalando paquetes via pacman..."
      sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

      # paru para AUR
      if ! command -v paru &>/dev/null; then
        warn "paru no encontrado — paquetes AUR no disponibles"
        warn "Instalar paru: https://github.com/Morganamilo/paru"
      fi

      # Actualizar pkgfile database para command-not-found
      if command -v pkgfile &>/dev/null; then
        info "Actualizando base de datos pkgfile..."
        sudo pkgfile --update
      fi
      ;;

    fedora)
      info "Instalando paquetes via dnf..."
      sudo dnf install -y "${DNF_PKGS[@]}"
      ;;

    debian)
      info "Instalando paquetes base via apt..."
      sudo apt update -qq
      sudo apt install -y "${APT_PKGS[@]}"

      install_homebrew

      info "Instalando paquetes via brew..."
      for pkg in "${BREW_PKGS[@]}"; do
        brew list "$pkg" &>/dev/null \
          && warn "$pkg ya instalado, omitiendo." \
          || brew install "$pkg"
      done
      ;;
  esac
}

install_homebrew() {
  if command -v brew &>/dev/null; then
    warn "Homebrew ya instalado"
    return
  fi

  info "Instalando Homebrew (necesario para paquetes actualizados en Debian)..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Activar brew en esta sesión
  if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    error "Homebrew instalado pero no encontrado"
  fi

  info "Brew: $(brew --version | head -1)"
}

# ─── OH-MY-POSH ────────────────────────────────────────────

install_oh_my_posh() {
  if command -v oh-my-posh &>/dev/null; then
    warn "oh-my-posh ya instalado"
    return
  fi

  case "$DISTRO_FAMILY" in
    arch)
      if command -v paru &>/dev/null; then
        info "Instalando oh-my-posh via paru (AUR)..."
        paru -S --noconfirm oh-my-posh-bin
      else
        info "Instalando oh-my-posh via script oficial..."
        curl -s https://ohmyposh.dev/install.sh | bash -s
      fi
      ;;
    debian)
      # En Debian ya tenemos brew
      info "Instalando oh-my-posh via brew..."
      brew install oh-my-posh
      ;;
    *)
      info "Instalando oh-my-posh via script oficial..."
      curl -s https://ohmyposh.dev/install.sh | bash -s
      ;;
  esac
}

# ─── ZSH DEFAULT SHELL ─────────────────────────────────────

set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "$SHELL" == "$zsh_path" ]]; then
    warn "zsh ya es la shell por defecto"
    return
  fi

  info "Configurando zsh como shell por defecto ($zsh_path)..."
  grep -qx "$zsh_path" /etc/shells || echo "$zsh_path" | sudo tee -a /etc/shells
  chsh -s "$zsh_path"
}

# ─── SYMLINKS ──────────────────────────────────────────────

create_symlinks() {
  info "Creando symlinks..."

  # .zshrc
  make_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

  # Neovim
  mkdir -p "$HOME/.config"
  make_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

  # Kitty (opcional)
  if command -v kitty &>/dev/null || confirm "Kitty no detectado. ¿Crear symlinks de todos modos?"; then
    mkdir -p "$HOME/.config/kitty"
    make_symlink "$DOTFILES_DIR/kitty/kitty.conf"    "$HOME/.config/kitty/kitty.conf"
    make_symlink "$DOTFILES_DIR/kitty/kanagawa.conf" "$HOME/.config/kitty/current-theme.conf"
  fi

  # Fastfetch (opcional)
  if command -v fastfetch &>/dev/null || confirm "Fastfetch no detectado. ¿Crear symlink de todos modos?"; then
    mkdir -p "$HOME/.config/fastfetch"
    make_symlink "$DOTFILES_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
  fi

  # Crear directorios XDG para zsh
  mkdir -p "$HOME/.cache/zsh"
  mkdir -p "$HOME/.local/state/zsh"
}

# ─── NERD FONT ─────────────────────────────────────────────

install_nerd_font() {
  local font_dir="$HOME/.local/share/fonts"

  if fc-list 2>/dev/null | grep -qi "JetBrainsMono.*Nerd"; then
    warn "JetBrainsMono Nerd Font ya instalada"
    return
  fi

  if ! confirm "¿Instalar JetBrainsMono Nerd Font? (requerida para oh-my-posh)"; then
    warn "Omitiendo Nerd Font — oh-my-posh puede mostrar caracteres rotos"
    return
  fi

  info "Descargando JetBrainsMono Nerd Font..."
  local version="v3.3.0"
  local url="https://github.com/ryanoasis/nerd-fonts/releases/download/$version/JetBrainsMono.zip"
  local tmp
  tmp=$(mktemp -d)

  curl -fsSL "$url" -o "$tmp/JetBrainsMono.zip"
  mkdir -p "$font_dir/JetBrainsMono"
  unzip -qo "$tmp/JetBrainsMono.zip" -d "$font_dir/JetBrainsMono"
  fc-cache -f "$font_dir" >/dev/null 2>&1
  rm -rf "$tmp"

  info "JetBrainsMono Nerd Font instalada"
}

# ─── RUN ────────────────────────────────────────────────────

main "$@"
