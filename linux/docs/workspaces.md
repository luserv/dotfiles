# Workspaces

Tienes 11 workspaces. Esta página explica cómo se navega entre ellos y por qué hay un script y un demonio de atajos de por medio.

## Navegación

| Atajo | Acción | Quién lo ejecuta |
|---|---|---|
| `Super+1` … `Super+0` | Ir directo al workspace | XFCE (`xdotool set_desktop N`) |
| `Super+Tab` | Siguiente workspace **con ventanas** | XFCE → `ws-cycle next` |
| `Super+Shift+Tab` | Anterior workspace **con ventanas** | `sxhkd` → `ws-cycle prev` |
| `Super+Shift+1` … `Super+Shift+0` | Mover la ventana activa al workspace N | XFCE (`move-window-to-workspace`) |
| `Super+Ctrl+Q` | Notificación con el estado | XFCE → `ws-notify.sh` |

## `ws-cycle`

`linux/bin/ws-cycle next|prev` salta solo entre los workspaces que tienen ventanas, más el actual, y da la vuelta en los extremos.

- Las ventanas "pegadas" a todos los workspaces (paneles, fondo, el propio conky) no cuentan: `wmctrl` las reporta con escritorio `-1`.
- Si solo el workspace actual tiene ventanas, no hace nada.
- Para llegar a un workspace vacío, usa `Super+1` … `Super+0`.

Ejemplo: con ventanas en los workspaces 1 y 3, y estando en el 3, `ws-cycle next` va al 1. Estando en el 5 (vacío), `next` va al 1 y `prev` al 3.

## `sxhkd` y `Super+Shift+Tab`

`Super+Shift+Tab` no se define en XFCE sino en `~/.config/sxhkd/sxhkdrc`:

```
super + shift + ISO_Left_Tab
    ~/.local/bin/ws-cycle prev
```

Se usa `ISO_Left_Tab` porque ese es el keysym que X11 genera con Shift+Tab. `sxhkd` arranca con la sesión desde `~/.config/autostart/sxhkd.desktop`.

Por qué no se hace con XFCE: `xfsettingsd` registra el atajo `<Super><Shift>Tab`, pero no lo dispara de forma fiable. No dejes un atajo `<Super><Shift>Tab` en el XML: competiría con `sxhkd` por la tecla.

## Notificación de estado

`linux/config/conky/ws-notify.sh` abre una notificación de 3 segundos que lista solo los workspaces con ventanas (con su cantidad) y el actual, marcado con `▶`.

## En el panel de Conky

La fila de puntos de la cabecera usa `modern/ws-state.sh`, que imprime un carácter por workspace: `A` activo, `O` con ventanas y `E` vacío. Ver [Panel de Conky](conky.md).

## Comandos útiles

```bash
wmctrl -d                  # lista de workspaces (el activo lleva *)
wmctrl -l                  # ventanas y su workspace (-1 = en todos)
xdotool get_desktop        # workspace actual (empieza en 0)
xdotool set_desktop 3      # ir al workspace 4
```

El subcomando es `set_desktop` con guion bajo; `set-desktop` no existe.
