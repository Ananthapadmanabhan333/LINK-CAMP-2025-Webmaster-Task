from sqlalchemy.orm import Session
from app.models.user import User
from .context_manager import ContextManager
from .llm_service import LLMService
# from .finetuning_service import FineTuningService
import time

class CoachOrchestrator:
    """
    Coordinates the AI Coach interaction.
    1. Builds Context
    2. Constructs Prompt
    3. Calls LLM
    """
    
    def __init__(self):
        self.llm = LLMService()
        self.finetuning = None  # Temporarily disabled
        # try:
        #     self.finetuning = FineTuningService()
        # except Exception as e:
        #     print(f"Fine-tuning service not available: {e}")
        #     self.finetuning = None

    def process_message(self, user: User, message: str, db: Session) -> str:
        # 1. Gather Context
        context_str = ContextManager.build_context(user, db)
        
        # 2. System Prompt
        system_prompt = f"""
        You are 'Hybrid Coach', an elite AI performance coach for a hybrid athlete application.
        Your goal is to provide specific, actionable, and empathetic advice based on the user's data.
        
        CONTEXT DATA:
        {context_str}
        
        GUIDELINES:
        - Be concise but professional.
        - If fatigue is high (>80%), RECOMMEND REST or Active Recovery.
        - Support goals of Strength, Boxing, and Endurance.
        - Answer directly. Do not say "As an AI...".
        """
        
        # 3. specific Logic Triggers (Hybrid Logic)
        # If specific keywords are found, we might force certain data into the prompt
        # (For MVP, the ContextManager handles most of this)
        
        # 4. Generate Response
        start_time = time.time()
        response = self.llm.generate_response(system_prompt, message)
        response_time_ms = (time.time() - start_time) * 1000
        
        # 5. Log conversation for fine-tuning (if available)
        if self.finetuning:
            try:
                user_context_dict = {
                    "fatigue_state": context_str,
                    "user_profile": f"Weight: {user.current_weight_kg}kg, Activity: {user.activity_level}"
                }
                self.finetuning.log_conversation(
                    db=db,
                    user_id=user.id,
                    user_message=message,
                    ai_response=response,
                    system_prompt=system_prompt,
                    user_context=user_context_dict,
                    response_time_ms=response_time_ms
                )
            except Exception as e:
                print(f"Failed to log conversation: {e}")
        
        return response
