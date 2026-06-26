# FSX Dotfiles

Configuración personal de desarrollo para Linux — multi-distro.

**Distros soportadas:** Arch / CachyOS / EndeavourOS · Fedora · Debian / Ubuntu

## Stack

| Herramienta | Función |
|---|---|
| **zsh** | Shell principal |
| **oh-my-posh** (`probua.minimal`) | Prompt minimalista con info de git |
| **lsd** | `ls` con iconos y colores |
| **neovim + LazyVim** | Editor principal |
| **bat** | `cat` con syntax highlighting |
| **btop** | `top` con interfaz visual |
| **fzf** | Búsqueda fuzzy |
| **zoxide** | `cd` inteligente con historial |
| **fd** | `find` más rápido, respeta `.gitignore` |
| **ripgrep** | `grep` ultrarrápido |
| **zsh-autosuggestions** | Sugerencias inline del historial |
| **zsh-syntax-highlighting** | Colores en tiempo real al escribir |
| **zsh-completions** | Completados extra |
| **kitty** | Terminal con tema Kanagawa |
| **fastfetch** | Info del sistema al iniciar |

## Instalación

```bash
git clone git@github.com:felix73sanchez/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
exec zsh
```

### Flags del instalador

| Comando | Efecto |
|---|---|
| `./install.sh` | Instala todo (por defecto) |
| `./install.sh --dry-run` | Muestra qué haría sin ejecutar nada |
| `./install.sh --uninstall` | Elimina los symlinks creados |
| `./install.sh --doctor` | Verifica la salud de la instalación |
| `./install.sh --help` | Muestra el uso |

El script detecta tu distro automáticamente y usa el package manager nativo:

| Distro | Package Manager | Notas |
|---|---|---|
| Arch / CachyOS / EndeavourOS | `pacman` + `paru` (AUR) | Todo desde repos nativos |
| Fedora | `dnf` | Todo desde repos nativos |
| Debian / Ubuntu | `apt` + Homebrew | Homebrew para paquetes actualizados |

> Requiere `sudo` para instalar paquetes y `chsh`.
> Neovim abre y lazy.nvim instala todos los plugins automáticamente en el primer inicio.

## Estructura

```
dotfiles/
├── install.sh                        # Bootstrap multi-distro
├── lib/
│   ├── detect.sh                     # Detección de distro
│   └── utils.sh                      # Funciones comunes (log, backup, symlink)
├── zsh/
│   ├── .zshrc                        # Config unificada (detecta distro)
│   └── distro/
│       ├── arch.zsh                  # Aliases pacman/paru, pkgfile
│       ├── fedora.zsh                # Aliases dnf
│       └── debian.zsh                # Aliases apt, flatpak
├── oh-my-posh/
│   └── probua.minimal.omp.json       # Tema del prompt
├── nvim/                             # Config de Neovim (LazyVim)
│   ├── init.lua
│   ├── lazyvim.json
│   ├── lazy-lock.json
│   ├── stylua.toml
│   └── lua/
│       ├── config/
│       │   ├── autocmds.lua
│       │   ├── keymaps.lua
│       │   ├── lazy.lua
│       │   └── options.lua
│       └── plugins/
├── kitty/
│   ├── kitty.conf                    # Config de la terminal (JetBrainsMono Nerd Font)
│   └── kanagawa.conf                 # Tema de colores (Kanagawa)
└── fastfetch/
    └── config.jsonc                  # Módulos del sistema info
```

## Cómo funciona

### Un solo `.zshrc` — cero duplicación

El `.zshrc` detecta la distro via `/etc/os-release` y carga el módulo correspondiente:

```zsh
# Detección automática → carga arch.zsh, fedora.zsh o debian.zsh
_fsx_distro_id=$(grep -oP '^ID=\K\w+' /etc/os-release 2>/dev/null)
case "$_fsx_distro_id" in
  arch|cachyos|endeavouros) _fsx_distro_family="arch"   ;;
  fedora)                   _fsx_distro_family="fedora"  ;;
  debian|ubuntu|pop)        _fsx_distro_family="debian"  ;;
esac
source "$DOTFILES_DIR/zsh/distro/${_fsx_distro_family}.zsh"
```

