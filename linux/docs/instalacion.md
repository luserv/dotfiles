# Instalación

El instalador enlaza **archivo por archivo** (nunca carpetas completas) desde `linux/` hacia tu `$HOME`, de modo que las aplicaciones pueden seguir escribiendo otros archivos junto a los enlazados.

## Pasos

```bash
git clone https://github.com/luserv/w11dotfiles.git
cd w11dotfiles
./install-linux.sh --dry-run   # simulación: no modifica nada
./install-linux.sh             # enlaza todo
```

Opciones:

- `--dry-run`: muestra lo que haría sin cambiar nada.
- `--only config|home|bin|packages-info`: procesa una sola sección. `packages-info` solo imprime cómo instalar las listas de paquetes.

## Comportamiento

- Si el destino ya existe y no es el enlace correcto, se mueve a `~/.dotfiles-backup/<fecha-hora>/` conservando su ruta relativa. Nunca se sobrescribe sin respaldo.
- Es idempotente: una segunda ejecución informa "ya enlazado".
- Se niega a ejecutarse como root.

## Paquetes

Las listas en `linux/packages/` son informativas; el instalador no instala nada:

```bash
sudo pacman -S --needed - < linux/packages/pacman-explicit.txt
paru -S --needed - < linux/packages/aur.txt
```

Revisa las listas antes de instalar: reflejan el sistema de origen.

Dependencias de la parte de escritorio documentada aquí: `conky` (con Lua y Cairo), `sxhkd`, `wmctrl`, `xdotool`, `rofi`, `libnotify`, `jq`, `pipewire` con `wpctl` y `pactl`, `bluetui` y `alacritty`.

## Después de instalar

- Los atajos de XFCE están en un archivo XML que `xfsettingsd` reescribe. Si el atajo no responde tras enlazar, reinicia la sesión.
- El panel de Conky y `sxhkd` arrancan desde `~/.config/autostart/`; inicia sesión de nuevo para que arranquen.

## Agregar un archivo nuevo

1. Copia el archivo a la ruta espejo dentro de `linux/` (por ejemplo `~/.config/foo/foo.conf` va en `linux/config/foo/foo.conf`).
2. Ejecuta `linux/scan-secrets.sh linux/config/foo` y revisa cada coincidencia.
3. Si es un script, hazlo ejecutable y registra el bit en git: `git update-index --chmod=+x <ruta>`.
4. Haz commit y ejecuta `./install-linux.sh` para enlazarlo.

## Qué no se versiona

Gestores de contraseñas, mensajería, navegadores, clientes de sincronización, `gh`, configuraciones de herramientas de IA, aplicaciones Electron/JetBrains/Code, y archivos de sesión, caché, logs o bases de datos. Tampoco `*.bak`, `git/config` ni archivos generados por la máquina.
