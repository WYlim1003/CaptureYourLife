import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import auth as firebase_auth
from app.config import settings
from fastapi import HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from typing import Optional
import json

db = None
security = HTTPBearer()


def init_firebase():
    global db
    if not firebase_admin._apps:
        try:
            if settings.firebase_private_key:
                cred_dict = {
                    "type": "service_account",
                    "project_id": settings.firebase_project_id,
                    "private_key": settings.firebase_private_key.replace('\\n', '\n'),
                    "client_email": settings.firebase_client_email,
                    "client_id": "000000000000000000000",
                    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
                    "token_uri": "https://oauth2.googleapis.com/token",
                }
                cred = credentials.Certificate(cred_dict)
                firebase_admin.initialize_app(cred)
            else:
                firebase_admin.initialize_app()
        except Exception as e:
            print(f"Firebase initialization warning: {e}")
    db = firestore.client()
    return db


def get_db():
    if db is None:
        init_firebase()
    return db


async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    token = credentials.credentials
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=["HS256"])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return {"user_id": user_id}
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
