#!/usr/bin/env bash
# PreToolUse-хук: блокирует чтение и правку файлов с секретами.
# Claude Code передаёт на stdin JSON вызова инструмента.
# Код выхода 2 = отказ, текст из stderr увидит Claude.

input="$(cat)"

# Достаём путь файла без jq (его может не быть)
file_path="$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed 's/.*"\([^"]*\)"$/\1/')"

[ -z "$file_path" ] && exit 0

name="$(basename "$file_path")"

# Разрешённые примеры
case "$name" in
  .env.example|.env.sample|.env.template) exit 0 ;;
esac

case "$name" in
  .env|.env.*|*.keystore|*.jks|*.p12|*.pem|*.key|id_rsa*|id_ed25519*|google-services.json|keystore.properties|secrets.*|credentials.json)
    echo "Заблокировано protect-secrets: '$name' может содержать секреты. Если файл правда нужно изменить — пользователь сделает это вручную." >&2
    exit 2
    ;;
esac

exit 0
