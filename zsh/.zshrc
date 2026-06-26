# ============================================================
#                       FSX
#                  .zshrc — Multi-Distro Dev Config
#       oh-my-posh + autocompletado + historial + plugins
# ============================================================

# Deduplicar PATH y fpath (previene crecimiento en subshells y reloads)
typeset -U PATH path fpath

# ============================================================
# DOTFILES_DIR — resolve from symlink
# ============================================================
if [[ -L "$HOME/.zshrc" ]]; then
  _zshrc_real="$(readlink -f "$HOME/.zshrc")"
  DOTFILES_DIR="$(dirname "$(dirname "$_zshrc_real")")"
  unset _zshrc_real
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
# PROMPT ENGINE — selector escrito por install.sh
#   omp  = oh-my-posh (default) | p10k = powerlevel10k
# ============================================================
_fsx_prompt_engine="omp"
[[ -r "$XDG_CONFIG_HOME/zsh/prompt-engine" ]] && \
  read -r _fsx_prompt_engine < "$XDG_CONFIG_HOME/zsh/prompt-engine"

# powerlevel10k instant prompt — debe ir lo más temprano posible.
# Inofensivo si el cache no existe (usuarios de oh-my-posh).
if [[ "$_fsx_prompt_engine" == "p10k" ]]; then
  _p10k_instant="$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
  [[ -r "$_p10k_instant" ]] && source "$_p10k_instant"
  unset _p10k_instant
fi

# ============================================================
# DISTRO DETECTION
# ============================================================
_fsx_distro_id=$(grep -oP '^ID=\K\w+' /etc/os-release 2>/dev/null)
case "$_fsx_distro_id" in
  arch|cachyos|endeavouros|manjaro) _fsx_distro_family="arch"    ;;
  fedora)                           _fsx_distro_family="fedora"  ;;
  debian|ubuntu|pop|linuxmint|zorin) _fsx_distro_family="debian" ;;
  *)                                _fsx_distro_family="unknown" ;;
esac

# ============================================================
# PATH
# ============================================================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"

