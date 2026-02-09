from typing import Dict, Any, List
from sqlalchemy.orm import Session
from app.models.user import User
from app.models.athlete_state import AthleteState
from app.models.daily_log import DailyLog
from app.models.training import TrainingSession
from datetime import date

class ContextManager:
    """
    Aggregates all relevant user data into a structured context for the LLM.
    """
    
    @staticmethod
    def build_context(user: User, db: Session) -> str:
        """
        Build context string for LLM. Returns minimal context if database is unavailable.
        """
        # Always return at least basic user info
        basic_context = f"User: {user.full_name}, Weight: {user.current_weight_kg}kg, Activity: {user.activity_level}"
        
        # If no database session, return basic context only
        if db is None:
            return basic_context + "\nNote: Full training history unavailable"
        
        try:
            # Try to get additional context from database
            context_parts = [basic_context]
            
            # Athlete State (Fatigue) - optional
            try:
                state = db.query(AthleteState).filter(AthleteState.user_id == user.id).first()
                if state:
                    context_parts.append(
                        f"\nFatigue State:\n"
                        f"- CNS: {state.cns_fatigue:.1f}%\n"
                        f"- Upper Body: {state.muscular_fatigue_upper:.1f}%\n"
                        f"- Lower Body: {state.muscular_fatigue_lower:.1f}%\n"
                        f"- Cardio: {state.cardio_fatigue:.1f}%"
                    )
            except:
                pass  # Skip if table doesn't exist
            
            # Recent Training - optional
            try:
                sessions = db.query(TrainingSession).filter(
                    TrainingSession.user_id == user.id
                ).order_by(TrainingSession.started_at.desc()).limit(3).all()
                
                if sessions:
                    history_str = "\nRecent Training:\n"
                    for s in sessions:
                        history_str += f"- {s.type} on {s.started_at.date()}\n"
                    context_parts.append(history_str)
            except:
                pass  # Skip if table doesn't exist
            
            # Daily Logs - optional
            try:
                today_log = db.query(DailyLog).filter(
                    DailyLog.user_id == user.id,
                    DailyLog.date == date.today()
                ).first()
                
                if today_log:
                    context_parts.append(
                        f"\nToday's Status:\n"
                        f"- Sleep: {today_log.sleep_hours} hrs\n"
                        f"- Mood: {today_log.mood}/10\n"
                        f"- Soreness: {today_log.soreness_level}/10"
                    )
            except:
                pass  # Skip if table doesn't exist
            
            return "\n".join(context_parts)
            
        except Exception as e:
            print(f"Error building context: {e}")
            # Return minimal context if anything fails
            return basic_context + "\nNote: Full training history unavailable"
