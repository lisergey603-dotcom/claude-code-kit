from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    bot_token: str
    channel_id: str = ""
    tz: str = "Europe/Moscow"


settings = Settings()
