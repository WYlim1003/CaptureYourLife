from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from app.dependencies import verify_token
from app.services.firebase_service import FirebaseService
import os
from datetime import datetime

router = APIRouter(prefix="/images", tags=["images"])
firebase_service = FirebaseService()
UPLOAD_DIR = "uploads"

os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.post("/upload")
async def upload_image(
    file: UploadFile = File(...), user: dict = Depends(verify_token)
):
    try:
        user_id = user["user_id"]

        file_name = f"{user_id}_{datetime.utcnow().timestamp()}_{file.filename}"
        file_path = os.path.join(UPLOAD_DIR, file_name)

        contents = await file.read()
        with open(file_path, "wb") as f:
            f.write(contents)

        image_metadata = firebase_service.save_image_metadata(
            user_id, file_name, len(contents)
        )

        return {
            "status": "success",
            "image_id": image_metadata["id"],
            "file_name": file_name,
            "file_size": len(contents),
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/{image_id}")
async def get_image(image_id: str, user: dict = Depends(verify_token)):
    try:
        db = firebase_service.db
        doc = db.collection("images").document(image_id).get()

        if not doc.exists:
            raise HTTPException(status_code=404, detail="Image not found")

        image_data = doc.to_dict()

        if image_data["user_id"] != user["user_id"]:
            raise HTTPException(status_code=403, detail="Unauthorized")

        file_path = os.path.join(UPLOAD_DIR, image_data["file_name"])
        if not os.path.exists(file_path):
            raise HTTPException(status_code=404, detail="File not found")

        return {"image_id": image_id, "file_name": image_data["file_name"]}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