# Homebrew — solo si está instalado (típicamente en Debian)
if [[ -d /home/linuxbrew/.linuxbrew ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX/Homebrew"
  export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
  export MANPATH="$HOMEBREW_PREFIX/share/man:${MANPATH:-}"
  export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
elif [[ -d /opt/homebrew ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
  export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
  export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
  export MANPATH="$HOMEBREW_PREFIX/share/man:${MANPATH:-}"
  export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
fi

# ============================================================
# PLUGIN RESOLUTION — multi-path
# Busca el plugin en las rutas conocidas de cada distro/método
# ============================================================
_source_plugin() {
  local name="$1"
  local paths=(
    "/usr/share/zsh/plugins/$name/$name.zsh"                                 # Arch/CachyOS
    "/usr/share/$name/$name.zsh"                                             # Fedora
    "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/opt/$name/share/$name/$name.zsh}"    # Homebrew
    "$HOME/.local/share/zsh/plugins/$name/$name.zsh"                         # Manual
  )
  for p in "${paths[@]}"; do
    [[ -n "$p" && -f "$p" ]] && { source "$p"; return 0; }
  done
  return 1
}

# ============================================================
# PLUGINS — fpath ANTES de compinit
# ============================================================
for _comp_dir in \
  "/usr/share/zsh/site-functions" \
  "/usr/share/zsh-completions" \
  "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/opt/zsh-completions/share/zsh-completions}" \
; do
  [[ -n "$_comp_dir" && -d "$_comp_dir" ]] && fpath=("$_comp_dir" $fpath)
done
unset _comp_dir

# ============================================================
# AUTOCOMPLETADO
# ============================================================
autoload -Uz compinit

# Cache compinit — solo regenera si el dump tiene más de 24h
_zcompdump="$XDG_CACHE_HOME/zsh/zcompdump-${ZSH_VERSION}"
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"

if [[ -n "$_zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' rehash true
zstyle ':completion::complete:*' gain-privileges 1

# Corrección de errores leve
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*:correct:*' original true

# Case-insensitive + matching inteligente
zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=* l:|=*'

# Mejora autocompletado kill
zstyle ':completion:*:*:kill:*' command \
  'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# Cache para comandos pesados
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"

# ============================================================
# PLUGINS — source después de compinit
# ============================================================

# zsh-autosuggestions config (ANTES del source para que el plugin las tome)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c6c6c'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

_source_plugin zsh-autosuggestions
bindkey '^ ' autosuggest-accept

# history-substring-search (disponible en Arch, opcional en otras distros)
_source_plugin zsh-history-substring-search

# NOTA: zsh-syntax-highlighting se sourcea al FINAL del archivo,
# después de fzf/zoxide, para que envuelva todos los widgets ZLE.

# ============================================================
# PROMPT — oh-my-posh | powerlevel10k (según _fsx_prompt_engine)
# ============================================================
if [[ "$_fsx_prompt_engine" == "p10k" ]]; then
  # powerlevel10k — resolución multi-path del tema
  #   /usr/share/...            → Arch (pacman)
  #   $HOMEBREW_PREFIX/share/... → Debian (brew)
  #   ~/.local/share/...         → Fedora / clone manual
  for _p10k_theme in \
    "/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme" \
    "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme}" \
    "$HOME/.local/share/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme" \
  ; do
    [[ -n "$_p10k_theme" && -f "$_p10k_theme" ]] && { source "$_p10k_theme"; break; }
  done
  unset _p10k_theme
  # Config del usuario; si falta, p10k lanza el wizard en el primer arranque.
  [[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
else
  # oh-my-posh — cached init
  _omp_cache="$XDG_CACHE_HOME/oh-my-posh/init.zsh"
  _omp_config="$DOTFILES_DIR/oh-my-posh/probua.minimal.omp.json"
  if command -v oh-my-posh >/dev/null 2>&1; then
    if [[ ! -f "$_omp_cache" || "$_omp_config" -nt "$_omp_cache" ]]; then
      mkdir -p "$(dirname "$_omp_cache")"
      oh-my-posh init zsh --config "$_omp_config" > "$_omp_cache"
    fi
    source "$_omp_cache"
  fi
  unset _omp_cache _omp_config
fi
unset _fsx_prompt_engine

# ============================================================
# HISTORIAL DE COMANDOS
# ============================================================
HISTFILE="$XDG_STATE_HOME/zsh/history"
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
# setopt SHARE_HISTORY         # Descomentar si querés historial compartido entre terminales
setopt EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # Expande comando del historial antes de ejecutar

# ============================================================
# OPCIONES GENERALES
# ============================================================
setopt AUTO_CD
setopt AUTO_PUSHD            # cd apila el dir en la pila
setopt PUSHD_IGNORE_DUPS     # no apila duplicados
setopt PUSHD_SILENT          # no imprime la pila en cada pushd/popd
setopt CORRECT
SPROMPT='¿Quisiste decir %F{green}%r%f en vez de %F{red}%R%f? [sí(y)/no(n)/editar(e)/abortar(a)] '
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt IGNORE_EOF             # Evita cerrar shell con Ctrl+D
setopt MULTIOS                # Permite redirección múltiple: echo foo > a > b
setopt PROMPT_SUBST           # Permite expansión en prompts
setopt LONG_LIST_JOBS         # Muestra PID en listado de jobs
setopt AUTO_RESUME            # Resume jobs en background con solo el nombre

# ============================================================
# KEYBINDINGS
# ============================================================
bindkey '^[[A'    history-beginning-search-backward
bindkey '^[[B'    history-beginning-search-forward
bindkey '^R'      history-incremental-search-backward
bindkey '^[[H'    beginning-of-line
bindkey '^[[F'    end-of-line
bindkey '^[[3~'   delete-char
bindkey '^H'      backward-kill-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Editar el comando actual en $EDITOR con Ctrl-X Ctrl-E
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# history-substring-search keybindings (si el plugin está cargado)
if (( $+widgets[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^P'   history-substring-search-up
  bindkey '^N'   history-substring-search-down
fi

# ============================================================
# VARIABLES DE ENTORNO
# ============================================================
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R --use-color -i -J -W"

# ============================================================
# ALIASES — Navegación
# ============================================================
alias c='clear'
alias ls='lsd --group-directories-first'
alias ll='lsd -lah --group-directories-first'
alias la='lsd -A'
alias lt='lsd -lah --timesort'
alias lsize='lsd -lah --sizesort'
alias tree='lsd --tree'
alias tree2='lsd --tree --depth 2'
alias ld='lsd -d */'
alias lld='lsd -lah -d */'
alias ldir='lsd --directory-only'
alias vi='nvim'

command -v bat  &>/dev/null && alias cat='bat --style=plain'
command -v btop &>/dev/null && alias top='btop'

# ============================================================
# ALIASES — Seguridad
# ============================================================
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv'
alias rmd='rm -rfI'
alias mkdir='mkdir -pv'

# ============================================================
# ALIASES — Sistema
# ============================================================
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias myip='curl -s ifconfig.me && echo'
alias ports='ss -tulpn'
alias ping='ping -c 5'
alias h='history'
alias hg='history | grep'
alias grep='grep --color=auto'
alias reload='source ~/.zshrc && echo "zshrc recargado"'
alias zshconfig='nvim ~/.zshrc'
alias apagar='sudo shutdown -h now'
alias reiniciar='sudo reboot'

# ============================================================
# ALIASES — Systemd (común a todas las distros)
# ============================================================
alias ss-start='sudo systemctl start'
alias ss-stop='sudo systemctl stop'
alias ss-restart='sudo systemctl restart'
alias ss-status='systemctl status'
alias ss-enable='sudo systemctl enable'
alias ss-disable='sudo systemctl disable'
alias ss-failed='systemctl --failed'
alias ss-logs='journalctl -xe'
alias ss-boot='journalctl -b'

# ============================================================
# ALIASES — Servidores
# ============================================================
alias mirtha='ssh fsxserver@10.0.0.73'

# ============================================================
# ALIASES — Git
# ============================================================
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gco='git checkout'
alias gb='git branch'
alias gba='git branch -a'
alias gst='git stash'
alias gstp='git stash pop'

# ============================================================
# FUNCIONES
# ============================================================
mkcd()      { mkdir -p "$1" && cd "$1" }
fh()        { history | grep --color=auto "$1" }
gclone()    { git clone "$1" && cd "$(basename "$1" .git)" }
bak()       { cp "$1"{,.bak} && echo "Backup: $1.bak" }
whichport() { ss -tulpn | grep ":$1" }

extract() {
  if [[ -f "$1" ]]; then
    case $1 in
      *.tar.bz2)  tar xjf "$1" ;;
      *.tar.gz)   tar xzf "$1" ;;
      *.tar.xz)   tar xJf "$1" ;;
      *.tar.zst)  tar --zstd -xf "$1" ;;
      *.bz2)      bunzip2 "$1" ;;
      *.gz)       gunzip "$1"  ;;
      *.tar)      tar xf "$1"  ;;
      *.zip)      unzip "$1"   ;;
      *.7z)       7z x "$1"    ;;
      *.zst)      zstd -d "$1" ;;
      *.rar)      unrar x "$1" ;;
      *.pkg.tar*) echo "Paquete pacman — usá: sudo pacman -U '$1'" ;;
      *)          echo "'$1' formato no reconocido" ;;
    esac
  else
    echo "'$1' no es un archivo válido"
  fi
}

