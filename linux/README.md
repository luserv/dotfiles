# Dotfiles de Linux

Este repositorio cubre Windows 11 (raíz del repo, `terminal.ps1`) y Linux (esta carpeta). La configuración de Linux proviene de un sistema CachyOS con Xfce (xfwm4), fish, alacritty, rofi, picom y conky (sin barra ni panel).

## Estructura

| Ruta | Destino en `$HOME` |
|---|---|
| `linux/config/` | `~/.config/` (misma ruta relativa) |
| `linux/home/` | `~/` (por ejemplo `.bashrc`, `.tmux.conf`) |
| `linux/bin/` | `~/.local/bin/` (scripts de usuario) |
| `linux/system/` | Archivos de sistema (`/etc`); **no** los enlaza el instalador, ver [Hotspot WiFi](#hotspot-wifi) |
| `linux/packages/` | Listas informativas: `pacman-explicit.txt` y `aur.txt` |
| `linux/scan-secrets.sh` | Revisa archivos en busca de secretos antes de hacer commit |

El instalador enlaza **archivo por archivo** (no carpetas completas), así las aplicaciones pueden seguir escribiendo otros archivos junto a los enlazados.

## Instalación

```bash
git clone https://github.com/luserv/w11dotfiles.git
cd w11dotfiles
./install-linux.sh --dry-run   # simulación: no modifica nada
./install-linux.sh             # enlaza todo
```

Opciones:

- `--dry-run`: muestra lo que haría sin cambiar nada.
- `--only config|home|bin|packages-info`: procesa una sola sección. `packages-info` solo imprime cómo instalar las listas de paquetes; no instala nada.

Comportamiento:

- Si el destino ya existe y no es el enlace correcto, se mueve a `~/.dotfiles-backup/<fecha-hora>/` conservando su ruta relativa. Nunca se sobrescribe sin respaldo.
- Es idempotente: una segunda ejecución informa "ya enlazado" y no cambia nada.
- Se niega a ejecutarse como root.

## Hotspot WiFi

Permite usar `wlan0` como hotspot mientras el internet llega por ethernet. Al elegir la línea `Hotspot` en el menú de `networkmanager_dmenu` (`Ctrl+Super+N`) se abre un submenú: encender/apagar, cambiar nombre, cambiar contraseña y mostrar QR.

Piezas (las tres primeras las enlaza `install-linux.sh`):

- `linux/config/networkmanager-dmenu/config.ini`: apunta `dmenu_command` al wrapper. Contiene la ruta absoluta `/home/kv/...`; ajústala si el usuario es otro.
- `linux/home/.local/share/nmdm-wrapper/rofi`: wrapper que intercepta las líneas `...:Hotspot`. Se llama `rofi` a propósito para que `networkmanager_dmenu` siga pasándole sus flags de rofi.
- `linux/bin/hotspot-menu`: el submenú (requiere `rofi`, `alacritty`, `qrencode`, `libnotify`).
- `linux/system/NetworkManager/dispatcher.d/90-hotspot-forward`: reglas de `DOCKER-USER` para que Docker no descarte el reenvío del hotspot.

Pasos manuales (requieren `sudo`; el instalador se niega a correr como root):

```bash
# 1. Crear el hotspot (ajusta ssid y clave)
nmcli device disconnect wlan0
nmcli device wifi hotspot ifname wlan0 con-name MiHotspot ssid MiRed password "CLAVE"
nmcli connection modify MiHotspot connection.autoconnect yes

# 2. Reglas persistentes para Docker (su FORWARD tiene policy DROP)
sudo install -m 755 linux/system/NetworkManager/dispatcher.d/90-hotspot-forward /etc/NetworkManager/dispatcher.d/
sudo systemctl enable --now NetworkManager-dispatcher.service

# 3. Si usas ufw: reenvío, DNS y DHCP desde wlan0
sudo ufw route allow in on wlan0 out on enp43s0
sudo ufw allow in on wlan0 to any port 53 proto udp
sudo ufw allow in on wlan0 to any port 53 proto tcp
sudo ufw allow in on wlan0 to any port 67 proto udp
```

El nombre de la conexión (`MiHotspot`) y la interfaz de salida (`enp43s0`) están fijos en el script del dispatcher; cámbialos si difieren.

## Workspaces, Conky y atajos

Navegación entre workspaces y panel de estado en el escritorio.

| Pieza | Función |
|---|---|
| `linux/config/conky/modern/conky.conf` + `modern.lua` | **Panel activo** (lo arranca el autostart): dibujado con Cairo, paleta Nord. Hora, fecha, uptime, IP, puntos de workspaces, anillos de CPU/RAM/disco con cantidades, barras por hilo de CPU, red, sección de audio (volumen y qué app suena en qué workspace), batería y top de procesos |
| `linux/config/conky/modern/ws-state.sh` | Estado de cada workspace para el panel: `A` activo, `O` con ventanas, `E` vacío |
| `linux/config/conky/modern/audio-state.sh` | Volumen y streams de audio activos, con el workspace de la ventana que suena (necesita `wpctl`, `pactl`, `jq` y `wmctrl`) |
| `linux/bin/volume-notify` | Teclas de volumen (`up\|down\|mute`) con notificación. Subir se limita al 100% con `wpctl -l 1.0` |
| `linux/config/conky/conky.conf` | Panel anterior, en texto plano (alternativa): hora, workspaces, CPU, temperatura, RAM, disco, red y top de procesos |
| `linux/config/conky/workspaces.sh` | Fila de workspaces para Conky: activo `[n]`, con ventanas normal, vacíos atenuados |
| `linux/config/conky/ws-notify.sh` | Notificación (3 s) con los workspaces que tienen ventanas y el actual (`Super+Ctrl+Q`) |
| `linux/bin/ws-cycle` | `ws-cycle next\|prev`: salta solo entre workspaces con ventanas, con vuelta al otro extremo |
| `linux/config/sxhkd/sxhkdrc` | `Super+Shift+Tab` → `ws-cycle prev` |
| `linux/config/autostart/{conky,sxhkd}.desktop` | Arrancan Conky y `sxhkd` con la sesión |

`Super+Tab` (siguiente) se define en `xfce4-keyboard-shortcuts.xml` y `Super+Shift+Tab` (anterior) en `sxhkd`.

Notas:

- `sxhkd` es necesario porque `xfsettingsd` no dispara de forma fiable los atajos con `Shift+Tab`. Hay que quitar del XML cualquier atajo `<Super><Shift>Tab`, o ambos compiten por la tecla.
- No asignes un atajo a `Super_L` solo (por ejemplo para un menú de aplicaciones): captura la tecla y `Super+Shift+Tab` solo funciona si se aprieta Shift primero.
- Las rutas `/home/kv/...` están fijas en `conky.desktop` y en el XML de atajos; ajústalas si el usuario es otro.
- Tamaño del panel nuevo: se controla con `SCALE` al inicio de `modern.lua` (ahora 1.15). Si lo cambias, ajusta en `modern/conky.conf` `minimum_width` y `maximum_width` (360 × `SCALE`) y `minimum_height` (794 × `SCALE`).
- El panel nuevo necesita conky con Lua y Cairo (`conky -v` los lista) y un compositor activo para la transparencia. Usa la interfaz `wlan0` y el sensor `coretemp`; ajústalos en `modern.lua` si tu equipo es otro.
- Volver al panel anterior: cambia `conky.desktop` para que apunte a `~/.config/conky/conky.conf`.
- Dependencias: `conky`, `sxhkd`, `wmctrl`, `xdotool` y `libnotify` (están en `pacman-explicit.txt`).

## Mantener la pantalla activa (caffeine)

`Super+Alt+C` alterna `linux/bin/xfce-idle-toggle`: mientras está activo bloquea con `systemd-inhibit` el estado inactivo (`idle`), la suspensión (`sleep`) y la acción al cerrar la tapa, y avisa con una notificación. El panel de Conky muestra `Keep awake` en la cabecera mientras esté activo.

No se usa `caffeine-ng`: su icono necesita una bandeja del sistema y este setup no tiene panel ni barra.

## Menú de apagado

`Super+Shift+Q` abre un menú de rofi con Lock, Log out, Suspend, Reboot y Shut down. Log out, Reboot y Shut down piden confirmación (Yes/No) antes de ejecutarse.

- `linux/bin/power-menu`: el script. Usa `xflock4` y `xfce4-session-logout`.
- `linux/config/rofi/power-menu.rasi`: tema compacto sobre `theme.rasi` (Tokyo Night). Los iconos son glifos de Nerd Font, así que necesitas una fuente Nerd Font en rofi.

## Qué se excluye por privacidad

No se versionan gestores de contraseñas (1Password, Bitwarden), mensajería (Signal), navegadores, clientes de sincronización (Nextcloud, filen, rclone), `gh`, configuraciones de herramientas de IA (opencode, claude), aplicaciones Electron/JetBrains/Code, ni archivos de sesión, caché, logs o bases de datos. Tampoco `*.bak`, `*.backup*` ni `git/config` (contiene identidad personal). Los archivos generados por la máquina (por ejemplo `fish_variables`) y los enlaces simbólicos a temas dinámicos tampoco se incluyen.

## Agregar un archivo nuevo

1. Copia el archivo a la ruta espejo dentro de `linux/` (por ejemplo `~/.config/foo/foo.conf` va en `linux/config/foo/foo.conf`).
2. Ejecuta `linux/scan-secrets.sh linux/config/foo` y revisa cada coincidencia.
3. Si es un script, hazlo ejecutable y registra el bit en git: `git update-index --chmod=+x <ruta>`.
4. Haz commit y ejecuta `./install-linux.sh` para enlazarlo.
