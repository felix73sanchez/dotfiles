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

  choose_prompt_engine
  echo ""

  install_packages
  install_prompt_engine
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

# ─── PROMPT ENGINE SELECTION ───────────────────────────────

# PROMPT_ENGINE: "omp" (oh-my-posh) | "p10k" (powerlevel10k)
PROMPT_ENGINE="omp"

choose_prompt_engine() {
  info "Elegí el motor de prompt:"
  echo "  1) oh-my-posh   (tema probua.minimal, por defecto)"
  echo "  2) powerlevel10k (config interactiva en el primer arranque)"
  local choice
  read -rp "Opción [1/2] (default 1): " choice
  case "$choice" in
    2) PROMPT_ENGINE="p10k" ;;
    *) PROMPT_ENGINE="omp" ;;
  esac
  info "Motor seleccionado: $PROMPT_ENGINE"
}

install_prompt_engine() {
  case "$PROMPT_ENGINE" in
    omp)  install_oh_my_posh ;;
    p10k) install_powerlevel10k ;;
  esac
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

# ─── POWERLEVEL10K ─────────────────────────────────────────

install_powerlevel10k() {
  local p10k_manual="$HOME/.local/share/zsh/plugins/powerlevel10k"

  case "$DISTRO_FAMILY" in
    arch)
      info "Instalando powerlevel10k via pacman..."
      sudo pacman -S --needed --noconfirm zsh-theme-powerlevel10k
      ;;
    debian)
      info "Instalando powerlevel10k via brew..."
      brew list powerlevel10k &>/dev/null \
        && warn "powerlevel10k ya instalado, omitiendo." \
        || brew install powerlevel10k
      ;;
    *)
      # Fedora y fallback: clonar manualmente (no empaquetado)
      if [[ -d "$p10k_manual" ]]; then
        warn "powerlevel10k ya clonado en $p10k_manual"
        return
      fi
      info "Clonando powerlevel10k en $p10k_manual..."
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_manual"
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

  # Marcador de motor de prompt — leído por .zshrc
  mkdir -p "$HOME/.config/zsh"
  echo "$PROMPT_ENGINE" > "$HOME/.config/zsh/prompt-engine"
  info "Motor de prompt registrado: $HOME/.config/zsh/prompt-engine ($PROMPT_ENGINE)"
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

  local fallback_version="v3.3.0"
  local version
  version="$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest 2>/dev/null \
    | grep -m1 '"tag_name"' | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')" || true
  if [[ -z "$version" ]]; then
    version="$fallback_version"
    warn "No se pudo detectar la última versión, usando fallback: $version"
  else
    info "Última versión detectada: $version"
  fi

  info "Descargando JetBrainsMono Nerd Font $version..."
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

# ─── CLI FLAGS ──────────────────────────────────────────────

usage() {
  echo ""
  info "FSX Dotfiles — Uso"
  echo ""
  echo "  ./install.sh              Instalar todo"
  echo "  ./install.sh --dry-run    Mostrar qué se haría sin ejecutar"
  echo "  ./install.sh --uninstall  Eliminar symlinks creados"
  echo "  ./install.sh --doctor     Verificar estado de la instalación"
  echo "  ./install.sh --help       Mostrar este mensaje"
  echo ""
}

dry_run() {
  detect_distro
  echo ""
  info "Modo dry-run — no se realizarán cambios"
  echo ""

  local -a pairs=(
    "$DOTFILES_DIR/zsh/.zshrc|$HOME/.zshrc"
    "$DOTFILES_DIR/nvim|$HOME/.config/nvim"
    "$DOTFILES_DIR/kitty/kitty.conf|$HOME/.config/kitty/kitty.conf"
    "$DOTFILES_DIR/kitty/kanagawa.conf|$HOME/.config/kitty/current-theme.conf"
    "$DOTFILES_DIR/fastfetch/config.jsonc|$HOME/.config/fastfetch/config.jsonc"
  )

  for pair in "${pairs[@]}"; do
    local src="${pair%%|*}"
    local dest="${pair##*|}"
    info "[DRY-RUN] $src → $dest"
  done
}

