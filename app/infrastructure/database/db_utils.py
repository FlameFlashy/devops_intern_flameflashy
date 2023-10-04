from sqlalchemy.ext.asyncio import (
    AsyncEngine,
    async_sessionmaker,
    create_async_engine,
)

from infrastructure.config import BaseConfig

__all__ = (
    "DBConfig",
    "create_engine",
    "create_sessionmaker",
    "build_async_db_url",
)


class DBConfig(BaseConfig):
    user: str
    password: str
    endpoint: str
    name: str

    class Config(BaseConfig.Config):
        env_prefix = "DB_"


def create_engine(db_config: DBConfig) -> AsyncEngine:
    return create_async_engine(build_async_db_url(db_config))


def create_sessionmaker(engine: AsyncEngine) -> async_sessionmaker:
    return async_sessionmaker(bind=engine)


def build_async_db_url(config: DBConfig) -> str:
    return f"postgresql+asyncpg://{config.user}:{config.password}@{config.endpoint}/{config.name}"  # noqa
