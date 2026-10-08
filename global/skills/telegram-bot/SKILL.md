---
name: telegram-bot
description: Создание и доработка Telegram-ботов и автопостинга в каналы на Python (aiogram 3, APScheduler) — структура проекта, хендлеры, расписание постов, запуск на сервере. Используй для любых задач с Telegram-ботами и каналами.
---

# Telegram-бот на aiogram 3

## Структура
```
bot/
├── __main__.py        точка входа: python -m bot
├── config.py          настройки из .env
├── handlers/
│   ├── __init__.py    сборка роутеров
│   └── start.py
├── services/          логика: API, генерация постов, БД
└── scheduler.py       расписание автопостинга
.env.example
requirements.txt
```

## Минимальный каркас
Готовый каркас уже лежит в шаблоне `templates/python-bot`. Ключевые моменты:

```python
# config.py
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env")
    bot_token: str
    channel_id: str = ""        # @channel или -100...
    tz: str = "Europe/Moscow"

settings = Settings()
```

```python
# scheduler.py — пост каждый день в 10:00 по Москве
from apscheduler.schedulers.asyncio import AsyncIOScheduler

def setup_scheduler(bot) -> AsyncIOScheduler:
    sch = AsyncIOScheduler(timezone=settings.tz)
    sch.add_job(post_daily, "cron", hour=10, minute=0, args=[bot])
    return sch
```

## Постинг в канал
- Бот должен быть **администратором канала** с правом публикации.
- `channel_id`: `@username` для публичного, `-100…` для приватного (узнать — переслать пост из канала боту @getidsbot или аналогу).
- Разметка: `parse_mode="HTML"` надёжнее Markdown — меньше проблем с экранированием.
- Лимиты: не больше ~20 сообщений в минуту в один чат. При `TelegramRetryAfter` — ждать `e.retry_after` секунд.

## Запуск на сервере (systemd)
```ini
# /etc/systemd/system/mybot.service
[Unit]
Description=My Telegram bot
After=network-online.target

[Service]
WorkingDirectory=/opt/mybot
ExecStart=/opt/mybot/.venv/bin/python -m bot
Restart=always
RestartSec=5
EnvironmentFile=/opt/mybot/.env

[Install]
WantedBy=multi-user.target
```
`sudo systemctl enable --now mybot`, логи: `journalctl -u mybot -f`.

## Частые проблемы
- `Conflict: terminated by other getUpdates request` — запущены две копии бота с одним токеном.
- `chat not found` — бот не добавлен в канал или неверный `channel_id`.
- Посты уходят не в то время — у планировщика не задан `timezone`.
