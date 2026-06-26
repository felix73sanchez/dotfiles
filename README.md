# FSX Dotfiles

Configuración personal de desarrollo para Linux — multi-distro.

**Distros soportadas:** Arch / CachyOS / EndeavourOS · Fedora · Debian / Ubuntu

## Stack

| Herramienta | Reemplaza | Para qué sirve |
|---|---|---|
| **zsh** | bash | Shell principal — autocompletado avanzado, plugins |
| **oh-my-posh** (`probua.minimal`) | prompt por defecto | Prompt customizable con info de git e iconos |
| **lsd** | `ls` | Listado de archivos con iconos, colores, y tree |
| **neovim + LazyVim** | vim / nano | Editor de código en terminal con plugins auto-gestionados |
| **bat** | `cat` | Ver archivos con syntax highlighting y números de línea |
| **btop** | `top` / `htop` | Monitor de sistema con interfaz visual |
| **fzf** | búsqueda manual | Búsqueda fuzzy interactiva (archivos, historial) |
| **zoxide** | `cd` | Navegación inteligente — aprende tus directorios más usados |
| **fd** | `find` | Buscar archivos por nombre, respeta `.gitignore` |
| **ripgrep** (`rg`) | `grep` | Buscar texto dentro de archivos, respeta `.gitignore` |
| **fastfetch** | neofetch | Info del sistema al abrir terminal |
| **kitty** | terminal por defecto | Terminal GPU-acelerada con tema Kanagawa |
| **JetBrainsMono Nerd Font** | fuente por defecto | Fuente monoespaciada con iconos para prompt y lsd |

### Plugins de zsh

| Plugin | Qué hace |
|---|---|
| **zsh-autosuggestions** | Sugerencias inline grises del historial |
| **zsh-syntax-highlighting** | Colorea comandos en tiempo real (verde=válido, rojo=error) |
| **zsh-completions** | Completados TAB extra |
| **zsh-history-substring-search** | Buscar historial por substring con ↑/↓ |
| **pkgfile** | Solo Arch — sugiere qué paquete instalar cuando un comando no existe |

## Requisitos previos

Antes de ejecutar `install.sh`, asegurate de tener:

- **`git`** — para clonar el repo
- **`curl`** — para descargar herramientas (oh-my-posh, Nerd Fonts, Homebrew en Debian)
- **`sudo`** — para instalar paquetes y cambiar el shell con `chsh`
- **Terminal con soporte Nerd Fonts** — kitty, Alacritty, WezTerm, o cualquier emulador que permita configurar la fuente. Sin Nerd Font el prompt y `lsd` muestran caracteres rotos

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

### Detección de distro y package managers

El script detecta tu distro automáticamente y usa el package manager correspondiente:

| Distro | Package Manager | Por qué este manager |
|---|---|---|
| Arch / CachyOS / EndeavourOS | `pacman` + `paru` (AUR) | Repos nativos siempre actualizados — no necesita nada extra |
| Fedora | `dnf` | Repos nativos con versiones recientes |
| Debian / Ubuntu | `apt` + Homebrew | `apt` tiene versiones muy atrasadas de herramientas de desarrollo (bat, fd, ripgrep, etc.). Homebrew se instala como fallback para obtener versiones actualizadas sin agregar PPAs manuales |

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

`install.sh` crea symlinks, no copias. Esto tiene ventajas concretas:

- **El repo es la única fuente de verdad** — los archivos en `~/.config/` apuntan directamente al repo clonado
- **Los cambios se reflejan inmediatamente** — editás un archivo en el repo y la config ya está actualizada, sin re-ejecutar nada
- **`git diff` trackea todo directamente** — cualquier cambio en tu config aparece en el diff del repo
- **Reproducibilidad total** — clonar en una máquina nueva + `./install.sh` = exactamente la misma configuración
- **Backups automáticos** — si ya existe un archivo en el destino, se crea un backup con timestamp (`.bak.YYYYMMDD-HHMMSS`) antes de sobreescribirlo

### Overrides locales con `local.zsh`

Para configuraciones personales que no deberían ir al repo, usá `zsh/local.zsh`:

```zsh
# Crear tu archivo local (no trackeado por git):
cp zsh/local.zsh.example zsh/local.zsh
```

Este archivo se carga automáticamente al final de `.zshrc` pero está en `.gitignore`. Ideal para:

- Aliases personales o de trabajo
- Configuración de SSH específica de cada máquina
- Entradas de `PATH` que varían por entorno (e.g. SDKs, herramientas internas)
- API keys y tokens que no deben ir a un repo

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

Config basada en el starter de [LazyVim](https://lazyvim.org). Es una instalación **vanilla de LazyVim** — sin plugins custom agregados todavía.

### Primer inicio

Al abrir `nvim` por primera vez, `lazy.nvim` detecta los plugins definidos y los instala automáticamente. No se necesita intervención manual.

### Agregar plugins custom

Para agregar plugins, creá archivos `.lua` en `nvim/lua/plugins/`. Cualquier archivo en ese directorio es cargado automáticamente por lazy.nvim:

```lua
-- nvim/lua/plugins/example.lua
return {
  { "user/plugin-name", opts = {} },
}
```

### Configuración

Los archivos en `nvim/lua/config/` están listos para customizar:

- `keymaps.lua` — atajos de teclado personalizados
- `options.lua` — opciones de Neovim (números de línea, tabs, etc.)
- `autocmds.lua` — autocommands (acciones al abrir/guardar archivos, etc.)

### Formateo Lua

El proyecto usa **StyLua** para formatear archivos Lua. La configuración está en `nvim/stylua.toml`:

- Indent: 2 espacios
- Ancho de columna: 120 caracteres

## Notas

### XDG Base Directories

Todas las configuraciones usan **XDG Base Directories** — nada se escribe fuera de `~/.config`, `~/.cache`, `~/.local`. Esto mantiene el home limpio y facilita backups.

### Resolución de plugins

Las rutas de plugins se resuelven automáticamente sin importar el package manager. El `.zshrc` busca en múltiples paths hasta encontrar cada plugin (ver sección "Plugins con resolución multi-path").

### Nerd Font

El prompt oh-my-posh y `lsd` requieren una **Nerd Font** para mostrar iconos correctamente. El instalador ofrece descargar **JetBrainsMono Nerd Font** automáticamente y auto-detecta la última versión desde GitHub (fallback: v3.3.0).

### Homebrew (solo Debian/Ubuntu)

Homebrew se instala **únicamente en Debian/Ubuntu** como fallback. Las versiones de `apt` para herramientas como bat, fd, ripgrep, y fzf suelen estar muy atrasadas. Homebrew permite tener versiones actualizadas sin agregar PPAs manualmente.

### Herramientas opcionales

- **bun** — se configura automáticamente si está instalado en `~/.bun` (agrega al PATH y configura completions)
- **zoxide** — reemplaza `cd` con navegación inteligente basada en frecuencia de uso. Después de unos días, `z proyecto` te lleva a `~/dev/proyecto` sin importar dónde estés
