import os
import google.generativeai as genai
from typing import Optional

class LLMService:
    """
    Interfaces with Google Gemini API.
    Refalls to a 'Simulated Intelligence' if no API key is present.
    """
    
    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY")
        if self.api_key:
            genai.configure(api_key=self.api_key)
            self.model = genai.GenerativeModel('gemini-pro')
        else:
            self.model = None

    def generate_response(self, system_prompt: str, user_message: str) -> str:
        if self.model:
            try:
                chat = self.model.start_chat(history=[
                    {"role": "user", "parts": [system_prompt]}
                ])
                response = chat.send_message(user_message)
                return response.text
            except Exception as e:
                print(f"LLM Error: {e}")
                return self._simulate_intelligence(user_message)
        else:
            return self._simulate_intelligence(user_message)

    def _simulate_intelligence(self, message: str) -> str:
        """
        Sophisticated rule-based responses for demo purposes when offline.
        """
        msg = message.lower()
        
        if "tired" in msg or "exhausted" in msg:
            return "I see that you're feeling fatigued. Your CNS fatigue metrics are elevated. I strongly recommend switching to an Active Recovery session today—focus on mobility and light flow to aid recovery without adding stress."
        elif "hungry" in msg or "eat" in msg:
            return "Nutrition is key. Based on your training load today, aim for complex carbs and lean protein. A chicken and quinoa salad with avocado would be perfect for recovery."
        elif "skip" in msg or "miss" in msg:
            return "It's okay to miss a session if your body needs it. Consistency over intensity. If you can, try to do just 15 minutes of movement to keep the streak alive, but don't stress about a full workout."
        elif "pain" in msg or "hurt" in msg:
            return "Please prioritize safety. If you are experiencing sharp pain, stop immediately. Do not push through injury. I recommend consulting a physiotherapist."
        else:
            return "I'm analyzing your data. You seem to be on track. Remember, hybrid training requires careful fatigue management. How is your sleep quality lately?"