# ============================================================
# DISTRO-SPECIFIC — carga módulo según la distro detectada
# ============================================================
if [[ -f "$DOTFILES_DIR/zsh/distro/${_fsx_distro_family}.zsh" ]]; then
  source "$DOTFILES_DIR/zsh/distro/${_fsx_distro_family}.zsh"
fi
unset _fsx_distro_id _fsx_distro_family

# ============================================================
# FZF
# ============================================================
if command -v fzf &>/dev/null; then
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=dark'
  # Preview: archivos con bat, directorios con lsd
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {} 2>/dev/null || lsd --tree --color=always {} 2>/dev/null'"
  export FZF_ALT_C_OPTS="--preview 'lsd --tree --color=always {} 2>/dev/null | head -100'"

  # Keybindings + completions (Ctrl+R, Ctrl+T, Alt+C)
  source <(fzf --zsh 2>/dev/null) || {
    # Fallback para fzf < 0.48
    for _fzf_dir in \
      "/usr/share/fzf" \
      "${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/opt/fzf/shell}" \
    ; do
      if [[ -n "$_fzf_dir" && -d "$_fzf_dir" ]]; then
        [[ -f "$_fzf_dir/key-bindings.zsh" ]] && source "$_fzf_dir/key-bindings.zsh"
        [[ -f "$_fzf_dir/completion.zsh" ]]   && source "$_fzf_dir/completion.zsh"
        break
      fi
    done
    unset _fzf_dir
  }

  # Usar fd si está disponible (más rápido que find, respeta .gitignore)
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
fi

# ============================================================
# ZOXIDE — reemplaza cd con historial inteligente
# ============================================================
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"

# ============================================================
# BUN
# ============================================================
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
fi

# ============================================================
# LOCAL OVERRIDES — personal config not tracked by git
# Copy zsh/local.zsh.example → zsh/local.zsh to customize
# ============================================================
[[ -f "$DOTFILES_DIR/zsh/local.zsh" ]] && source "$DOTFILES_DIR/zsh/local.zsh"

# ============================================================
# ZSH-SYNTAX-HIGHLIGHTING — SIEMPRE AL FINAL
# Debe cargarse después de todo lo que registra widgets ZLE (fzf, etc.)
# ============================================================
_source_plugin zsh-syntax-highlighting
