# NLP Project: AI Fitness Coach with Fine-Tuning

## 🎯 Project Overview

**Fuelix AI Coach** is an intelligent fitness coaching system that uses Natural Language Processing to provide personalized training advice. This project demonstrates a complete NLP application with **continuous learning through fine-tuning**.

### Key Features
- 🤖 **Conversational AI Coach** using Google Gemini LLM
- 📊 **Context-Aware Responses** based on user fatigue, sleep, and training data
- 🔄 **Feedback Loop** for model improvement
- 📈 **Training Data Collection** from real user interactions
- 🎓 **Fine-Tuning Pipeline** for model personalization

---

## 🏗️ System Architecture

```
┌─────────────┐
│   User      │
└──────┬──────┘
       │ Chat Message
       ▼
┌─────────────────────────────────┐
│   AI Coach API Endpoint         │
│   /api/v1/coach/chat            │
└──────┬──────────────────────────┘
       │
       ▼
┌─────────────────────────────────┐
│   Coach Orchestrator            │
│   - Gathers user context        │
│   - Builds system prompt        │
│   - Calls LLM                   │
│   - Logs conversation ✨        │
└──────┬──────────────────────────┘
       │
       ├──────────────┬─────────────────┐
       ▼              ▼                 ▼
┌──────────┐   ┌──────────┐    ┌──────────────┐
│   LLM    │   │ Context  │    │  Fine-Tuning │
│ Service  │   │ Manager  │    │   Service    │
└──────────┘   └──────────┘    └──────┬───────┘
                                       │
                                       ▼
                              ┌─────────────────┐
                              │   Database      │
                              │ (Conversations) │
                              └─────────────────┘
```

---

## 📚 NLP Components

### 1. **Context Manager**
Aggregates user data into a rich context for the LLM:
- **Fatigue State**: CNS, muscular (upper/lower), cardio fatigue levels
- **Recent Activity**: Last workout, daily logs
- **User Profile**: Weight, activity level, goals
- **Injuries**: Current limitations

**File**: `backend/app/ai_engine/context_manager.py`

### 2. **LLM Service**
Interfaces with Google Gemini API:
- Model: `gemini-pro`
- Supports system prompts for role definition
- Fallback to rule-based responses when offline

**File**: `backend/app/ai_engine/llm_service.py`

### 3. **Fine-Tuning Service** ✨
Manages training data collection and export:
- **Automatic Logging**: Every conversation saved with context
- **Quality Filtering**: Only 4+ star ratings used for training
- **Dataset Export**: JSONL format for Gemini fine-tuning
- **Versioning**: Track which data was used for each model

**File**: `backend/app/ai_engine/finetuning_service.py`

---

## 🔄 Fine-Tuning Workflow

### Phase 1: Data Collection

```
User Chat → AI Response → Automatic Logging
                              ↓
                    ┌─────────────────────┐
                    │ TrainingConversation│
                    │   - user_message    │
                    │   - ai_response     │
                    │   - user_context    │
                    │   - rating (null)   │
                    └─────────────────────┘
```

### Phase 2: Quality Assessment

```
User Rates Response (1-5 ⭐)
         ↓
┌─────────────────────┐
│ TrainingConversation│
│   rating: 5         │
│   was_helpful: true │
└─────────────────────┘
```

### Phase 3: Dataset Export

```
Filter: rating >= 4 AND was_helpful = true
         ↓
Export to JSONL format:
{
  "text_input": "System: You are an AI fitness coach...\n\nUser Context:\n- CNS Fatigue: 45%\n- Sleep: 7.5 hours\n\nUser: I'm feeling tired today",
  "output": "I see that you're feeling fatigued. Based on your CNS fatigue at 45%, I recommend..."
}
```

### Phase 4: Model Fine-Tuning

**Option A: Gemini API Fine-Tuning**
```bash
# Upload dataset
curl -X POST https://generativelanguage.googleapis.com/v1beta/tunedModels \
  -H "Authorization: Bearer $GEMINI_API_KEY" \
  -d @training_data.jsonl

# Monitor training
# Deploy fine-tuned model
```

**Option B: Custom Model (Hugging Face)**
```python
from transformers import AutoModelForCausalLM, Trainer

# Load base model (e.g., GPT-2, LLaMA)
model = AutoModelForCausalLM.from_pretrained("gpt2")

# Fine-tune on exported dataset
trainer = Trainer(model=model, train_dataset=dataset)
trainer.train()
```

---

## 📊 Database Schema

### TrainingConversation Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | Integer | Primary key |
| `user_id` | Integer | User who had conversation |
| `user_message` | Text | User's input |
| `ai_response` | Text | AI's response |
| `system_prompt` | Text | System instructions used |
| `user_context` | JSON | Fatigue, sleep, mood data |
| `user_rating` | Integer | 1-5 star rating (nullable) |
| `was_helpful` | Boolean | User feedback (nullable) |
| `feedback_text` | Text | Optional user comments |
| `model_version` | String | Which model generated response |
| `response_time_ms` | Float | Response latency |
| `created_at` | DateTime | When conversation occurred |
| `included_in_training` | Boolean | Used in dataset? |
| `training_dataset_version` | String | Which dataset version |

