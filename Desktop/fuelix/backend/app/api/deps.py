from typing import Generator, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from pydantic import ValidationError
from sqlalchemy.orm import Session
from app.core import security
from app.core.config import settings
from app.db.session import SessionLocal
from app.models.user import User
from app.schemas.token import TokenPayload

reusable_oauth2 = OAuth2PasswordBearer(
    tokenUrl=f"{settings.API_V1_STR}/auth/access-token"
)

def get_db() -> Generator:
    """
    Database session dependency.
    Handles connection errors gracefully for demo purposes.
    """
    try:
        db = SessionLocal()
        yield db
    except Exception as e:
        print(f"Database connection failed: {e}")
        # Yield None if database is unavailable
        yield None
    finally:
        try:
            if db:
                db.close()
        except:
            pass

def get_current_user(
    db: Session = Depends(get_db), token: str = Depends(reusable_oauth2)
) -> User:
    if token == "mock_token_for_dev":
        return get_mock_user(db)
        
    try:
        payload = jwt.decode(
            token, settings.SECRET_KEY, algorithms=[security.ALGORITHM]
        )
        token_data = TokenPayload(**payload)
    except (JWTError, ValidationError):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Could not validate credentials",
        )
    user = db.query(User).filter(User.id == token_data.sub).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

def get_mock_user(db: Session = Depends(get_db)) -> User:
    """
    For MVP: Returns a mock user to bypass authentication.
    In production, remove this and use proper authentication.
    """
    # Create a mock user object without database access
    mock_user = User(
        id=1,
        email="test@fuelix.com",
        full_name="Test User",
        hashed_password="mock_hash",
        is_active=True,
        current_weight_kg=75.0,
        activity_level="moderate",
        equipment_access=["bodyweight", "dumbbells"]
    )
    return mock_user
