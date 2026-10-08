#!/usr/bin/env bash
# Создаёт проект из шаблона или подключает набор к существующему проекту.
#   ./new-project.sh <android|web-pwa|python-bot> <папка> [--merge]
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPL_DIR="$KIT_DIR/templates"

usage() {
  echo "Использование: $0 <android|web-pwa|python-bot> <папка> [--merge]"
  echo "  --merge  добавить файлы в существующий проект, ничего не перезаписывая"
  exit 1
}

[ $# -lt 2 ] && usage
STACK="$1"; TARGET="$2"; MERGE="${3:-}"
[ -d "$TPL_DIR/$STACK" ] || { echo "Нет шаблона '$STACK'"; usage; }

if [ -d "$TARGET" ] && [ -n "$(ls -A "$TARGET" 2>/dev/null)" ] && [ "$MERGE" != "--merge" ]; then
  echo "Папка $TARGET не пуста. Для существующего проекта добавьте --merge."
  exit 1
fi

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
NAME="$(basename "$TARGET")"

# Копирует файл, если его ещё нет. Служебные файлы шаблона (_stack.md, _commands.md, _gitignore) пропускаются.
copy_tree() {
  local src="$1"
  (cd "$src" && find . -type f ! -name '_stack.md' ! -name '_commands.md' ! -name '_gitignore' -print) | while read -r rel; do
    rel="${rel#./}"
    local dst="$TARGET/$rel"
    if [ -e "$dst" ]; then
      echo "  = $rel (уже есть, пропущен)"
      continue
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src/$rel" "$dst"
    echo "  + $rel"
  done
}

# Вставляет содержимое файла вместо строки-плейсхолдера
fill_placeholder() {
  local file="$1" placeholder="$2" content_file="$3"
  [ -f "$file" ] || return 0
  grep -q "$placeholder" "$file" || return 0
  awk -v ph="$placeholder" -v cf="$content_file" '
    index($0, ph) { while ((getline line < cf) > 0) print line; close(cf); next }
    { print }
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

echo "Шаблон: $STACK → $TARGET"
CLAUDE_EXISTED=0; [ -e "$TARGET/CLAUDE.md" ] && CLAUDE_EXISTED=1

copy_tree "$TPL_DIR/base"
copy_tree "$TPL_DIR/$STACK"

# Общие файлы из скиллов, чтобы не дублировать их в шаблонах
copy_shared() {
  local from="$1" rel="$2"
  if [ ! -e "$TARGET/$rel" ]; then
    mkdir -p "$(dirname "$TARGET/$rel")"
    cp "$from" "$TARGET/$rel"
    echo "  + $rel"
  fi
}
case "$STACK" in
  android) copy_shared "$KIT_DIR/global/skills/android-apk-ci/build-apk.yml" ".github/workflows/build-apk.yml" ;;
  web-pwa) copy_shared "$KIT_DIR/global/skills/pwa-checklist/sw.js" "sw.js" ;;
esac

# Заполняем CLAUDE.md, только если создали его сейчас
if [ "$CLAUDE_EXISTED" = 0 ]; then
  fill_placeholder "$TARGET/CLAUDE.md" "{{STACK_INFO}}" "$TPL_DIR/$STACK/_stack.md"
  fill_placeholder "$TARGET/CLAUDE.md" "{{COMMANDS_INFO}}" "$TPL_DIR/$STACK/_commands.md"
else
  echo "  ! CLAUDE.md уже был — не трогаю. Подсказки по стеку: $TPL_DIR/$STACK/_stack.md"
fi

# Имя проекта во всех свежих текстовых файлах
grep -rl "{{PROJECT_NAME}}" "$TARGET" --exclude-dir=.git 2>/dev/null | while read -r f; do
  sed -i.bak "s/{{PROJECT_NAME}}/$NAME/g" "$f" && rm -f "$f.bak"
done

# .gitignore: дописываем правила стека, если их ещё нет
if [ -f "$TPL_DIR/$STACK/_gitignore" ]; then
  touch "$TARGET/.gitignore"
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    grep -qxF "$line" "$TARGET/.gitignore" || echo "$line" >> "$TARGET/.gitignore"
  done < "$TPL_DIR/$STACK/_gitignore"
fi

if [ ! -d "$TARGET/.git" ]; then
  git -C "$TARGET" init -q -b main
  echo "  + git init"
fi

echo
echo "Готово. Дальше:"
echo "  cd \"$TARGET\" && claude"
echo "  /plan заполни CLAUDE.md по проекту"
