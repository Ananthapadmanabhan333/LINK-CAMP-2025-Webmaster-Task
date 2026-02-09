from typing import Any, List
from fastapi import APIRouter, Body, Depends, HTTPException
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session
from app.api import deps
from app.core import security
from app.models.user import User
from app.models.athlete_state import AthleteState
from app.schemas.user import User as UserSchema, UserCreate, UserUpdate

router = APIRouter()

@router.post("/", response_model=UserSchema)
def create_user(
    *,
    db: Session = Depends(deps.get_db),
    user_in: UserCreate,
) -> Any:
    """
    Create new user.
    """
    if db is None:
        raise HTTPException(status_code=503, detail="Database unavailable")
        
    user = db.query(User).filter(User.email == user_in.email).first()
    if user:
        raise HTTPException(
            status_code=400,
            detail="The user with this username already exists in the system.",
        )
    
    hashed_password = security.get_password_hash(user_in.password)
    db_obj = User(
        email=user_in.email,
        hashed_password=hashed_password,
        full_name=user_in.full_name,
        is_superuser=user_in.is_superuser,
        is_active=user_in.is_active,
        dob=user_in.dob,
        height_cm=user_in.height_cm,
        current_weight_kg=user_in.current_weight_kg,
        activity_level=user_in.activity_level
    )
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    
    # Create initial athlete state
    athlete_state = AthleteState(user_id=db_obj.id)
    db.add(athlete_state)
    db.commit()
    
    return db_obj

@router.get("/me", response_model=UserSchema)
def read_user_me(
    current_user: User = Depends(deps.get_mock_user),
) -> Any:
    """
    Get current user.
    """
    return current_user

@router.put("/me", response_model=UserSchema)
def update_user_me(
    *,
    db: Session = Depends(deps.get_db),
    user_in: UserUpdate,
    current_user: User = Depends(deps.get_mock_user),
) -> Any:
    """
    Update own user profile.
    """
    if db is None:
        raise HTTPException(status_code=503, detail="Database unavailable")
    
    # Update user fields
    update_data = user_in.dict(exclude_unset=True)
    for field, value in update_data.items():
        if hasattr(current_user, field):
            setattr(current_user, field, value)
    
    db.add(current_user)
    db.commit()
    db.refresh(current_user)
    return current_user
