import json
from google import genai
from google.genai import types
from app.core.config import settings
from app.core import business_consts
from app.core.logger import get_logger

logger = get_logger(__name__)

class BaseAIService:
    """
    Core AI service for Google Gemini integration.
    """
    
    def __init__(self):
        self.api_key = settings.GEMINI_API_KEY
        self.client = None
        self.model_candidates = business_consts.GEMINI_MODEL_CANDIDATES
        
        if self.api_key and "YOUR_GEMINI_KEY" not in self.api_key:
            try:
                self.client = genai.Client(api_key=self.api_key)
            except Exception as e:
                logger.error(f"Gemini Init Error: {e}")

    def _generate_with_strict_schema(self, contents, response_schema):
        """Internal helper with 'Response Schema' enforcement."""
        if not self.client:
            raise Exception("AI Service not available. Check GEMINI_API_KEY.")

        last_error = ""
        for model_id in self.model_candidates:
            # Candidates may already be "models/..." — avoid "models/models/..."
            current_id = model_id if model_id.startswith("models/") else f"models/{model_id}"
            try:
                logger.info(f"AI Analysis (Strict Schema) with: {current_id}...")
                response = self.client.models.generate_content(
                    model=current_id,
                    contents=contents,
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=response_schema
                    )
                )
                return response
            except Exception as e:
                err_msg = str(e)
                last_error = err_msg
                if "404" in err_msg or "not found" in err_msg.lower():
                    continue
                raise e

        raise Exception(f"All AI model candidates failed. Last error: {last_error}")

    def validate_business_intent(self, business_type_name: str, business_description: str) -> tuple[bool, str]:
        """
        Validates if the business description matches the selected category.
        """
        prompt = f"Analyze if the description '{business_description}' matches category '{business_type_name}'. Return JSON: {{\"isValid\": bool, \"message\": str}}"
        
        schema = {
            "type": "object",
            "properties": {
                "isValid": {"type": "boolean"},
                "message": {"type": "string"}
            },
            "required": ["isValid", "message"]
        }
        
        try:
            response = self._generate_with_strict_schema([prompt], schema)
            data = json.loads(response.text)
            return data.get("isValid", True), data.get("message", "")
        except Exception as e:
            logger.warning(f"Intent validation failed: {str(e)}")
            return True, ""
