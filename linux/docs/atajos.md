# Atajos de teclado

Fuente de verdad: `linux/config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml`. Esta página es un resumen por categoría. Para ver el estado real de tu máquina:

```bash
xfconf-query -c xfce4-keyboard-shortcuts -v -l | rg '^/commands/custom/'
```

`Super+Shift+Tab` es la excepción: no está en el XML sino en `sxhkd` (ver [Workspaces](workspaces.md)).

## Workspaces

| Atajo | Acción |
|---|---|
| `Super+1` … `Super+9`, `Super+0` | Ir al workspace 1 a 9 y 10 (también `Super+10`) |
| `Super+Shift+1` … `Super+Shift+0` | Mover la ventana activa al workspace N (usa los símbolos `! @ # $ % ^ & * ( )`) |
| `Super+Tab` | Siguiente workspace con ventanas (con vuelta) |
| `Super+Shift+Tab` | Workspace anterior con ventanas (con vuelta), vía `sxhkd` |
| `Super+Ctrl+Q` | Notificación con los workspaces que tienen ventanas |
| `Super+Alt+C` | Alternar "mantener activo" (caffeine) |

## Ventanas y tiling

| Atajo | Acción |
|---|---|
| `Super+Izquierda` / `Derecha` / `Arriba` / `Abajo` | Mitad de pantalla (`tile-third … 2`) |
| `Super+Ctrl+Flechas` | Tercio de pantalla izquierdo, derecho, superior o inferior |
| `Super+Alt+U` / `I` / `J` / `K` | Esquinas: superior izquierda, superior derecha, inferior izquierda, inferior derecha |
| `Super+J` | Maximizar o restaurar la ventana activa |
| `Super+F` | Pantalla completa (xfwm4) |
| `Super+T` | Mostrar la ventana en todos los workspaces (xfwm4) |
| `Super+W` | Cerrar la ventana activa |
| `Super+Shift+Flechas` | Mover la ventana (xfwm4) |
| `Super` + teclado numérico | Tiling de xfwm4 (`KP_Left`, `KP_Home`, etc.) |

## Aplicaciones

| Atajo | Acción |
|---|---|
| `Super+Return` | Terminal (alacritty) |
| `Super+Espacio`, `Super+Alt+Espacio` | Lanzador de aplicaciones (rofi, con tema Tokyo Night) |
| `Super+R` | `xfce4-appfinder` |
| `Super+B` / `Super+Shift+B` | Navegador / navegador en modo privado |
| `Super+E`, `Ctrl+Alt+F` | Gestor de archivos (nemo) |
| `Super+Ctrl+T` | Monitor del sistema (`btop`, o el administrador de tareas) |
| `Super+Shift+D` | `lazydocker` en una terminal |
| `Super+Shift+/` | Gestor de contraseñas (1Password o KeePassXC) |

## Sistema

| Atajo | Acción |
|---|---|
| `Super+Shift+Q` | Menú de apagado (rofi) |
| `Super+L`, `Ctrl+Alt+L`, `Super+Ctrl+L` | Bloquear pantalla |
| `Ctrl+Alt+Supr` | Diálogo estándar de cierre de sesión de XFCE |
| `Ctrl+Shift+Esc` | Administrador de tareas |
| `Ctrl+Alt+Esc` | `xkill` |
| `Super+,` | Ajustes de XFCE |
| `Super+Ctrl+,` | Ajustes de teclado |
| `Super+Ctrl+D` / `Super+D` | Ajustes de pantalla / versión mínima |
| `Super+Ctrl+P` | Ajustes de energía |
| `Super+N` | Ajustes de notificaciones |
| `Super+Ctrl+A` | Control de volumen (`pavucontrol`) |
| `Super+Ctrl+B` | Bluetooth (`bluetui`); se cierra con `Esc` |
| `Super+Ctrl+N` | Selector de redes (`networkmanager_dmenu`); incluye el submenú Hotspot |
| `Super+Ctrl+W` | Editor de conexiones de red |
| `XF86AudioRaiseVolume`, `XF86AudioLowerVolume`, `XF86AudioMute` | Volumen con notificación (`volume-notify`); subir se limita al 100% |

## Capturas de pantalla

| Atajo | Acción |
|---|---|
| `Print` | Pantalla completa |
| `Ctrl+Print` | Ventana |
| `Super+Print` | Región |
| `Shift+Print` | Región con `scrot -s` |
| `Alt+Print` | Ventana activa con `scrot -u` |

## Portapapeles

| Atajo | Acción |
|---|---|
| `Super+C` / `Super+V` / `Super+X` | Copiar / pegar / cortar universal (`omarchy-copy`, `omarchy-paste`, `omarchy-cut`) |
| `Ctrl+Shift+C` / `Ctrl+Shift+V` / `Ctrl+Shift+X` | Lo mismo con `Ctrl+Shift` |
| `Super+Ctrl+V` | Historial del portapapeles (rofi con `greenclip`) |

## Zoom de pantalla

| Atajo | Acción |
|---|---|
| `Super+Ctrl+Z` | Acercar (envía `Ctrl++`) |
| `Super+Ctrl+Alt+Z` | Restablecer (envía `Ctrl+0`) |

## Cómo agregar o cambiar un atajo

```bash
# Crear
xfconf-query -c xfce4-keyboard-shortcuts -n -t string \
  -p '/commands/custom/<Super><Alt>x' -s "$HOME/.local/bin/mi-script"

# Quitar
xfconf-query -c xfce4-keyboard-shortcuts -r -p '/commands/custom/<Super><Alt>x'
```

Antes de asignar una combinación, comprueba que no esté tomada (en `commands` y en `xfwm4`):

```bash
xfconf-query -c xfce4-keyboard-shortcuts -v -l | rg -i '<Super><Alt>x'
```

Después de cambiar atajos, copia el XML al repo (ver [Instalación](instalacion.md)).

## Combinaciones a evitar

- `Super` solo: no asignes ninguna acción a `Super_L` (por ejemplo un menú de aplicaciones). Captura la tecla y rompe combinaciones como `Super+Shift+Tab` cuando se aprieta Super primero.
- `Super+W` cierra la ventana activa (está definido como comando y como acción de xfwm4); no la reutilices.
- `Super+Shift+PageUp` y `Super+Shift+PageDown` ejecutan hoy el mismo comando (mueven la ventana al siguiente workspace); uno de los dos está mal definido.
- Las combinaciones con `Shift+Tab` no se disparan de forma fiable desde `xfsettingsd`; usa `sxhkd` (ver [Solución de problemas](solucion-de-problemas.md)).
