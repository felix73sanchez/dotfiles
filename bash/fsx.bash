# ============================================================
#                       FSX
#              bash/fsx.bash — Omarchy add-on
#
# This file is SOURCED from ~/.bashrc via a clearly marked,
# additive block appended by `install.sh --omarchy`.
# It NEVER replaces Omarchy's ~/.bashrc and is fully additive:
#   - No prompt engine changes (Omarchy keeps Starship)
#   - No chsh / default-shell change
#   - No nvim / fastfetch / kitty / alacritty / font changes
# ============================================================

# Resolve DOTFILES_DIR from the location of this file
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  _fsx_bash_real="$(readlink -f "${BASH_SOURCE[0]}")"
  DOTFILES_DIR="$(dirname "$(dirname "$_fsx_bash_real")")"
  unset _fsx_bash_real
else
  DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
fi
export DOTFILES_DIR

# ============================================================
# XDG Base Directories
# ============================================================
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# ============================================================
# PATH
# ============================================================
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
  *":$HOME/.dotnet/tools:"*) ;;
  *) export PATH="$HOME/.dotnet/tools:$PATH" ;;
esac

# Homebrew — activate via shellenv only if the binary exists (no errors when absent)
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# BUN
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
fi

# ============================================================
# BASH COMPLETION
# ============================================================
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
elif [[ -f /etc/bash_completion ]]; then
  source /etc/bash_completion
fi

# ============================================================
# HISTORY — size + no duplicates (bash equivalent of zsh opts)
# ============================================================
export HISTFILE="${HISTFILE:-$XDG_STATE_HOME/bash/history}"
[[ -d "$(dirname "$HISTFILE")" ]] || mkdir -p "$(dirname "$HISTFILE")"
export HISTSIZE=50000
export HISTFILESIZE=50000
export HISTCONTROL=ignoredups:erasedups:ignorespace
export HISTIGNORE="ls:ll:la:lt:lsize:clear:history"
shopt -s histappend
shopt -s cmdhist
shopt -s cdspell
shopt -s checkwinsize

# ============================================================
# ENVIRONMENT VARIABLES
# ============================================================
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-nvim}"
export PAGER="less"
export LESS="-R --use-color -i -J -W"

# ============================================================
# ALIASES — Navigation
# Omarchy defaults to eza, so ls family maps to eza
# ============================================================
alias c='clear'
if command -v eza &>/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --group-directories-first'
  alias la='eza -A'
  alias lt='eza -lah --sort=modified'
  alias lsize='eza -lah --sort=size'
  alias tree='eza --tree'
  alias tree2='eza --tree --level=2'
  alias ld='eza -d */'
  alias lld='eza -lah -d */'
elif command -v lsd &>/dev/null; then
  alias ls='lsd --group-directories-first'
  alias ll='lsd -lah --group-directories-first'
  alias la='lsd -A'
  alias lt='lsd -lah --timesort'
  alias lsize='lsd -lah --sizesort'
  alias tree='lsd --tree'
  alias tree2='lsd --tree --depth 2'
  alias ld='lsd -d */'
  alias lld='lsd -lah -d */'
fi
alias vi='nvim'

command -v bat  &>/dev/null && alias cat='bat --style=plain'
command -v btop &>/dev/null && alias top='btop'

# Aliases — Safety
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias rmd='rm -rfI'
alias mkdir='mkdir -pv'

# Aliases — System
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias myip='curl -s ifconfig.me && echo'
alias ports='ss -tulpn'
alias ping='ping -c 5'
alias h='history'
alias hg='history | grep'
alias grep='grep --color=auto'
alias reload='source ~/.bashrc'
alias bashconfig='${EDITOR:-nvim} ~/.bashrc'
alias apagar='systemctl poweroff'
alias reiniciar='sudo reboot'

# Aliases — Systemd
alias ss-start='sudo systemctl start'
alias ss-stop='sudo systemctl stop'
alias ss-restart='sudo systemctl restart'
alias ss-status='systemctl status'
alias ss-enable='sudo systemctl enable'
alias ss-disable='sudo systemctl disable'
alias ss-failed='systemctl --failed'
alias ss-logs='journalctl -xe'
alias ss-boot='journalctl -b'

# Aliases — Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gi='git init'
alias gm='git merge'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch -a'
alias gst='git stash'
alias gstp='git stash pop'

# ============================================================
# FUNCTIONS
# ============================================================
mkcd()      { mkdir -p "$1" && cd "$1" || return; }
fh()        { history | grep --color=auto "$1"; }
gclone()    { git clone "$1" && cd "$(basename "$1" .git)" || return; }
bak()       { cp "$1"{,.bak} && echo "Backup: $1.bak"; }
whichport() { ss -tulpn | grep ":$1"; }

extract() {
  if [[ -f "$1" ]]; then
    case $1 in
      *.tar.bz2)  tar xjf "$1" ;;
      *.tar.gz)   tar xzf "$1" ;;
      *.tar.xz)   tar xJf "$1" ;;
      *.tar.zst)  tar --zstd -xf "$1" ;;
      *.bz2)      bunzip2 "$1" ;;
      *.gz)       gunzip "$1" ;;
      *.tar)      tar xf "$1" ;;
      *.zip)      unzip "$1" ;;
      *.7z)       7z x "$1" ;;
      *.zst)      zstd -d "$1" ;;
      *.rar)      unrar x "$1" ;;
      *.pkg.tar*) echo "Pacman package — use: sudo pacman -U '$1'" ;;
      *)          echo "'$1' unrecognized format" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# ============================================================
# ARCH PACKAGE ALIASES (Omarchy is Arch-based)
# ============================================================
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

alias pac='sudo pacman'
alias pacq='pacman -Q'
alias pacqe='pacman -Qe'
alias pacqi='pacman -Qi'
alias pacql='pacman -Ql'
alias pacown='pacman -Qo'
alias pacorph='pacman -Qtdq'
alias paccache='sudo paccache -rk2'
alias paclog='grep -i "installed\|upgraded\|removed" /var/log/pacman.log | tail -30'

pacclean() {
  local orphs
  orphs=$(pacman -Qtdq 2>/dev/null)
  if [[ -n "$orphs" ]]; then
    echo "$orphs" | sudo pacman -Rns -
  else
    echo "No orphan packages found."
  fi
}

whatpkg() {
  if [[ -n "${1:-}" ]]; then
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

pacnews() {
  find /etc \( -name '*.pacnew' -o -name '*.pacsave' \) 2>/dev/null
}

# ============================================================
# FZF (bash bindings)
# ============================================================
if command -v fzf &>/dev/null; then
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=dark'
  if command -v bat &>/dev/null && command -v eza &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || eza --tree --color=always {} 2>/dev/null'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} 2>/dev/null | head -100'"
  fi
  if fzf --bash &>/dev/null; then
    eval "$(fzf --bash)"
  else
    for _fzf_dir in /usr/share/fzf /usr/share/bash-completion/completions; do
      [[ -f "$_fzf_dir/key-bindings.bash" ]] && source "$_fzf_dir/key-bindings.bash" && break
    done
    unset _fzf_dir
  fi
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
fi

# ============================================================
# ZOXIDE — smart cd replacement
# ============================================================
command -v zoxide &>/dev/null && eval "$(zoxide init bash --cmd cd)"

# ============================================================
# LOCAL OVERRIDES — personal config not tracked by git
# Copy bash/local.bash.example → bash/local.bash to customize
# ============================================================
[[ -f "$DOTFILES_DIR/bash/local.bash" ]] && source "$DOTFILES_DIR/bash/local.bash"
