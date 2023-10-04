from pydantic_settings import BaseSettings

__all__ = ("BaseConfig",)


class BaseConfig(BaseSettings):
    class Config:
        env_file = ".env.local", ".env"
