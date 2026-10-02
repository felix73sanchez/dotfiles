# FSX Dotfiles

Configuración personal de desarrollo para Linux, multi-distro y con dos caminos de instalación: el **normal** (zsh + oh-my-posh/p10k + nvim + kitty + fastfetch) y el **aditivo para Omarchy** (`--omarchy`, bash sin tocar los defaults de tu sistema).

**Distros soportadas (path normal):** Arch / CachyOS / EndeavourOS · Fedora · Debian / Ubuntu
**Path Omarchy:** cualquier sistema basado en Arch con Omarchy instalado.

---

## Instalación rápida

### Path normal (Arch/CachyOS, Fedora, Debian/Ubuntu)

```bash
git clone git@github.com:felix73sanchez/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh          # elegí prompt: 1) oh-my-posh  2) powerlevel10k
exec zsh
```

Al primer `nvim`, lazy.nvim instala los plugins solo. Después configurá la Nerd Font en tu terminal.

### Path Omarchy (`--omarchy`)

Pensado para **sumar** el stack FSX encima de Omarchy sin reemplazar nada. No cambia la shell por defecto, no toca nvim / fastfetch / kitty / alacritty / foot, no cambia el prompt (seguís con Starship) ni las fuentes.

```bash
git clone git@github.com:felix73sanchez/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --omarchy
exec bash             # o abrí una terminal nueva

# Verificá después:
./install.sh --omarchy --doctor
```

Cada decisión (cada grupo de paquetes, el bloque en `~/.bashrc`, brew+bbrew) pide su propia confirmación. Nada se toca sin que aceptes.

> ¿Querés ver el plan sin ejecutar nada? `./install.sh --omarchy --dry-run`

### Checklist post-instalación

- [ ] Terminal nueva abierta (`exec zsh` o `exec bash`)
- [ ] `./install.sh --doctor` (o `--omarchy --doctor`) sin ✗
- [ ] Nerd Font configurada en la terminal (solo path normal)
- [ ] `nvim` abierto una vez para que lazy.nvim instale plugins (solo path normal)

---

## Qué instala cada path

| Área | Path normal | Path Omarchy (`--omarchy`) |
|---|---|---|
| **Shell** | zsh + `chsh -s zsh` | bash (sin `chsh`, Omarchy sigue por defecto) |
| **Prompt** | oh-my-posh (`probua.minimal`) o powerlevel10k | Sin cambios — Omarchy mantiene **Starship** |
| **Init de shell** | symlink `~/.zshrc` → repo | bloque marcado **aditivo** en `~/.bashrc` |
| **Editor** | nvim + LazyVim (symlink `~/.config/nvim`) | Sin cambios — se mantiene **omarchy-nvim** |
| **Terminal** | kitty + tema Kanagawa (symlinks) | Sin cambios — se mantienen **foot / alacritty** |
| **Info sistema** | fastfetch (symlink) | Sin cambios |
| **Listado de archivos** | lsd | usa **eza** si existe (default de Omarchy) |
| **Paquetes** | set completo del distro (ver abajo) | solo aditivos: `bash-completion` · `fzf fd ripgrep` · `zoxide btop bat` |
| **Nerd Font** | instala JetBrainsMono Nerd Font | Sin cambios |
| **Homebrew + bbrew** | ofrecido (grupo brew-tools) | ofrecido (grupo brew-tools) |

### Herramientas del path normal

| Herramienta | Reemplaza | Para qué sirve |
|---|---|---|
| **zsh** | bash | Shell principal — autocompletado avanzado, plugins |
| **oh-my-posh** (`probua.minimal`) | prompt por defecto | Prompt customizable con info de git e iconos |
| **lsd** | `ls` | Listado con iconos, colores y tree |
| **neovim + LazyVim** | vim / nano | Editor de terminal con plugins auto-gestionados |
| **bat** | `cat` | Syntax highlighting y números de línea |
| **btop** | `top` / `htop` | Monitor de sistema visual |
| **fzf** | búsqueda manual | Búsqueda fuzzy interactiva |
| **zoxide** | `cd` | Navegación inteligente por frecuencia de uso |
| **fd** | `find` | Buscar archivos respetando `.gitignore` |
| **ripgrep** (`rg`) | `grep` | Buscar texto dentro de archivos |
| **fastfetch** | neofetch | Info del sistema al abrir terminal |
| **kitty** | terminal por defecto | Terminal GPU-acelerada con tema Kanagawa |
| **JetBrainsMono Nerd Font** | fuente por defecto | Iconos para prompt y `lsd`/`eza` |

