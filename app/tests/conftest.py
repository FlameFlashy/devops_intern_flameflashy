from typing import Generator

from fastapi.testclient import TestClient
from pytest import fixture
from pytest_mock import MockFixture

from presentation.main import create_app


@fixture
def web_client(mocker: MockFixture) -> Generator[TestClient, None, None]:
    mocker.patch("presentation.main.register_db")

    yield TestClient(create_app())