### Plugins con resolución multi-path

Los plugins de zsh se buscan automáticamente en las rutas de cada distro:

```zsh
_source_plugin zsh-autosuggestions
# Busca en: /usr/share/zsh/plugins/ (Arch)
#           /usr/share/ (Fedora)
#           $HOMEBREW_PREFIX/opt/ (Homebrew)
#           ~/.local/share/zsh/plugins/ (manual)
```

### Symlinks en vez de copias

`install.sh` crea symlinks — los cambios en el repo se reflejan inmediatamente sin re-ejecutar nada.
Si ya existe un archivo en el destino, se crea un backup con timestamp (`.bak.YYYYMMDD-HHMMSS`) para evitar sobreescrituras.

## Lo que configura `.zshrc`

### Orden de carga

```
XDG dirs → distro detect → PATH → brew (si existe) → fpath → compinit → plugins → oh-my-posh → ...
```

### Historial
- 50,000 líneas en `$XDG_STATE_HOME/zsh/history`
- Sin duplicados, con timestamps, verificación antes de ejecutar

### Autocompletado
- Menú interactivo con TAB
- Case-insensitive + matching inteligente
- Cache en `$XDG_CACHE_HOME/zsh/compcache`

### Keybindings
| Tecla | Acción |
|---|---|
| `↑ / ↓` | Buscar historial por prefijo (o substring si el plugin está cargado) |
| `Ctrl+R` | Búsqueda incremental |
| `Ctrl+Space` | Aceptar sugerencia inline |
| `Ctrl+→ / ←` | Mover por palabras |
| `Ctrl+H` | Borrar palabra anterior |
| `Ctrl+X Ctrl+E` | Editar comando en `$EDITOR` |

### Aliases comunes (todas las distros)
```zsh
ls / ll / la / lt / lsize    # lsd variants
tree / tree2                 # lsd --tree
vi                           # nvim
cat                          # bat (si instalado)
top                          # btop (si instalado)
gs / ga / gc / gp / gl      # git shortcuts
ss-start / ss-stop / ...    # systemd shortcuts
rmd                          # rm -rfI (con -I para confirmación interactiva)
reload                       # source ~/.zshrc
apagar / reiniciar           # shutdown / reboot
```

### Aliases por distro

**Arch/CachyOS:** `actualizar` (paru -Syu), `instalar`, `buscar`, `desinstalar`, `pac*`, `mirrors`
> `pacclean` es una función que verifica si hay paquetes huérfanos antes de intentar eliminarlos.
**Fedora:** `actualizar` (dnf upgrade), `instalar`, `buscar`, `desinstalar`, `dnf*`
**Debian:** `actualizar` (apt update+upgrade), `instalar`, `buscar`, `desinstalar`, `purgar`, `apt*`

### Funciones
```zsh
mkcd <dir>      # mkdir + cd
fh <query>      # buscar en historial
gclone <url>    # git clone + cd
bak <file>      # copia .bak
whichport <n>   # qué proceso usa el puerto
extract <file>  # descomprimir cualquier formato
whatpkg <cmd>   # qué paquete provee un comando (solo Arch)
pacnews         # buscar .pacnew/.pacsave (solo Arch)
```

## Neovim / LazyVim

Config basada en el starter de [LazyVim](https://lazyvim.org). Los plugins se instalan automáticamente al abrir nvim por primera vez.

## Notas

- Los configs usan **XDG Base Directories** — nada se escribe fuera de `~/.config`, `~/.cache`, `~/.local`.
- Rutas de plugins se resuelven automáticamente sin importar el package manager.
- El prompt oh-my-posh requiere una **Nerd Font** (e.g. JetBrainsMono Nerd Font) — el instalador ofrece descargarla y auto-detecta la última versión desde GitHub (fallback: v3.3.0).
- `bun` se configura automáticamente si está instalado en `~/.bun`.
- `zoxide` reemplaza `cd` con navegación inteligente por historial.
- Homebrew **solo se instala en Debian/Ubuntu** como fallback para paquetes actualizados.
