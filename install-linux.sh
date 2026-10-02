#!/usr/bin/env bash
# Linux dotfiles installer: symlinks files from linux/ into $HOME.
# Usage: ./install-linux.sh [--dry-run] [--only config|home|bin|packages-info]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINUX_DIR="$REPO_DIR/linux"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.dotfiles-backup/$TIMESTAMP"

DRY_RUN=0
ONLY=""
LINKED=0
SKIPPED=0
BACKED_UP=0

usage() {
  cat <<'EOF'
Uso: ./install-linux.sh [--dry-run] [--only config|home|bin|packages-info]

  --dry-run   Muestra lo que se haria sin modificar nada.
  --only X    Procesa solo una seccion: config, home, bin o packages-info.
  -h, --help  Muestra esta ayuda.
EOF
}

info() { printf '%s\n' "$*"; }
err() { printf 'error: %s\n' "$*" >&2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --only)
      [ $# -ge 2 ] || { err "--only requiere un valor"; usage >&2; exit 2; }
      ONLY="$2"
      shift
      ;;
    -h | --help) usage; exit 0 ;;
    *) err "opcion desconocida: $1"; usage >&2; exit 2 ;;
  esac
  shift
done

case "$ONLY" in
  "" | config | home | bin | packages-info) ;;
  *) err "valor invalido para --only: $ONLY"; usage >&2; exit 2 ;;
esac

if [ "$(id -u)" -eq 0 ]; then
  err "no ejecutes este script como root; usa tu usuario normal."
  exit 1
fi

wants() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }

# link_file <source> <target>
link_file() {
  local src="$1" dst="$2"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    info "ya enlazado: $dst"
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local rel="${dst#"$HOME"/}"
    local backup="$BACKUP_DIR/$rel"
    if [ "$DRY_RUN" -eq 1 ]; then
      info "[dry-run] respaldo: $dst -> $backup"
    else
      mkdir -p "$(dirname "$backup")"
      mv "$dst" "$backup"
      info "respaldo: $dst -> $backup"
    fi
    BACKED_UP=$((BACKED_UP + 1))
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    info "[dry-run] enlazar: $dst -> $src"
  else
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    info "enlazado: $dst -> $src"
  fi
  LINKED=$((LINKED + 1))
}

# link_tree <source dir> <target dir>: link every file, never whole directories.
link_tree() {
  local src_root="$1" dst_root="$2"
  [ -d "$src_root" ] || { info "omitido (no existe): $src_root"; return 0; }
  local file
  while IFS= read -r -d '' file; do
    link_file "$file" "$dst_root/${file#"$src_root"/}"
  done < <(find "$src_root" -type f -print0 | sort -z)
}

packages_info() {
  cat <<EOF
Listas de paquetes (no se instala nada automaticamente):

  Paquetes oficiales (pacman):
    sudo pacman -S --needed - < "$LINUX_DIR/packages/pacman-explicit.txt"

  Paquetes AUR (requiere un helper como paru o yay):
    paru -S --needed - < "$LINUX_DIR/packages/aur.txt"

Revisa las listas antes de instalar: reflejan el sistema de origen.
EOF
}

if [ "$DRY_RUN" -eq 1 ]; then
  info "Modo simulacion (--dry-run): no se modificara nada."
fi

wants config && link_tree "$LINUX_DIR/config" "$HOME/.config"
wants home && link_tree "$LINUX_DIR/home" "$HOME"
wants bin && link_tree "$LINUX_DIR/bin" "$HOME/.local/bin"
wants packages-info && packages_info

if [ -z "$ONLY" ] || [ "$ONLY" != "packages-info" ]; then
  info ""
  info "Resumen: $LINKED enlazados, $SKIPPED ya enlazados, $BACKED_UP respaldados."
  if [ "$BACKED_UP" -gt 0 ] && [ "$DRY_RUN" -eq 0 ]; then
    info "Respaldos en: $BACKUP_DIR"
  fi
fi
