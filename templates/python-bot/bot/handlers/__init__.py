from aiogram import Router

from . import start


def get_router() -> Router:
    router = Router()
    router.include_router(start.router)
    return router
