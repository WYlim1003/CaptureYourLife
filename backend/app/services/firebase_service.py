from app.dependencies import get_db
from datetime import datetime
import uuid


class FirebaseService:
    def __init__(self):
        self.db = get_db()

    def create_user(self, user_id: str, email: str, username: str):
        user_data = {
            "id": user_id,
            "email": email,
            "username": username,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        self.db.collection("users").document(user_id).set(user_data)
        return user_data

    def get_user(self, user_id: str):
        doc = self.db.collection("users").document(user_id).get()
        if doc.exists:
            return doc.to_dict()
        return None

    def save_image_metadata(self, user_id: str, file_name: str, file_size: int):
        image_id = str(uuid.uuid4())
        image_data = {
            "id": image_id,
            "user_id": user_id,
            "file_name": file_name,
            "file_size": file_size,
            "created_at": datetime.utcnow(),
        }
        self.db.collection("images").document(image_id).set(image_data)
        return image_data

    def save_generation(
        self, user_id: str, original_image_id: str, style: str, result_url: str
    ):
        generation_id = str(uuid.uuid4())
        generation_data = {
            "id": generation_id,
            "user_id": user_id,
            "original_image_id": original_image_id,
            "style": style,
            "status": "completed",
            "result_url": result_url,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow(),
        }
        self.db.collection("generations").document(generation_id).set(generation_data)
        return generation_data

    def get_user_generations(self, user_id: str):
        docs = (
            self.db.collection("generations")
            .where("user_id", "==", user_id)
            .stream()
        )
        return [doc.to_dict() for doc in docs]
