# Menús y utilidades

Scripts de `linux/bin/` (se enlazan a `~/.local/bin/`) y las configuraciones que los acompañan.

## Menú de apagado

`Super+Shift+Q` abre un menú de rofi con **Lock**, **Log out**, **Suspend**, **Reboot** y **Shut down**. Log out, Reboot y Shut down piden confirmación (Yes/No) antes de ejecutarse.

| Archivo | Función |
|---|---|
| `linux/bin/power-menu` | El script. Usa `xflock4` y `xfce4-session-logout` |
| `linux/config/rofi/power-menu.rasi` | Tema compacto sobre `theme.rasi` (Tokyo Night) |

Los iconos son glifos de Nerd Font escritos como escapes Unicode (`$''`), así que el script queda en ASCII. Rofi necesita una fuente Nerd Font para mostrarlos.

## Bluetooth

`Super+Ctrl+B` abre `bluetui` en una ventana de alacritty (clase `bluetooth-tui`).

`linux/config/bluetui/config.toml` contiene `esc_quit = true`, que permite cerrar la aplicación con `Esc`. Si estás dentro de un popup (por ejemplo al emparejar), el primer `Esc` puede cerrar solo ese popup.

## Volumen

Las teclas de volumen ejecutan `linux/bin/volume-notify up|down|mute`, que cambia el volumen y muestra una notificación con el nivel.

- **Subir** usa `wpctl set-volume -l 1.0`, así que nunca pasa del 100%. Si ya estabas por encima, la tecla te devuelve al 100%.
- **Bajar** y **silenciar** usan `pactl`.
- El tope vale solo para estas teclas: `pavucontrol` u otras aplicaciones pueden seguir subiendo más allá del 100%.

`Super+Ctrl+A` abre `pavucontrol`.

## Mantener la pantalla activa (caffeine)

`Super+Alt+C` alterna `linux/bin/xfce-idle-toggle`. Mientras está activo bloquea con `systemd-inhibit` el estado inactivo (`idle`), la suspensión (`sleep`) y la acción al cerrar la tapa, y avisa con una notificación. El panel de Conky muestra `Keep awake` en la cabecera.

El estado se guarda en `$XDG_RUNTIME_DIR/xfce-idle-inhibit.pid`. No se usa `caffeine-ng`: su icono necesita una bandeja del sistema y este setup no tiene panel ni barra.

## Hotspot WiFi

Permite usar `wlan0` como hotspot mientras el internet llega por ethernet. Se abre desde el selector de redes (`Super+Ctrl+N`), línea `Hotspot`: encender o apagar, cambiar nombre, cambiar contraseña y mostrar QR. Los pasos de instalación, que requieren `sudo`, están en la sección "Hotspot WiFi" de [`linux/README.md`](../README.md).

## Tiling de ventanas

| Script | Uso |
|---|---|
| `tile-third` | `tile-third <left\|right\|top\|bottom> [partes]` coloca la ventana activa en 1/partes del monitor, respetando el área útil |
| `resize-edge` | `resize-edge <left\|right\|up\|down> [paso]` expande el borde de la ventana activa |
| `move-window-to-workspace` | Mueve la ventana activa a un workspace (lo usan `Super+Shift+1` … `0`) |

Los atajos de tiling están en [Atajos de teclado](atajos.md).

## Capturas de pantalla

`linux/bin/xfce-capture-screenshot fullscreen|window|region` captura con `scrot` (pantalla completa, ventana enfocada o región elegida). Guarda un PNG en tu carpeta de imágenes (`SCREENSHOT_DIR`, o `XDG_PICTURES_DIR`, o `~/Pictures`), lo copia al portapapeles con `xclip` y avisa con una notificación. Los atajos son `Print`, `Ctrl+Print` y `Super+Print`.

## Portapapeles universal

`omarchy-copy`, `omarchy-paste` y `omarchy-cut` replican el "copiar, pegar y cortar universal" de Omarchy/Hyprland. Detectan la clase de la ventana activa: en terminales envían `Ctrl+Insert` (copiar) y `Shift+Insert` (pegar); en el resto de aplicaciones, `Ctrl+C` y `Ctrl+V`. Cortar siempre envía `Ctrl+X`. Atajos: `Super+C/V/X` y `Ctrl+Shift+C/V/X`.

## Otras utilidades

| Script | Para qué sirve |
|---|---|
| `force-ssd-chromium` | Fuerza decoraciones del lado del servidor de xfwm4 en aplicaciones que dibujan las suyas |
| `zoom-clamp.sh` | Evita que las ventanas de Zoom crezcan sin control |
| `zmishare` | Escritorio X anidado dentro de una ventana, para compartir pantalla de forma estable en Zoom |
| `kdenlive-nogpu` | Lanza Kdenlive con renderizado por software (sin GPU) |
| `gnome-theme-switcher` | Aplicación en Python (GTK4) para cambiar el tema de GTK |
