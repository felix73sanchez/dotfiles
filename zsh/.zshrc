# ============================================================
#                       FSX
#                  .zshrc — Dev config
#         oh-my-posh + autocompletado + historial
# ============================================================

# ============================================================
# PATH
# ============================================================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"

# Homebrew (Linuxbrew)
if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ============================================================
# PLUGINS — fpath ANTES de compinit
# ============================================================

# zsh-completions
[[ -d "$HOMEBREW_PREFIX/opt/zsh-completions/share/zsh-completions" ]] && \
  fpath=("$HOMEBREW_PREFIX/opt/zsh-completions/share/zsh-completions" $fpath)

# ============================================================
# AUTOCOMPLETADO
# ============================================================
autoload -Uz compinit
compinit

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

# Cache para comandos pesados
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"

# ============================================================
# PLUGINS — source después de compinit
# ============================================================

# zsh-autosuggestions
[[ -f "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && \
  source "$HOMEBREW_PREFIX/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c6c6c'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
bindkey '^ ' autosuggest-accept

# zsh-syntax-highlighting — siempre al final
[[ -f "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$HOMEBREW_PREFIX/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ============================================================
# OH-MY-POSH
# ============================================================
if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config "$HOME/.cache/oh-my-posh/themes/probua.minimal.omp.json")"
fi

# ============================================================
# HISTORIAL DE COMANDOS
# ============================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS

# ============================================================
# OPCIONES GENERALES
# ============================================================
setopt AUTO_CD
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt IGNORE_EOF             # Evita cerrar shell con Ctrl+D

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

# ============================================================
# VARIABLES DE ENTORNO
# ============================================================
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R --use-color"

# ============================================================
# ALIASES — Navegacion
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
alias lf='lsd -lah | grep "^-"'
alias vi='nvim'

command -v bat  &>/dev/null && alias cat='bat --style=plain'
command -v btop &>/dev/null && alias top='btop'

# ============================================================
# ALIASES — Seguridad
# ============================================================
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv --preserve-root'
alias rmd='rm -rf'
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
alias actualizar='sudo apt update && sudo apt upgrade -y'
alias apagar='sudo shutdown -h now'

# ============================================================
# ALIASES — Servidores
# ============================================================
alias mirtha='ssh fsxserver@10.0.0.73'
alias code='flatpak run com.visualstudio.code'

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
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.tar.xz)  tar xJf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.gz)      gunzip "$1"  ;;
      *.tar)     tar xf "$1"  ;;
      *.zip)     unzip "$1"   ;;
      *.7z)      7z x "$1"    ;;
      *.zst)     zstd -d "$1" ;;
      *.rar)     unrar x "$1" ;;
      *)         echo "'$1' formato no reconocido" ;;
    esac
  else
    echo "'$1' no es un archivo valido"
  fi
}

# ============================================================
# FZF
# ============================================================
if command -v fzf &>/dev/null; then
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=dark'
fi

# ============================================================
# ZOXIDE — reemplaza cd con historial inteligente
# ============================================================
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"

# ============================================================
# BUN
# ============================================================
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"
