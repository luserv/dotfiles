# Solución de problemas

Trampas encontradas al armar este setup y cómo se resolvieron.

## Las terminales abren zsh (o muestran el asistente `zsh-newuser-install`)

Tu shell de login es fish, pero las terminales lanzadas por atajos usan la variable `SHELL` del proceso que las lanza. Si reiniciaste `xfsettingsd`, `sxhkd` o `conky` desde una shell con otro `SHELL` (por ejemplo zsh), esos procesos la heredan.

Compruébalo y reinicia con el valor correcto:

```bash
tr '\0' '\n' < /proc/$(pgrep -x xfsettingsd)/environ | rg '^SHELL='
setsid env SHELL=/bin/fish xfsettingsd --replace >/dev/null 2>&1 &
```

Haz lo mismo con `sxhkd` y `conky` si también heredaron el valor equivocado. Cerrar sesión y volver a entrar también lo corrige.

## `Super+Shift+Tab` solo funciona apretando Shift primero

Había un atajo asignado a `Super_L` solo (para abrir un menú). Captura la tecla Super y se come la combinación cuando se aprieta Super antes que Shift. Quita el atajo `Super_L` y no vuelvas a asignar ninguno a una tecla modificadora sola:

```bash
xfconf-query -c xfce4-keyboard-shortcuts -r -p '/commands/custom/Super_L'
```

Además, `xfsettingsd` no dispara de forma fiable las combinaciones con `Shift+Tab`; por eso `Super+Shift+Tab` vive en `sxhkd` con el keysym `ISO_Left_Tab`. No dejes un atajo `<Super><Shift>Tab` en el XML: `sxhkd` avisa `Could not grab key … already grabbed` si otro proceso tiene la combinación.

## Un atajo con `xdotool` no hace nada

El subcomando es `set_desktop` (con guion bajo). `xdotool set-desktop` no existe y falla en silencio cuando se ejecuta desde un atajo. Para moverse relativamente: `xdotool set_desktop --relative 1` (o `-- -1` para retroceder). El caso con vuelta al otro extremo lo resuelve [`ws-cycle`](workspaces.md).

## Un atajo no se dispara

Comprueba, en este orden:

1. Que la combinación no esté tomada en otro canal (`commands` y `xfwm4`): `xfconf-query -c xfce4-keyboard-shortcuts -v -l | rg -i '<Super><Alt>x'`.
2. Que el comando funcione ejecutado a mano en una terminal.
3. Que el script tenga permiso de ejecución (`ls -l`) y la ruta exista.
4. Si el atajo lleva `Shift` y una tecla especial (`Tab`, símbolos), pruébalo con `sxhkd`.

## Conky

- **No se ve el panel o queda debajo de las ventanas:** es una ventana de tipo `desktop`, así que las demás ventanas la tapan. Es el comportamiento esperado.
- **Avisos de ajustes obsoletos:** en conky 1.25 `own_window_transparent`, `own_window_argb_visual` y `own_window_argb_value` están obsoletos. Usa `own_window_color = '#00000000'`. `cairo_xlib_surface_create` también: `modern.lua` usa `conky_surface()` cuando existe.
- **`freq_g 0` da aviso:** los CPU se numeran desde 1 (`${freq_g 1}`).
- **Cambios que no se ven:** reinicia conky; los cambios en `modern.lua` no se aplican en caliente.

## Editar configuraciones de conky con `sd`

`sd` interpreta `${nombre}` del texto de reemplazo como un grupo de captura y lo vacía: una línea de conky con `${cpu}` queda sin valores. Para editar archivos de conky usa un editor, o duplica el dólar (`$${cpu}`).

## Un script se commitea sin permiso de ejecución

Si `git ls-tree HEAD ruta` muestra `100644` en un script, el instalador lo enlazará sin permiso. Corrígelo antes de subir:

```bash
chmod +x linux/bin/mi-script
git update-index --chmod=+x linux/bin/mi-script
git commit --amend --no-edit   # solo si el commit aún no se pushó
```

## `caffeine-ng` no aparece

Su icono necesita una bandeja del sistema, y este setup no tiene panel ni barra. Se reemplazó por `xfce-idle-toggle` con el atajo `Super+Alt+C` (ver [Menús y utilidades](menus-y-utilidades.md)).

## El escaneo de secretos sale con código 1

`linux/scan-secrets.sh` avisa con código 1 cuando encuentra palabras como `password` o `token`, incluso en texto de documentación. Revisa cada coincidencia: si son ejemplos o avisos, no hay problema.

## Problemas conocidos

- `Super+Shift+PageUp` y `Super+Shift+PageDown` ejecutan el mismo comando (mueven la ventana al siguiente workspace); uno está mal definido.
- El atajo de `flameshot` aparece con el nombre de tecla `<Super>Shift<Print>`, que es inusual y puede no dispararse.