uninstall() {
  info "Desinstalando symlinks..."

  local -a targets=(
    "$HOME/.zshrc"
    "$HOME/.config/nvim"
    "$HOME/.config/kitty/kitty.conf"
    "$HOME/.config/kitty/current-theme.conf"
    "$HOME/.config/fastfetch/config.jsonc"
  )

  local removed=0
  for target in "${targets[@]}"; do
    if [[ -L "$target" ]]; then
      local real
      real="$(readlink -f "$target")"
      if [[ "$real" == "$DOTFILES_DIR"/* ]]; then
        rm "$target"
        info "Eliminado: $target"
        ((removed++))
      else
        warn "Symlink no apunta a dotfiles, omitido: $target → $real"
      fi
    fi
  done

  if [[ "$removed" -eq 0 ]]; then
    warn "No se encontraron symlinks para eliminar"
  else
    info "$removed symlink(s) eliminado(s)"
  fi
}

doctor() {
  info "FSX Dotfiles — Doctor"
  echo ""

  local passed=0
  local total=0

  check_pass() { echo -e "${GREEN}  ✓ $1${NC}"; passed=$((passed + 1)); total=$((total + 1)); }
  check_fail() { echo -e "${RED}  ✗ $1${NC}"; total=$((total + 1)); }

  # 1. Symlinks
  info "Symlinks:"
  local -a symlink_checks=(
    "$DOTFILES_DIR/zsh/.zshrc|$HOME/.zshrc"
    "$DOTFILES_DIR/nvim|$HOME/.config/nvim"
    "$DOTFILES_DIR/kitty/kitty.conf|$HOME/.config/kitty/kitty.conf"
    "$DOTFILES_DIR/kitty/kanagawa.conf|$HOME/.config/kitty/current-theme.conf"
    "$DOTFILES_DIR/fastfetch/config.jsonc|$HOME/.config/fastfetch/config.jsonc"
  )

  for pair in "${symlink_checks[@]}"; do
    local src="${pair%%|*}"
    local dest="${pair##*|}"
    if [[ -L "$dest" ]] && [[ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]]; then
      check_pass "$dest → $src"
    else
      check_fail "$dest → $src"
    fi
  done
  echo ""

  # 2. Required tools
  info "Herramientas requeridas:"
  local -a tools=(zsh nvim git curl fzf zoxide lsd bat btop rg fastfetch)
  for tool in "${tools[@]}"; do
    if command -v "$tool" &>/dev/null; then
      check_pass "$tool"
    else
      check_fail "$tool"
    fi
  done
  echo ""

  # 3. Prompt engine
  info "Motor de prompt:"
  local engine_file="$HOME/.config/zsh/prompt-engine"
  if [[ -f "$engine_file" ]]; then
    local engine
    engine="$(cat "$engine_file")"
    local engine_bin
    case "$engine" in
      omp)  engine_bin="oh-my-posh" ;;
      p10k) engine_bin="p10k" ;;
      *)    engine_bin="$engine" ;;
    esac
    if command -v "$engine_bin" &>/dev/null; then
      check_pass "$engine ($engine_bin encontrado)"
    else
      check_fail "$engine ($engine_bin no encontrado)"
    fi
  else
    check_fail "Archivo prompt-engine no encontrado"
  fi
  echo ""

  # 4. Nerd Font
  info "Nerd Font:"
  if fc-list 2>/dev/null | grep -qi "JetBrainsMono.*Nerd"; then
    check_pass "JetBrainsMono Nerd Font"
  else
    check_fail "JetBrainsMono Nerd Font"
  fi
  echo ""

  # 5. Zsh default shell
  info "Shell por defecto:"
  if [[ "$SHELL" == *zsh ]]; then
    check_pass "zsh ($SHELL)"
  else
    check_fail "zsh no es la shell por defecto ($SHELL)"
  fi
  echo ""

  # Summary
  echo -e "${GREEN}──────────────────────────────────────────────${NC}"
  if [[ "$passed" -eq "$total" ]]; then
    info "$passed/$total verificaciones pasaron ✓"
  else
    warn "$passed/$total verificaciones pasaron"
  fi
}

# ─── RUN ────────────────────────────────────────────────────

case "${1:-}" in
  --dry-run)   dry_run ;;
  --uninstall) uninstall ;;
  --doctor)    doctor ;;
  --help|-h)   usage ;;
  "")          main ;;
  *)           error "Opción desconocida: $1. Usá --help." ;;
esac
