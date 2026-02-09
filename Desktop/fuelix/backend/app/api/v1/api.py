from fastapi import APIRouter
from app.api.v1.endpoints import auth, users

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
from app.api.v1.endpoints import training
api_router.include_router(training.router, prefix="/training", tags=["training"])
from app.api.v1.endpoints import nutrition
api_router.include_router(nutrition.router, prefix="/nutrition", tags=["nutrition"])
from app.api.v1.endpoints import recovery
api_router.include_router(recovery.router, prefix="/recovery", tags=["recovery"])
from app.api.v1.endpoints import coach
api_router.include_router(coach.router, prefix="/coach", tags=["coach"])
from app.api.v1.endpoints import tasks
api_router.include_router(tasks.router, prefix="/tasks", tags=["tasks"])
from app.api.v1.endpoints import ai_trainer
api_router.include_router(ai_trainer.router, prefix="/ai-trainer", tags=["ai-trainer"])
from app.api.v1.endpoints import finetuning
api_router.include_router(finetuning.router, prefix="/finetuning", tags=["finetuning"])
from app.api.v1.endpoints import daily_metrics
api_router.include_router(daily_metrics.router, prefix="/daily-metrics", tags=["daily-metrics"])
