# Arranque en CachyOS (Limine + UKI)

Configuración de sistema para arrancar `linux-cachyos` sin depender de Omarchy.
Los archivos viven en `linux/system/` y **no** los enlaza el instalador: se copian a mano.

| Archivo | Destino | Para qué |
| --- | --- | --- |
| `mkinitcpio.conf.d/cachyos_hooks.conf` | `/etc/mkinitcpio.conf.d/` | Hooks del initramfs (`plymouth`, `encrypt`, `btrfs-overlayfs`) y módulo `thunderbolt` |
| `mkinitcpio.conf.d/cachyos_resume.conf` | `/etc/mkinitcpio.conf.d/` | Hook `resume` (hibernación) |
| `limine-entry-tool.d/z-cachyos.conf` | `/etc/limine-entry-tool.d/` | UKI `cachyos`, cmdline, orden de arranque y snapshots |
| `sddm.conf.d/z-cachyos-sddm.conf` | `/etc/sddm.conf.d/` | SDDM en X11 con tema `maldives` |

## Instalar

```fish
sudo install -m644 linux/system/mkinitcpio.conf.d/*.conf /etc/mkinitcpio.conf.d/
sudo install -m644 linux/system/limine-entry-tool.d/z-cachyos.conf /etc/limine-entry-tool.d/
sudo install -m644 linux/system/sddm.conf.d/z-cachyos-sddm.conf /etc/sddm.conf.d/
sudo limine-mkinitcpio
```

## Notas

- El prefijo `z-` en el drop-in de Limine es intencional: los drop-ins se leen en orden alfabético y el último gana.
- El `root=UUID=...` y `resume=` de `/etc/default/limine` son específicos de cada máquina y **no** se versionan.
- Si se reinstala el sistema, ajustar `BOOT_ORDER` en `/etc/default/limine` a `linux-cachyos, linux-cachyos-*, *, *fallback, Snapshots`.
