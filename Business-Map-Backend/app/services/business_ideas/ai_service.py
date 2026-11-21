import json
from typing import List, Dict, Optional
from app.services.shared.base_ai import BaseAIService
from app.schemas.domain import BusinessIdea
from app.schemas.base import BudgetRange
from app.core.prompts import SYSTEM_IDEA_GENERATOR

class BusinessIdeaService(BaseAIService):
    """
    AI service specialized in gap analysis and business idea generation.
    """

    def analyze_location_and_suggest_businesses(
        self,
        search_query: str,
        target_area_name: str,
        budget_range: BudgetRange,
        existing_businesses_data: List[Dict],
        business_description: Optional[str] = None,
        city_name: str = "Islamabad"
    ) -> List[Dict]:
        """Module 4: Idea Generation."""
        budget_min = budget_range.min
        budget_max = budget_range.max
        currency = budget_range.currency

        user_vision_instruction = f"USER VISION: {business_description}" if business_description else ""

        system_prompt = SYSTEM_IDEA_GENERATOR.format(
            city_name=city_name,
            search_query=search_query,
            target_area_name=target_area_name,
            budget_min=budget_min,
            budget_max=budget_max,
            currency=currency,
            user_vision_instruction=user_vision_instruction,
            existing_landscape=json.dumps(existing_businesses_data[:15])
        )

        schema = {
            "type": "object",
            "properties": {
                "business_ideas": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "id": {"type": "string"},
                            "business_name": {"type": "string"},
                            "description": {"type": "string"},
                            "usp": {"type": "string"},
                            "core_services": {"type": "array", "items": {"type": "string"}},
                            "target_audience": {"type": "array", "items": {"type": "string"}},
                            "why_it_fits": {"type": "string"},
                            "images": {"type": "array", "items": {"type": "string"}},
                            "fit_tags": {"type": "array", "items": {"type": "string"}},
                            "challenges": {"type": "array", "items": {"type": "string"}},
                            "practical_tips": {"type": "array", "items": {"type": "string"}}
                        },
                        "required": ["id", "business_name", "description", "usp", "core_services", "target_audience", "why_it_fits", "images", "fit_tags", "challenges", "practical_tips"]
                    }
                }
            },
            "required": ["business_ideas"]
        }

        try:
            response = self._generate_with_strict_schema([system_prompt], schema)
            content = json.loads(response.text)
            ideas_raw = content.get('business_ideas', [])
            return [BusinessIdea(**idea).model_dump() for idea in ideas_raw[:3]]
        except Exception as e:
            raise Exception(f"Business Suggestion Analysis Failed: {str(e)}")
