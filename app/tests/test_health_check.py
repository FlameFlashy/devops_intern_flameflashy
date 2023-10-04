from fastapi.testclient import TestClient


def test_health_check(web_client: TestClient) -> None:
    response = web_client.get("/health/")
    content = response.json()

    assert response.status_code == 200
    assert "status" in content
    assert "date" in content
    assert "message" in content
