from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    app_name: str = "CaptureYourLife"
    debug: bool = True
    secret_key: str = "your-secret-key-change-in-production"

    firebase_project_id: Optional[str] = None
    firebase_private_key: Optional[str] = None
    firebase_client_email: Optional[str] = None

    replicate_api_token: Optional[str] = None

    server_host: str = "0.0.0.0"
    server_port: int = 8000

    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
