#!/usr/bin/env bash
# Устанавливает global/ в ~/.claude, не трогая ваши собственные команды, агентов и скиллы.
#   ./install.sh          — символические ссылки (обновляются через git pull)
#   ./install.sh --copy   — копии файлов
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$KIT_DIR/global"
DEST="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
MODE="link"
[ "${1:-}" = "--copy" ] && MODE="copy"
STAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$DEST"
chmod +x "$SRC/hooks/"*.sh 2>/dev/null || true

# Поставить один файл или папку: from -> to
place() {
  local from="$1" to="$2"
  if [ -L "$to" ] && [ "$(readlink "$to")" = "$from" ]; then
    echo "  = ${to#$DEST/} (уже установлен)"; return
  fi
  if [ -e "$to" ] || [ -L "$to" ]; then
    mv "$to" "$to.bak-$STAMP"
    echo "  ↺ ${to#$DEST/} — старая версия сохранена как .bak-$STAMP"
  fi
  if [ "$MODE" = "link" ]; then ln -s "$from" "$to"; else cp -R "$from" "$to"; fi
  echo "  ✓ ${to#$DEST/}"
}

echo "Установка в $DEST ($MODE)"

# 1. CLAUDE.md
place "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"

# 2. Папки — поштучно, чтобы ваши собственные файлы рядом остались на месте
for dir in commands agents skills hooks; do
  mkdir -p "$DEST/$dir"
  for item in "$SRC/$dir"/*; do
    place "$item" "$DEST/$dir/$(basename "$item")"
  done
done

# 3. settings.json — объединяем с существующим, а не заменяем
if [ ! -e "$DEST/settings.json" ]; then
  cp "$SRC/settings.json" "$DEST/settings.json"
  echo "  ✓ settings.json"
elif command -v python3 >/dev/null 2>&1; then
  cp "$DEST/settings.json" "$DEST/settings.json.bak-$STAMP"
  python3 - "$DEST/settings.json" "$SRC/settings.json" <<'PY'
import json, sys
dst_path, src_path = sys.argv[1], sys.argv[2]
dst = json.load(open(dst_path, encoding="utf-8"))
src = json.load(open(src_path, encoding="utf-8"))

perms = dst.setdefault("permissions", {})
for key in ("allow", "deny"):
    cur = perms.setdefault(key, [])
    for rule in src.get("permissions", {}).get(key, []):
        if rule not in cur:
            cur.append(rule)

hooks = dst.setdefault("hooks", {})
for event, groups in src.get("hooks", {}).items():
    cur = hooks.setdefault(event, [])
    for g in groups:
        if g not in cur:
            cur.append(g)

dst.setdefault("$schema", src.get("$schema"))
json.dump(dst, open(dst_path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
PY
  echo "  ✓ settings.json — объединён с вашим (копия: settings.json.bak-$STAMP)"
else
  cp "$SRC/settings.json" "$DEST/settings.kit.json"
  echo "  ! settings.json уже есть, python3 не найден — наш вариант сохранён как settings.kit.json, перенесите нужное вручную"
fi

echo
echo "Готово. Перезапустите Claude Code, чтобы подхватились настройки."
