---
description: Запустить сборку и тесты под стек проекта и разобрать падения
---

Определи стек проекта и запусти проверки:

| Признак | Команды |
|---|---|
| `gradlew` / `build.gradle(.kts)` | `./gradlew assembleDebug`, `./gradlew test`, `./gradlew lint` |
| `package.json` | `npm run build`, `npm test` (если скрипты есть), `npm run lint` |
| `pyproject.toml` / `requirements.txt` | `ruff check .`, `python -m pytest -q` |
| Только HTML/JS без сборщика | проверь `manifest.json`, `sw.js`, битые ссылки на файлы |

Если локально собрать нельзя (например, нет Android SDK) — посмотри последний прогон CI: `gh run list --limit 3`, а при падении `gh run view <id> --log-failed`.

Итог:
- ✅ что прошло
- ❌ что упало — причина в одну строку и предложение исправления

Не чини сам без запроса — только отчёт. Если всё зелёное — одна строка.
