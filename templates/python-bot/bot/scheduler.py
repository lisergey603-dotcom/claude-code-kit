import logging

from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from .config import settings

log = logging.getLogger(__name__)


async def post_daily(bot: Bot) -> None:
    if not settings.channel_id:
        log.warning("CHANNEL_ID не задан — пост пропущен")
        return
    await bot.send_message(settings.channel_id, "Ежедневный пост: заготовка.")


def setup_scheduler(bot: Bot) -> AsyncIOScheduler:
    scheduler = AsyncIOScheduler(timezone=settings.tz)
    # Пример: каждый день в 10:00. Раскомментируй, когда настроишь канал.
    # scheduler.add_job(post_daily, "cron", hour=10, minute=0, args=[bot])
    return scheduler
