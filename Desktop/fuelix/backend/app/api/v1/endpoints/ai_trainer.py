from fastapi import APIRouter
from app.schemas.ai_trainer import WorkoutGenerationRequest, WorkoutResponse
from app.ai_engine.workout_generator import WorkoutGenerator

router = APIRouter()
generator = WorkoutGenerator()

@router.post("/generate", response_model=WorkoutResponse)
def generate_workout(request: WorkoutGenerationRequest):
    """
    Generate AI-powered workout without database dependencies.
    """
    # Create a simple state dict for the workout generator
    state_dict = {
        "cns_fatigue": 30.0,  # Default moderate fatigue
        "muscular_upper_fatigue": 25.0,
        "muscular_lower_fatigue": 25.0,
        "cardio_fatigue": 20.0
    }
    
    # Generate workout using the correct method name
    workout_data = generator.generate_session(
        state=state_dict,
        equipment=request.equipment_available or ["bodyweight", "dumbbells"],
        time_available=request.time_available_minutes,
        blocked_movements=[],
        workout_type=request.workout_type,
        difficulty=request.difficulty
    )
    
    return WorkoutResponse(**workout_data)
