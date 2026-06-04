# ============================================================
# Arch Linux / CachyOS / EndeavourOS
# Aliases y funciones específicas de pacman
# ============================================================

# Package manager — paru > yay > pacman
if command -v paru &>/dev/null; then
  alias actualizar='paru -Syu'
  alias instalar='paru -S'
  alias buscar='paru -Ss'
  alias pinfo='paru -Si'
  alias desinstalar='paru -Rns'
elif command -v yay &>/dev/null; then
  alias actualizar='yay -Syu'
  alias instalar='yay -S'
  alias buscar='yay -Ss'
  alias pinfo='yay -Si'
  alias desinstalar='yay -Rns'
else
  alias actualizar='sudo pacman -Syu'
  alias instalar='sudo pacman -S'
  alias buscar='pacman -Ss'
  alias pinfo='pacman -Si'
  alias desinstalar='sudo pacman -Rns'
fi

# Pacman shortcuts
alias pac='sudo pacman'
alias pacq='pacman -Q'
alias pacqe='pacman -Qe'
alias pacqi='pacman -Qi'
alias pacql='pacman -Ql'
alias pacown='pacman -Qo'
alias pacorph='pacman -Qtdq'
alias pacclean='sudo pacman -Rns $(pacman -Qtdq)'
alias paccache='sudo paccache -rk2'
alias paclog='grep -i "installed\|upgraded\|removed" /var/log/pacman.log | tail -30'

# CachyOS specific
command -v cachyos-rate-mirrors &>/dev/null && alias mirrors='sudo cachyos-rate-mirrors'

# ─── Funciones Arch ─────────────────────────────────────────

# Qué paquete provee un comando
whatpkg() {
  if [[ -n "$1" ]]; then
    local bin
    bin="$(command -v "$1" 2>/dev/null)"
    if [[ -n "$bin" ]]; then
      pacman -Qo "$bin"
    else
      echo "Command '$1' not found in PATH"
    fi
  else
    echo "Usage: whatpkg <command>"
  fi
}

# Buscar .pacnew y .pacsave
pacnews() {
  find /etc -name '*.pacnew' -o -name '*.pacsave' 2>/dev/null
}

# ─── command-not-found (pkgfile) ────────────────────────────

if [[ -f /usr/share/doc/pkgfile/command-not-found.zsh ]]; then
  source /usr/share/doc/pkgfile/command-not-found.zsh
elif command -v pkgfile &>/dev/null; then
  command_not_found_handler() {
    local pkgs
    pkgs=$(pkgfile -b -- "$1" 2>/dev/null)
    if [[ -n "$pkgs" ]]; then
      echo "'$1' is not installed. Provided by:" >&2
      echo "$pkgs" | sed 's/^/  /' >&2
    else
      echo "zsh: command not found: $1" >&2
    fi
    return 127
  }
fi
