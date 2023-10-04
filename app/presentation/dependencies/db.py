from typing import AsyncGenerator, Callable

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker


async def get_session() -> AsyncSession:  # type: ignore
    pass


def get_session_imp(
    session_maker: async_sessionmaker,
) -> Callable[[], AsyncGenerator[AsyncSession, None]]:
    async def _get_session() -> AsyncGenerator[AsyncSession, None]:
        async with session_maker() as session:
            yield session

    return _get_session
