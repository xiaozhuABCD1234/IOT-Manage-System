from fastapi import APIRouter
from utils import color

router = APIRouter()


@router.get("/colors")
async def generate_colors(n: int) -> list[str]:
    return color.generate_colors(n)