### Plugins de zsh (solo path normal)

| Plugin | Qué hace |
|---|---|
| **zsh-autosuggestions** | Sugerencias inline grises del historial |
| **zsh-syntax-highlighting** | Colorea comandos en tiempo real |
| **zsh-completions** | Completados TAB extra |
| **zsh-history-substring-search** | Buscar historial por substring con ↑/↓ |
| **pkgfile** | Solo Arch — sugiere el paquete de un comando faltante |

### Package managers por distro (path normal)

| Distro | Manager | Nota |
|---|---|---|
| Arch / CachyOS / EndeavourOS | `pacman` + `paru` (AUR) | Repos nativos |
| Fedora | `dnf` | Repos nativos |
| Debian / Ubuntu | `apt` + Homebrew | `apt` tiene versiones viejas; Homebrew como fallback |

El path Omarchy usa `pacman -S --needed` por grupo, respetando lo ya instalado.

---

## Flags

Todas las flags son combinables entre sí y con `--omarchy`.

| Comando | Efecto |
|---|---|
| `./install.sh` | Instala el path normal completo |
| `./install.sh --omarchy` | Instala solo lo aditivo para Omarchy |
| `./install.sh --dry-run` | Muestra qué haría sin ejecutar nada |
| `./install.sh --uninstall` | Quita **solo archivos propiedad de FSX** (ver Desinstalador) |
| `./install.sh --uninstall --dry-run` | Lista lo que quitaría, sin tocar nada |
| `./install.sh --doctor` | Verifica el estado de la instalación normal |
| `./install.sh --omarchy --doctor` | Verifica el path Omarchy (bloque + paquetes) |
| `./install.sh --help` | Muestra el uso |

---

## Cómo funciona

### Symlinks, no copias (path normal)

`install.sh` crea symlinks desde `~/.config/` hacia el repo clonado:

- **El repo es la única fuente de verdad** — editás en el repo y la config ya está actualizada.
- **Sin re-ejecutar nada** — los cambios se reflejan al instante.
- **`git diff` trackea tu config** directamente.
- **Backups automáticos** — si el destino existe, se guarda como `.bak.YYYYMMDD-HHMMSS`.
- **Reproducible** — clonar + `./install.sh` = misma configuración.

### Un solo `.zshrc` (path normal)

El `.zshrc` detecta la distro desde `/etc/os-release` y carga el módulo correspondiente (`arch.zsh`, `fedora.zsh`, `debian.zsh`). Sin duplicación entre distros.

### Include aditivo en `~/.bashrc` (path Omarchy)

No se reemplaza `~/.bashrc`. El instalador agrega un **bloque marcado** que podés identificar y borrar fácil:

```bash
# >>> fsx dotfiles (omarchy) >>>
# Added by FSX dotfiles (install.sh --omarchy). Safe to remove this block.
if [[ -f "/home/tu-usuario/dotfiles/bash/fsx.bash" ]]; then
  source "/home/tu-usuario/dotfiles/bash/fsx.bash"
fi
# <<< fsx dotfiles (omarchy) <<<
```

- Si el bloque ya existe, **no se duplica**.
- `bash/fsx.bash` es 100% aditivo: no cambia el prompt, no hace `chsh`, no toca nvim/fastfetch/kitty/fuentes.
- El `--uninstall` elimina exactamente ese bloque.

### Overrides locales (no trackeados)

Ambos paths cargan un archivo local al final, fuera de git:

