---
description: Подготовить релиз — версия, CHANGELOG, тег
argument-hint: <новая версия, например 1.2.0>
---

Новая версия: $ARGUMENTS

1. Найди, где хранится версия:
   - Android: `versionName` и `versionCode` в `app/build.gradle(.kts)` — `versionCode` увеличь на 1.
   - Web/Node: `version` в `package.json`; для PWA — также имя кеша в `sw.js`, чтобы пользователи получили обновление.
   - Python: `version` в `pyproject.toml` или `__version__`.
2. Собери изменения с прошлого тега: `git log $(git describe --tags --abbrev=0 2>/dev/null)..HEAD --oneline` (если тегов нет — весь лог).
3. Обнови `CHANGELOG.md` (создай, если нет): раздел `## [версия] — дата` с группами «Добавлено / Исправлено / Изменено», по-русски, понятно для пользователя.
4. Закоммить: `chore: release v<версия>` и поставь тег `v<версия>`.
5. Не пушь сам. Покажи команду: `git push && git push --tags` — после неё GitHub Actions соберёт релиз, если workflow настроен на теги.
