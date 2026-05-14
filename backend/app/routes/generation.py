from fastapi import APIRouter, Depends, HTTPException
from app.models import GenerationRequest, GenerationResponse
from app.dependencies import verify_token
from app.services.firebase_service import FirebaseService
from app.services.ai_service import AIService
import uuid
from datetime import datetime

router = APIRouter(prefix="/generate", tags=["generation"])
firebase_service = FirebaseService()
ai_service = AIService()


@router.post("/sticker", response_model=GenerationResponse)
async def generate_sticker(request: GenerationRequest, user: dict = Depends(verify_token)):
    try:
        user_id = user["user_id"]

        result = ai_service.generate_sticker(image_url="", prompt="sticker")

        if result["status"] == "error":
            raise HTTPException(status_code=500, detail=result["message"])

        generation = firebase_service.save_generation(
            user_id=user_id,
            original_image_id=request.image_id,
            style="sticker",
            result_url=result["result_url"],
        )

        return GenerationResponse(
            id=generation["id"],
            user_id=generation["user_id"],
            original_image_id=generation["original_image_id"],
            style=generation["style"],
            status=generation["status"],
            result_url=generation["result_url"],
            created_at=generation["created_at"],
            updated_at=generation["updated_at"],
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/avatar", response_model=GenerationResponse)
async def generate_avatar(request: GenerationRequest, user: dict = Depends(verify_token)):
    try:
        user_id = user["user_id"]

        result = ai_service.generate_avatar(image_url="", style=request.style)

        if result["status"] == "error":
            raise HTTPException(status_code=500, detail=result["message"])

        generation = firebase_service.save_generation(
            user_id=user_id,
            original_image_id=request.image_id,
            style=request.style,
            result_url=result["result_url"],
        )

        return GenerationResponse(
            id=generation["id"],
            user_id=generation["user_id"],
            original_image_id=generation["original_image_id"],
            style=generation["style"],
            status=generation["status"],
            result_url=generation["result_url"],
            created_at=generation["created_at"],
            updated_at=generation["updated_at"],
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/history")
async def get_generation_history(user: dict = Depends(verify_token)):
    try:
        user_id = user["user_id"]
        generations = firebase_service.get_user_generations(user_id)
        return {"generations": generations}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
