from datetime import datetime

from fastapi import APIRouter, status

router = APIRouter(tags=["health_check"])


@router.get("/health")
def health_check() -> dict:
    return {
        "status": status.HTTP_200_OK,
        "date": datetime.now(),
        "message": "I'm alive",
    }
