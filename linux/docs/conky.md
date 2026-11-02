# Panel de Conky

Panel de estado en el escritorio, dibujado con Cairo desde Lua (paleta Nord, fondo redondeado translúcido). Reemplaza a la barra: no hay polybar ni panel de XFCE.

## Archivos

| Archivo | Función |
|---|---|
| `linux/config/conky/modern/conky.conf` | Ventana de conky: tamaño, posición, tipo `desktop` |
| `linux/config/conky/modern/modern.lua` | Todo el dibujo (anillos, barras, textos) |
| `linux/config/conky/modern/ws-state.sh` | Estado de cada workspace: `A` activo, `O` con ventanas, `E` vacío |
| `linux/config/conky/modern/audio-state.sh` | Volumen y streams de audio activos, con su workspace |
| `linux/config/autostart/conky.desktop` | Arranca el panel con la sesión (espera 5 s) |
| `linux/config/conky/conky.conf` | Panel anterior en texto plano, como alternativa |

## Qué muestra

De arriba abajo:

1. **Cabecera:** hora grande y fecha; a la derecha, uptime, IP de `wlan0` y batería (icono con el nivel y el estado). Si caffeine está activo, aparece `Keep awake` a la izquierda.
2. **Workspaces:** un punto por workspace. Activo: grande y celeste. Con ventanas: relleno. Vacío: solo contorno.
3. **Anillos:** CPU (con temperatura y GHz), RAM y disco `/`, cada uno con porcentaje y cantidades.
4. **Threads:** una barra vertical por hilo de CPU, con su número.
5. **Red:** velocidad de bajada y de subida de `wlan0`.
6. **Audio:** barra de volumen y hasta dos streams sonando, con el workspace de la ventana que reproduce.
7. **Top CPU y Top RAM:** los 3 procesos principales (la RAM con su consumo en MB o GB).

Los anillos y las barras cambian a amarillo desde el 60% y a rojo desde el 80%. La batería usa amarillo bajo 30% y rojo bajo 15% mientras se descarga.

## Tamaño

Un único factor, `SCALE`, al inicio de `modern.lua` (ahora `1.15`), escala texto, anillos y espacios. Si lo cambias, ajusta también `modern/conky.conf` (el ancho y el alto no se calculan solos):

| Valor | Fórmula |
|---|---|
| `minimum_width` y `maximum_width` | `360 × SCALE` (con 1.15: 414) |
| `minimum_height` | `794 × SCALE` (con 1.15: 914) |

Si añades o quitas secciones, actualiza también la altura lógica `H` en `modern.lua` (ahora 794).

## Aplicar cambios

Tras cambiar `modern.lua` o `conky.conf`, reinicia conky para estar seguro de que toma los cambios. Reinícialo con el mismo `SHELL` de la sesión (ver [Solución de problemas](solucion-de-problemas.md)):

```bash
pkill -x conky
setsid env SHELL=/bin/fish conky -c ~/.config/conky/modern/conky.conf >/dev/null 2>&1 &
```

## Valores fijos para tu equipo

Ajústalos en `modern.lua` si tu hardware es otro:

| Valor | Dónde | Por defecto |
|---|---|---|
| Interfaz de red | `draw_header` y `draw_network` | `wlan0` |
| Sensor de temperatura | `draw_gauges` | `coretemp`, sensor 1 |
| Batería y cargador | `BATTERY` y `AC_ONLINE` | `BAT0` y `AC` |
| Disco | `draw_gauges` | `/` |
| Hilos de CPU | `nproc` (automático) | hasta 16 |

Sin batería (`BAT0`), esa línea simplemente no se dibuja.

## Requisitos

- `conky` compilado con Lua, Cairo e Imlib2 (`conky -v` los lista).
- Un compositor activo (`picom`) para la transparencia.
- `wmctrl` y `xdotool` (workspaces), `wpctl`, `pactl` y `jq` (audio), y `nproc`.
- Una fuente `DejaVu Sans` y `DejaVu Sans Mono`.

## Volver al panel anterior

Cambia `Exec` en `~/.config/autostart/conky.desktop` para que apunte a `~/.config/conky/conky.conf`. El panel anterior es texto plano (`workspaces.sh` y `ws-notify.sh` siguen en `linux/config/conky/`).
