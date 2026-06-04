# ============================================================
# Fedora
# Aliases y funciones específicas de dnf
# ============================================================

# Package management
alias actualizar='sudo dnf upgrade --refresh'
alias instalar='sudo dnf install'
alias buscar='dnf search'
alias pinfo='dnf info'
alias desinstalar='sudo dnf remove'

# DNF shortcuts
alias dnfl='dnf list installed'
alias dnfh='dnf history'
alias dnfhi='dnf history info'
alias dnfclean='sudo dnf autoremove && sudo dnf clean all'
alias dnfprovides='dnf provides'
alias dnfrepo='dnf repolist'

# ─── command-not-found (PackageKit) ─────────────────────────

if [[ -f /etc/profile.d/PackageKit.sh ]]; then
  source /etc/profile.d/PackageKit.sh
fi
