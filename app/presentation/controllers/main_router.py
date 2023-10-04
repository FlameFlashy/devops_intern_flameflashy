from fastapi import APIRouter

from . import healthcheck

router = APIRouter()
router.include_router(healthcheck.router)