---

## 🚀 API Endpoints

### Chat with AI Coach
```http
POST /api/v1/coach/chat?message=I'm feeling tired today
```
**Response:**
```json
{
  "recommendation": "I see that you're feeling fatigued...",
  "warning": null,
  "adjusted_plan": null
}
```
*Automatically logs conversation to database*

### Rate Conversation
```http
POST /api/v1/finetuning/rate-conversation
Content-Type: application/json

{
  "conversation_id": 123,
  "rating": 5,
  "was_helpful": true,
  "feedback_text": "Very helpful advice!"
}
```

### Export Training Dataset
```http
POST /api/v1/finetuning/export-dataset
Content-Type: application/json

{
  "min_rating": 4,
  "format": "jsonl",
  "dataset_version": "v1.0"
}
```
**Response:**
```json
{
  "status": "success",
  "filename": "training_data/training_data_v1.0.jsonl",
  "message": "Training dataset exported successfully"
}
```

### Get Dataset Statistics
```http
GET /api/v1/finetuning/dataset-stats
```
**Response:**
```json
{
  "total_conversations": 150,
  "rated_conversations": 45,
  "high_quality_conversations": 32,
  "included_in_training": 0,
  "available_for_training": 32
}
```

---

## 🎬 Demo Instructions

### 1. Start the Application
```bash
# Backend
cd backend
.venv\Scripts\activate
uvicorn app.main:app --reload

# Frontend
cd frontend
flutter run -d chrome
```

### 2. Generate Training Data
1. Open AI Coach in browser
2. Have 5-10 conversations:
   - "I'm feeling tired today"
   - "What should I eat before training?"
   - "My shoulder hurts, what exercises should I avoid?"
   - "How do I improve my cardio?"

### 3. Rate Conversations
Use API docs at `http://127.0.0.1:8000/api/v1/docs`:
- Navigate to `/finetuning/rate-conversation`
- Rate conversations 4-5 stars

### 4. View Statistics
- Call `/finetuning/dataset-stats`
- Show increasing numbers

### 5. Export Dataset
- Call `/finetuning/export-dataset`
- Show generated JSONL file
- Open file to display training examples

### 6. Explain Fine-Tuning
- Show how data would be used with Gemini API
- Explain feedback loop: Better data → Better model → Better responses

---

## 📈 Evaluation Metrics

### Data Quality Metrics
- **Collection Rate**: Conversations logged per day
- **Rating Rate**: % of conversations rated by users
- **Quality Rate**: % of conversations with 4+ stars
- **Context Richness**: Average fields populated in user_context

### Model Performance Metrics
- **Response Relevance**: Does AI address user's question?
- **Context Utilization**: Does AI use fatigue/sleep data appropriately?
- **User Satisfaction**: Average rating over time
- **Response Time**: Latency in milliseconds

### A/B Testing (Future)
- Compare base model vs fine-tuned model
- Measure improvement in user ratings
- Track engagement (messages per session)

---

## 🎓 NLP Concepts Demonstrated

1. **Prompt Engineering**: System prompts define AI behavior
2. **Context Injection**: User data enriches LLM understanding
3. **Transfer Learning**: Fine-tuning pre-trained models
4. **Human-in-the-Loop**: User ratings guide model improvement
5. **Data Versioning**: Track training datasets over time
6. **Quality Filtering**: Only use high-quality examples
7. **Domain Adaptation**: General LLM → Fitness-specific coach

---

## 🔮 Future Enhancements

- **Multi-turn Conversations**: Track conversation history
- **Reinforcement Learning**: RLHF (Reinforcement Learning from Human Feedback)
- **Automated Evaluation**: Use GPT-4 to rate responses
- **Personalized Models**: Fine-tune per user
- **Multilingual Support**: Expand to other languages
- **Voice Interface**: Speech-to-text integration

---

## 📝 Presentation Talking Points

1. **Problem**: Generic fitness advice doesn't work for hybrid athletes
2. **Solution**: AI coach that understands fatigue, recovery, and context
3. **Innovation**: Continuous improvement through user feedback
4. **Technical Depth**: 
   - NLP with context injection
   - Fine-tuning pipeline
   - Quality-filtered training data
5. **Real-World Application**: Production-ready system with database, API, frontend
6. **Scalability**: Automated data collection, versioned datasets

---

## 📚 References

- [Google Gemini API Documentation](https://ai.google.dev/docs)
- [Fine-Tuning Best Practices](https://platform.openai.com/docs/guides/fine-tuning)
- [Hugging Face Transformers](https://huggingface.co/docs/transformers)
- [RLHF Paper](https://arxiv.org/abs/2203.02155)