| Path | Archivo | Estado |
|---|---|---|
| Normal | `zsh/local.zsh` | Ejemplo committeado: `zsh/local.zsh.example` (`cp zsh/local.zsh.example zsh/local.zsh`) |
| Omarchy | `bash/local.bash` | Lo soporta `bash/fsx.bash`; creá el archivo a mano si lo necesitás |

Ideal para aliases personales/de trabajo, SSH por máquina, entradas de `PATH` y API keys.

---

## Neovim / LazyVim (solo path normal)

Config basada en el starter de [LazyVim](https://lazyvim.org) — **instalación vanilla**, sin plugins custom todavía.

- **Primer inicio:** al abrir `nvim`, `lazy.nvim` detecta y instala los plugins definidos. Sin intervención manual.
- **Plugins custom:** creá `.lua` en `nvim/lua/plugins/`; se cargan solos.
- **Config:** `nvim/lua/config/{keymaps,options,autocmds}.lua` listos para customizar.
- **Formato Lua:** StyLua (`nvim/stylua.toml`) — indent 2 espacios, ancho 120.

> En el path Omarchy el editor no se toca: seguís usando **omarchy-nvim**.

---

## Desinstalador

`./install.sh --uninstall` (o `--uninstall --dry-run` para previsualizar). Por diseño es conservador.

### Qué quita

- Symlinks propiedad de FSX: `~/.zshrc`, `~/.config/nvim`, `~/.config/kitty/{kitty.conf,current-theme.conf}`, `~/.config/fastfetch/config.jsonc`.
- El **bloque marcado** de `~/.bashrc` (reconstruye el archivo con `awk`, sin tocar el resto).
- El marcador `~/.config/zsh/prompt-engine`.
- Directorios XDG de zsh **solo si están vacíos** (pide confirmación por cada uno).

### Qué NO quita (intencional)

| No quita | Razón |
|---|---|
| Paquetes `pacman` / `dnf` / `apt` | Pueden pre-existir (`--needed`) y removertelos rompe el sistema u Omarchy |
| Homebrew / Linuxbrew | Puede usarse para otras cosas fuera del repo |
| bbrew (Bold Brew) | Herramienta de usuario — hay un prompt aparte, con default **NO** |
| oh-my-posh / powerlevel10k | Herramientas instaladas fuera del repo |
| Nerd Fonts | Recursos de usuario compartidos |
| `chsh` a zsh | Cambiar la shell de vuelta es decisión tuya |

> Nunca se eliminan paquetes ni se revierte nada de Omarchy.

---

## Notas

### XDG Base Directories

Todo se escribe bajo `~/.config`, `~/.cache`, `~/.local` y `~/.local/state`. Home limpio, backups fáciles.

### Nerd Font (path normal)

El prompt y `lsd`/`eza` necesitan una **Nerd Font**. El instalador ofrece bajar **JetBrainsMono Nerd Font** y auto-detecta la última release de GitHub (fallback: `v3.3.0`). En Omarchy no se toca la fuente.

### bbrew (Bold Brew TUI)

Ambos paths ofrecen el grupo **brew-tools**: si falta, instala Homebrew y luego `brew install bbrew` — una TUI para gestionar paquetes de Homebrew. Está envuelto en un confirm propio y `--uninstall` lo conserva por defecto.

### Homebrew en Debian/Ubuntu

Se instala **solo en Debian/Ubuntu** como fallback, porque las versiones de `apt` (bat, fd, ripgrep, fzf) suelen estar atrasadas. Evita agregar PPAs manuales.

### Herramientas opcionales

- **bun** — si está en `~/.bun`, se agrega al `PATH` y se configuran completions.
- **zoxide** — reemplaza `cd` con navegación inteligente. Después de unos días, `z proyecto` te lleva a `~/dev/proyecto` desde cualquier lado.
- **eza** — en Omarchy los aliases `ls`/`ll`/`tree` usan `eza` si está presente; si no, caen a `lsd`.
