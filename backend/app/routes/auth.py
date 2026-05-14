from fastapi import APIRouter, HTTPException
from app.models import UserRegister, UserLogin, TokenResponse, UserResponse
from app.services.firebase_service import FirebaseService
from app.config import settings
import jwt
import bcrypt
import uuid
from datetime import datetime, timedelta

router = APIRouter(prefix="/auth", tags=["auth"])
firebase_service = FirebaseService()


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())


def create_token(user_id: str) -> str:
    payload = {
        "sub": user_id,
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(days=7),
    }
    return jwt.encode(payload, settings.secret_key, algorithm="HS256")


@router.post("/register", response_model=TokenResponse)
async def register(user: UserRegister):
    try:
        user_id = str(uuid.uuid4())
        hashed_password = hash_password(user.password)

        firebase_service.create_user(user_id, user.email, user.username)

        user_data = {
            "id": user_id,
            "email": user.email,
            "username": user.username,
            "password_hash": hashed_password,
        }
        db = firebase_service.db
        db.collection("users").document(user_id).update(
            {"password_hash": hashed_password}
        )

        token = create_token(user_id)
        return TokenResponse(
            access_token=token,
            user=UserResponse(
                id=user_id,
                email=user.email,
                username=user.username,
                created_at=datetime.utcnow(),
            ),
        )
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/login", response_model=TokenResponse)
async def login(user: UserLogin):
    try:
        db = firebase_service.db
        users = db.collection("users").where("email", "==", user.email).stream()

        user_doc = None
        for doc in users:
            user_doc = doc
            break

        if not user_doc or not user_doc.exists:
            raise HTTPException(status_code=401, detail="Invalid credentials")

        user_data = user_doc.to_dict()
        password_hash = user_data.get("password_hash", "")

        if not verify_password(user.password, password_hash):
            raise HTTPException(status_code=401, detail="Invalid credentials")

        token = create_token(user_data["id"])
        return TokenResponse(
            access_token=token,
            user=UserResponse(
                id=user_data["id"],
                email=user_data["email"],
                username=user_data["username"],
                created_at=user_data.get("created_at", datetime.utcnow()),
            ),
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
