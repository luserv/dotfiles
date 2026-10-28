# Dotfiles de Linux

Este repositorio cubre Windows 11 (raíz del repo, `terminal.ps1`) y Linux (esta carpeta). La configuración de Linux proviene de un sistema CachyOS con Xfce (xfwm4), fish, alacritty, polybar, rofi y picom.

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

## Qué se excluye por privacidad

No se versionan gestores de contraseñas (1Password, Bitwarden), mensajería (Signal), navegadores, clientes de sincronización (Nextcloud, filen, rclone), `gh`, configuraciones de herramientas de IA (opencode, claude), aplicaciones Electron/JetBrains/Code, ni archivos de sesión, caché, logs o bases de datos. Tampoco `*.bak`, `*.backup*` ni `git/config` (contiene identidad personal). Los archivos generados por la máquina (por ejemplo `fish_variables`) y los enlaces simbólicos a temas dinámicos tampoco se incluyen.

## Agregar un archivo nuevo

1. Copia el archivo a la ruta espejo dentro de `linux/` (por ejemplo `~/.config/foo/foo.conf` va en `linux/config/foo/foo.conf`).
2. Ejecuta `linux/scan-secrets.sh linux/config/foo` y revisa cada coincidencia.
3. Si es un script, hazlo ejecutable y registra el bit en git: `git update-index --chmod=+x <ruta>`.
4. Haz commit y ejecuta `./install-linux.sh` para enlazarlo.
