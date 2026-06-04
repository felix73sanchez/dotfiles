# ============================================================
# Debian / Ubuntu
# Aliases y funciones específicas de apt
# ============================================================

# Package management
alias actualizar='sudo apt update && sudo apt upgrade -y'
alias instalar='sudo apt install'
alias buscar='apt search'
alias pinfo='apt show'
alias desinstalar='sudo apt remove'
alias purgar='sudo apt purge'

# APT shortcuts
alias aptl='dpkg -l'
alias aptclean='sudo apt autoremove -y && sudo apt autoclean'
alias aptfix='sudo apt --fix-broken install'

# VSCode via flatpak (common on Debian/Ubuntu)
command -v flatpak &>/dev/null && alias code='flatpak run com.visualstudio.code'

# ─── command-not-found ──────────────────────────────────────

if [[ -f /etc/zsh_command_not_found ]]; then
  source /etc/zsh_command_not_found
fi
