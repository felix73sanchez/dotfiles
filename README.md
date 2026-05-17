# FSX Dotfiles

Configuración personal de zsh + herramientas para entorno de desarrollo en Linux (Debian/Ubuntu).

## Stack

| Herramienta | Función |
|---|---|
| **zsh** | Shell principal |
| **oh-my-posh** (`probua.minimal`) | Prompt minimalista con info de git |
| **lsd** | `ls` con iconos y colores |
| **neovim** | Editor (`$EDITOR`) |
| **bat** | `cat` con syntax highlighting |
| **btop** | `top` con interfaz visual |
| **fzf** | Búsqueda fuzzy |
| **zoxide** | `cd` inteligente con historial |
| **zsh-autosuggestions** | Sugerencias inline del historial |
| **zsh-syntax-highlighting** | Colores en tiempo real al escribir |
| **zsh-completions** | Completados extra para brew |
| **kitty** | Terminal con tema Kanagawa |
| **fastfetch** | Info del sistema al iniciar |

## Instalación rápida

```bash
git clone git@github.com:felix73sanchez/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
exec zsh
```

> El script instala Homebrew automáticamente si no está presente.  
> Requiere `sudo` para `apt` y `chsh`.

## Estructura

```
dotfiles/
├── install.sh                    # Bootstrap completo
├── zsh/
│   └── .zshrc                    # Config principal de zsh
├── oh-my-posh/
│   └── probua.minimal.omp.json   # Tema del prompt
├── kitty/
│   ├── kitty.conf                # Config de la terminal
│   └── kanagawa.conf             # Tema de colores (Kanagawa)
└── fastfetch/
    └── config.jsonc              # Módulos del sistema info
```

## Lo que configura `.zshrc`

### Historial
- 50,000 líneas, compartido entre sesiones
- Sin duplicados, con timestamps

### Autocompletado
- Menú interactivo con TAB
- Case-insensitive + matching inteligente
- Cache en `~/.zsh/cache`

### Keybindings
| Tecla | Acción |
|---|---|
| `↑ / ↓` | Buscar historial por prefijo |
| `Ctrl+R` | Búsqueda incremental |
| `Ctrl+Space` | Aceptar sugerencia inline |
| `Ctrl+→ / ←` | Mover por palabras |
| `Ctrl+H` | Borrar palabra anterior |

### Aliases destacados
```zsh
ls / ll / la / lt / lsize    # lsd variants
tree / tree2                 # lsd --tree
vi                           # nvim
cat                          # bat (si instalado)
top                          # btop (si instalado)
gs / ga / gc / gp / gl      # git shortcuts
mirtha                       # ssh fsxserver@10.0.0.73
actualizar                   # apt update + upgrade
reload                       # source ~/.zshrc
```

### Funciones
```zsh
mkcd <dir>      # mkdir + cd
fh <query>      # buscar en historial
gclone <url>    # git clone + cd
bak <file>      # copia .bak
whichport <n>   # qué proceso usa el puerto
extract <file>  # descomprimir cualquier formato
```

## Instalación manual (paso a paso)

```bash
# 1. Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 2. Paquetes
brew install oh-my-posh lsd neovim bat btop fzf zoxide \
             zsh-autosuggestions zsh-syntax-highlighting zsh-completions

# 3. Copiar configs
cp zsh/.zshrc ~/.zshrc
mkdir -p ~/.cache/oh-my-posh/themes
cp oh-my-posh/probua.minimal.omp.json ~/.cache/oh-my-posh/themes/
mkdir -p ~/.zsh/cache

# 4. Shell por defecto
chsh -s $(which zsh)
exec zsh
```

## Notas

- El `.zshrc` usa rutas hardcoded de linuxbrew (`/home/linuxbrew/...`). En macOS cambiar por `/opt/homebrew/`.
- El tema oh-my-posh requiere una **Nerd Font** en la terminal (e.g. JetBrainsMono Nerd Font).
- `bun` se configura automáticamente si está instalado en `~/.bun`.
