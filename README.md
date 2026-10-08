# claude-code-kit

Личный набор для Claude Code: глобальные настройки, команды, агенты, скиллы и шаблоны новых проектов под Android, веб/PWA и Python/Telegram-ботов.

## Что внутри

```
claude-code-kit/
├── global/                 → ставится в ~/.claude (работает во всех проектах)
│   ├── CLAUDE.md           общие правила работы
│   ├── settings.json       разрешения, запреты, хуки
│   ├── commands/           slash-команды: /plan /fix /review /commit /test /explain /release /handoff
│   ├── agents/             агенты: code-reviewer, debugger, android-dev, web-dev, python-bot-dev
│   ├── skills/             скиллы: android-apk-ci, pwa-checklist, telegram-bot
│   └── hooks/              protect-secrets.sh — не даёт трогать .env, ключи и keystore
├── templates/              → шаблоны для новых проектов
│   ├── base/               общее для любого проекта (CLAUDE.md, .claude/, .gitignore)
│   ├── android/            + workflow сборки APK в GitHub Actions
│   ├── web-pwa/            + деплой на GitHub Pages
│   └── python-bot/         + структура бота, .env.example
├── install.sh              установить global/ в ~/.claude
└── new-project.sh          создать проект из шаблона
```

## Установка

```bash
git clone https://github.com/<ваш-логин>/claude-code-kit.git
cd claude-code-kit
./install.sh            # ссылки (обновляются через git pull)
./install.sh --copy     # или копии файлов
```

Существующие файлы в `~/.claude` не затираются: перед заменой делается резервная копия `*.bak-ДАТА`.

## Новый проект

```bash
./new-project.sh android  ~/projects/my-app
./new-project.sh web-pwa  ~/projects/my-site
./new-project.sh python-bot ~/projects/my-bot
```

Скрипт копирует `base/` + выбранный шаблон, подставляет имя проекта и делает `git init`. Дальше откройте папку в Claude Code и запустите `/plan`, чтобы заполнить CLAUDE.md под проект.

Подключить набор к уже существующему проекту (например, poker-vision-ai или skazka):

```bash
./new-project.sh android ~/projects/poker-vision-ai --merge
```

С `--merge` уже существующие файлы не перезаписываются — добавляется только то, чего нет.

## Команды

| Команда | Что делает |
|---|---|
| `/plan <задача>` | Разбирает задачу, читает код, предлагает план по шагам — без правок |
| `/fix <ошибка>` | Находит причину бага, чинит минимальной правкой, проверяет |
| `/review` | Ревью текущих изменений (git diff) через агента code-reviewer |
| `/test` | Запускает сборку и тесты под стек проекта, разбирает падения |
| `/commit` | Аккуратный коммит с понятным сообщением |
| `/explain <файл или тема>` | Объясняет код простыми словами |
| `/release <версия>` | Поднимает версию, обновляет CHANGELOG, ставит тег |
| `/handoff` | Записывает в NOTES.md, где остановились — чтобы продолжить в новой сессии |

## Агенты

Вызываются сами, когда задача подходит, или явно: «используй агента debugger».

- **code-reviewer** — ищет баги, утечки секретов, лишний код
- **debugger** — разбирает падения, логи, стектрейсы
- **android-dev** — Kotlin, Gradle, Compose, сборка APK
- **web-dev** — HTML/CSS/JS, PWA, вёрстка под телефон
- **python-bot-dev** — Python, aiogram, планировщики, API

## Хук защиты секретов

`protect-secrets.sh` блокирует чтение и правку `.env`, `*.keystore`, `*.jks`, `google-services.json`, приватных ключей. Если файл действительно нужно поменять — сделайте это руками.

## Обновление

```bash
cd claude-code-kit && git pull
```

При установке ссылками изменения подхватятся сразу.
