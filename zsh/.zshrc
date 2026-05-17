# ============================================================
#                       FSX
#                  .zshrc — Dev config
#         oh-my-posh + autocompletado + historial
#         -----------------Dependencias-----------------------
#         -  # Herramientas principales
#         -    brew install oh-my-posh lsd neovim bat btop fzf zoxide
#         -
#         -   # Plugins zsh
#         -    brew install zsh-autosuggestions zsh-syntax-highlighting zsh-completions 
#         -  
#         ------------------------------------------------------
# ============================================================

# --- PATH ---
export PATH=$PATH:$HOME/.local/bin
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="$HOME/.dotnet/tools:$PATH"


# --- OH-MY-POSH ---
#eval "$(oh-my-posh init zsh)"

if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config /home/fsx/.cache/oh-my-posh/themes/probua.minimal.omp.json)"
fi
# ============================================================
# HISTORIAL DE COMANDOS
# ============================================================
HISTFILE=$HOME/.zsh_history


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
# AUTOCOMPLETADO
# ============================================================
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion::complete:*' gain-privileges 1
#--------------------------
# Descripciones y formato
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
#zstyle ':completion:*' verbose true

# Corrección de errores leve
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*:correct:*' original true

# Menú interactivo con TAB
zstyle ':completion:*' menu select

# Case-insensitive + matching inteligente
zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=* l:|=*'

# Colores
#eval "$(dircolors -b)"
#zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Mejora autocompletado kill
zstyle ':completion:*:*:kill:*' command \
  'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Cache para comandos pesados
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache



#---------------------------
# ============================================================
# OPCIONES GENERALES
# ============================================================
setopt AUTO_CD
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt EXTENDED_GLOB
setopt GLOB_DOTS

# Evita cerrar shell con Ctrl+D
setopt ignoreeof

# ============================================================
# KEYBINDINGS
# ============================================================
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^R'   history-incremental-search-backward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^H'   backward-delete-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Ctrl+Backspace para borrar palabra anterior
bindkey '^H' backward-kill-word


# ============================================================
# PLUGINS
# ============================================================

# zsh-completions — cargar ANTES de compinit
[ -d /home/linuxbrew/.linuxbrew/opt/zsh-completions/share/zsh-completions ] && \
  fpath=(/home/linuxbrew/.linuxbrew/opt/zsh-completions/share/zsh-completions $fpath)

# zsh-autosuggestions
[ -f /home/linuxbrew/.linuxbrew/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /home/linuxbrew/.linuxbrew/opt/zsh-autosuggestions/share/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c6c6c'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
bindkey '^ ' autosuggest-accept

# zsh-syntax-highlighting — siempre al final de los plugins
[ -f /home/linuxbrew/.linuxbrew/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /home/linuxbrew/.linuxbrew/opt/zsh-syntax-highlighting/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ============================================================
# VARIABLES DE ENTORNO
# ============================================================
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R --use-color"

# ============================================================
# ALIASES -- Navegacion
# ============================================================

alias c='clear'
alias ls='lsd --group-directories-first'
alias ll='lsd -lah --group-directories-first'
alias la='lsd -A'
alias lt='lsd -lah --timesort'  # Ordenar por fecha
alias lsize='lsd -lah --sizesort'  # Ordenar por tamaño
alias tree='lsd --tree'
alias tree2='lsd --tree --depth 2'

# Listar solo directorios
alias ld='lsd -d */'                           # Solo directorios (simple)
alias lld='lsd -lah -d */'                     # Solo directorios (detallado)
alias ldir='lsd --directory-only'              # Solo directorios (alternativa)

# Bonus: solo archivos (sin directorios)
alias lf='lsd -lah | grep "^-"'                # Solo archivos
alias vi='nvim'

# Seguridad básica
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias rmd='rm -rf'


# Servidores
alias mirtha='ssh fsxserver@10.0.0.73'
alias code='flatpak run com.visualstudio.code'
alias apagar='shutdown -h now'

# ============================================================
# ALIASES -- Git
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
# ALIASES -- Utilidades
# ============================================================
alias grep='grep --color=auto'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -Iv --preserve-root'
alias mkdir='mkdir -pv'
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias myip='curl -s ifconfig.me && echo'
alias ports='ss -tulpn'
alias ping='ping -c 5'
alias c='clear'
alias h='history'
alias hg='history | grep'
alias reload='source ~/.zshrc && echo "zshrc recargado"'
alias zshconfig='nvim ~/.zshrc'
alias actualizar='sudo apt update && sudo apt upgrade -y'

command -v bat  &>/dev/null && alias cat='bat --style=plain'
command -v btop &>/dev/null && alias top='btop'

# ============================================================
# FUNCIONES
# ============================================================

mkcd()      { mkdir -p "$1" && cd "$1" }
fh()        { history | grep --color=auto "$1" }
gclone()    { git clone "$1" && cd "$(basename "$1" .git)" }
bak()       { cp "$1"{,.bak} && echo "Backup: $1.bak" }
whichport() { ss -tulpn | grep ":$1" }

extract() {
  if [ -f "$1" ]; then
    case $1 in
      *.tar.bz2)  tar xjf "$1"  ;;
      *.tar.gz)   tar xzf "$1"  ;;
      *.tar.xz)   tar xJf "$1"  ;;
      *.bz2)      bunzip2 "$1"  ;;
      *.gz)       gunzip "$1"   ;;
      *.tar)      tar xf "$1"   ;;
      *.zip)      unzip "$1"    ;;
      *.7z)       7z x "$1"     ;;
      *.zst)      zstd -d "$1"  ;;
      *.rar)      unrar x "$1"  ;;
      *)          echo "'$1' formato no reconocido" ;;
    esac
  else
    echo "'$1' no es un archivo valido"
  fi
}

# ============================================================
# FZF -- solo si esta instalado
# ============================================================
if command -v fzf &>/dev/null; then
#  source <(fzf) 2>/dev/null || true
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=dark'
fi

# ============================================================
# ZOXIDE -- solo si esta instalado
# ============================================================
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"


# bun completions
[ -s "/home/fsx/.bun/_bun" ] && source "/home/fsx/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias claude-mem='/home/fsx/.bun/bin/bun "/home/fsx/.claude/plugins/cache/thedotmack/claude-mem/12.1.0/scripts/worker-service.cjs"'
