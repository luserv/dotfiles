# Documentación de los dotfiles de Linux

Guía de la configuración de Linux de este repositorio (CachyOS con Xfce y xfwm4, fish, alacritty, rofi, picom y conky; sin barra ni panel).

## Páginas

| Página | Qué encontrarás |
|---|---|
| [Instalación](instalacion.md) | Cómo enlazar los archivos, respaldos, paquetes y cómo agregar archivos nuevos |
| [Atajos de teclado](atajos.md) | Todos los atajos personalizados, por categoría |
| [Panel de Conky](conky.md) | El panel del escritorio: secciones, scripts y cómo cambiar el tamaño |
| [Workspaces](workspaces.md) | Navegación entre workspaces, `sxhkd` y la notificación de estado |
| [Menús y utilidades](menus-y-utilidades.md) | Menú de apagado, Bluetooth, volumen, caffeine, tiling y más |
| [Solución de problemas](solucion-de-problemas.md) | Trampas conocidas y cómo se resolvieron |

## Mapa del repositorio

| Ruta | Contenido |
|---|---|
| `linux/config/` | Se enlaza a `~/.config/` (misma ruta relativa) |
| `linux/home/` | Se enlaza a `~/` |
| `linux/bin/` | Scripts de usuario, se enlazan a `~/.local/bin/` |
| `linux/system/` | Archivos de sistema (`/etc`); no los enlaza el instalador |
| `linux/packages/` | Listas informativas de paquetes (`pacman` y AUR) |
| `linux/docs/` | Esta documentación |
| `linux/scan-secrets.sh` | Revisa archivos en busca de secretos antes de hacer commit |
| `install-linux.sh` | Instalador de la parte de Linux (en la raíz del repo) |

La parte de Windows (`terminal.ps1`, `scripts/`) está documentada en el `readme.md` de la raíz.

## Convenciones

- Los textos para el usuario van en español neutro; los comentarios de código y los nombres de scripts, en inglés.
- Algunas rutas están fijas a `/home/kv` (autostart de Conky y XML de atajos). Ajústalas si el usuario es otro.
- Antes de cada commit que agregue archivos, ejecuta `linux/scan-secrets.sh` sobre ellos.
- Los atajos viven en `linux/config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml`; no se editan a mano en la máquina sin sincronizar el repo después.
