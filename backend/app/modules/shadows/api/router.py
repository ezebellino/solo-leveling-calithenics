from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.config import settings
from app.database import get_db
from app.modules.shadows.api.schemas import ShadowProgressionResponse, ShadowUnlockResponse
from app.modules.shadows.application.service import get_default_user_shadow_progression

router = APIRouter(prefix=settings.api_prefix, tags=["shadows"])


@router.get("/shadows/progression", response_model=ShadowProgressionResponse)
def read_shadow_progression(db: Session = Depends(get_db)) -> ShadowProgressionResponse:
    progression = get_default_user_shadow_progression(db)
    return ShadowProgressionResponse(
        shadowArmy=progression.shadow_army,
        unlockedShadows=[
            ShadowUnlockResponse(code=item.code, obtainedAt=item.obtained_at)
            for item in progression.unlocked_shadows
        ],
    )

