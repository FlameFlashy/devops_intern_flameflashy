from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from infrastructure.database.db_utils import (
    DBConfig,
    create_engine,
    create_sessionmaker,
)

from .controllers import main_router
from .dependencies.db import get_session, get_session_imp


def register_routers(app: FastAPI) -> None:
    app.include_router(main_router.router)


def register_db(app: FastAPI) -> None:
    config = DBConfig()
    engine = create_engine(config)
    session_maker = create_sessionmaker(engine)

    app.dependency_overrides[get_session] = get_session_imp(session_maker)


def register_cors(app: FastAPI) -> None:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )


def create_app() -> FastAPI:
    app = FastAPI()
    register_db(app)
    register_routers(app)
    register_cors(app)

    return app
