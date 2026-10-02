# Feature: Omarchy bash support (--omarchy flag)

## Objective
Allow installing the FSX dotfiles stack on an Omarchy system without touching Omarchy defaults (bash shell, omarchy-nvim, starship, foot/alacritty, fastfetch, kitty, fonts).

## Problem
`install.sh` unconditionally: switches the default shell to zsh, symlinks `~/.zshrc`, replaces `~/.config/nvim`, `~/.config/fastfetch`, and `~/.config/kitty`, and installs oh-my-posh. On Omarchy this breaks the managed defaults.

## Scope
- New `--omarchy` flag in `install.sh`.
- Bash equivalents of the zsh setup under `bash/` (aliases, functions, history, completion), sourced from `~/.bashrc` via an additive include file — never replacing Omarchy's `~/.bashrc`.
- Install only additive shell packages (e.g. `bash-completion`, fzf/fd/rg/zoxide if missing — all additive, no config override).
- Meticulous per-decision confirmation before every mutation (ask per package group, per alias file, per symlink).
- NO default-shell change, NO nvim/fastfetch/kitty/alacritty config, NO oh-my-posh/starship changes, NO font changes.

## Constraints
- Never overwrite `~/.bashrc`; append a single guarded `source` line or a clearly marked block (Omarchy docs: `~/.bashrc` is never overwritten by updates — safe to extend).
- Every destructive-ish step must be skippable via interactive confirm.
- `--dry-run` must cover the omarchy path too.

## Tasks
1. Create `bash/` with aliases/functions/history/completion equivalents of `zsh/.zshrc` + `zsh/distro/arch.zsh` (Omarchy is Arch-based).
2. Add `--omarchy` path in `install.sh`: package list (bash-completion, fzf, fd, ripgrep, zoxide, btop, bat) with per-group confirms, symlink/append the bash include, no chsh, no visual configs.
3. Ensure interactive prompts ask minutely (each config decision as its own confirm).
4. Extend `--dry-run` and `--doctor` minimally for the omarchy path where applicable.

## Checks
- `bash -n install.sh bash/*.bash` syntax check
- `./install.sh --omarchy --dry-run` runs and lists actions without mutating
- Manual inspection that no `chsh`/nvim/fastfetch/kitty/omp code path runs under `--omarchy`

## TDD
- Mode: disabled (no test runner in this dotfiles repo; shell scripts validated via `bash -n` + dry-run)
- Source: inferred from repo contents (no test framework present) during routing
- Runner: none

## Route
- Route per task: delegated direct (writer trigger: 3+ non-trivial files). Writer delegated to a fresh general agent.

## Delivery strategy
- ask-on-risk (default); forecast: small, single PR

## Evidence
- Commit `8bd157c` on `feat/omarchy-bash-support` (+514/-8)
- Checks passed: `bash -n install.sh bash/fsx.bash`, `--omarchy --dry-run` exit 0, no chsh/omp/nvim/fastfetch/kitty in omarchy path
