import json
from typing import List, Dict
from google.genai import types
from app.services.shared.base_ai import BaseAIService
from app.schemas.domain import RecommendedLocation, StrategicZone, LocationStrategy
from app.schemas.base import BudgetRange
from app.core.prompts import SYSTEM_MACRO_ANALYST, SYSTEM_SITE_SELECTOR

class LocationAIService(BaseAIService):
    """
    AI service specialized in site selection and location strategy.
    """

    def identify_strategic_zones(
        self, 
        business_type_name: str,
        business_description: str,
        target_area_name: str, 
        candidate_data: List[Dict],
        map_image: bytes = b""
    ) -> tuple[bool, str, List[StrategicZone]]:
        """Phase 1: Macro-Analysis."""
        schema = {
            "type": "object",
            "properties": {
                "isValid": {"type": "boolean"},
                "message": {"type": "string"},
                "strategic_zones": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "coordinate": {
                                "type": "object",
                                "properties": {"lat": {"type": "number"}, "lng": {"type": "number"}},
                                "required": ["lat", "lng"]
                            },
                            "strategy": {"type": "string", "enum": [s.value for s in LocationStrategy]},
                            "reasoning": {"type": "string"}
                        },
                        "required": ["coordinate", "strategy", "reasoning"]
                    }
                }
            },
            "required": ["isValid", "message", "strategic_zones"]
        }
        
        system_prompt = SYSTEM_MACRO_ANALYST.format(
            business_type_name=business_type_name,
            target_area_name=target_area_name
        )
        contents = []
        if map_image:
            contents.append(types.Part.from_bytes(data=map_image, mime_type="image/png"))
        contents.append(system_prompt)
        contents.append(f"USER BUSINESS DESCRIPTION:\n{business_description}")
        contents.append(f"CANDIDATE DATA:\n{json.dumps(candidate_data)}")
        
        try:
            response = self._generate_with_strict_schema(contents, schema)
            res_json = json.loads(response.text)
            if not res_json.get('isValid', True):
                return False, res_json.get('message', ""), []
                
            zones = res_json.get('strategic_zones', [])
            return True, "", [StrategicZone(**z) for z in zones[:3]]
        except Exception as e:
            raise Exception(f"Phase 1 AI Strategic Analysis Failed: {str(e)}")

    def perform_final_site_selection(
        self,
        business_type: str,
        business_description: str,
        target_area_name: str,
        budget_range: BudgetRange,
        specific_anchors: List[Dict],
        existing_competitors: List[Dict] = None,
        map_image: bytes = b"",
        is_prioritize_budget: bool = False,
        city_name: str = "Islamabad"
    ) -> tuple[List[RecommendedLocation], str]:
        """Phase 2: Micro-Selection."""
        budget_min = budget_range.min
        budget_max = budget_range.max
        currency = budget_range.currency

        priority_instruction = (
            f"STRICT BUDGET ENFORCEMENT IS ON: You MUST ONLY return locations that fit WITHIN {budget_max} {currency}."
            if is_prioritize_budget else
            f"QUALITY OVER BUDGET: Pick the 3 absolute BEST locations, even if they exceed {budget_max} {currency}."
        )

        budget_info_instruction = (
            "\n\nIMPORTANT: Set 'status' to null in budget_analysis. Still provide full cost_breakdown, total_estimated_budget, and optimization_tips as normal."
            if not is_prioritize_budget else ""
        )

        system_prompt = SYSTEM_SITE_SELECTOR.format(
            budget_min=budget_min,
            budget_max=budget_max,
            currency=currency,
            priority_instruction=priority_instruction,
            budget_info_instruction=budget_info_instruction,
            target_area_name=target_area_name,
            city_name=city_name,
            business_type=business_type
        )
        
        schema = {
            "type": "object",
            "properties": {
                "failure_reason": {"type": "string"},
                "recommended_locations": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "id": {"type": "string"},
                            "location_name": {"type": "string"},
                            "location": {"type": "string"},
                            "location_description": {"type": "string"},
                            "match_percentage": {"type": "integer"},
                            "coordinates": {
                                "type": "object",
                                "properties": {"lat": {"type": "number"}, "lng": {"type": "number"}},
                                "required": ["lat", "lng"]
                            },
                            "suitability": {
                                "type": "object",
                                "properties": {
                                    "tags": {"type": "array", "items": {"type": "string"}},
                                    "summary": {"type": "string"}
                                },
                                "required": ["tags", "summary"]
                            },
                            "budget_analysis": {
                                "type": "object",
                                "properties": {
                                    "status": {"type": "string", "nullable": True, "enum": ["within_budget", "exceeds_budget"]},
                                    "total_estimated_budget": {"type": "number"},
                                    "cost_breakdown": {
                                        "type": "array",
                                        "items": {
                                            "type": "object",
                                            "properties": {
                                                "category_name": {"type": "string"},
                                                "estimated_cost": {"type": "number"},
                                                "proportion_percentage": {"type": "number"}
                                            },
                                            "required": ["category_name", "estimated_cost", "proportion_percentage"]
                                        }
                                    },
                                    "optimization_tips": {"type": "array", "items": {"type": "string"}}
                                },
                                "required": ["total_estimated_budget", "cost_breakdown", "optimization_tips"]
                            },
                            "competitor_analysis": {
                                "type": "object",
                                "properties": {
                                    "total_competitors_count": {"type": "integer"},
                                    "competition_level": {"type": "string", "enum": ["low", "medium", "high"]},
                                    "top_competitors": {
                                        "type": "array",
                                        "items": {
                                            "type": "object",
                                            "properties": {
                                                "id": {"type": "string"},
                                                "name": {"type": "string"},
                                                "location": {"type": "string"},
                                                "rating": {"type": "number"},
                                                "distance_meters": {"type": "integer"}
                                            },
                                            "required": ["name", "location", "rating", "distance_meters"]
                                        }
                                    },
                                    "insights": {
                                        "type": "object",
                                        "properties": {
                                            "opportunities": {"type": "array", "items": {"type": "string"}},
                                            "threats": {"type": "array", "items": {"type": "string"}},
                                            "strengths": {"type": "array", "items": {"type": "string"}},
                                            "weaknesses": {"type": "array", "items": {"type": "string"}}
                                        },
                                        "required": ["opportunities", "threats", "strengths", "weaknesses"]
                                    }
                                },
                                "required": ["total_competitors_count", "competition_level", "top_competitors", "insights"]
                            }
                        },
                        "required": [
                            "id", "location_name", "location", "location_description", 
                            "match_percentage", "coordinates", "suitability", 
                            "budget_analysis", "competitor_analysis"
                        ]
                    }
                }
            },
            "required": ["recommended_locations"]
        }
        
        contents = []
        if map_image:
            contents.append(types.Part.from_bytes(data=map_image, mime_type="image/png"))
        contents.append(system_prompt)
        contents.append(f"COMMERCIAL ANCHOR SPOTS (Pick your recommendations from THESE):\n{json.dumps(specific_anchors)}")
        if existing_competitors:
            contents.append(f"EXISTING COMPETITORS (These spots are ALREADY OCCUPIED. Use them for SWOT analysis ONLY — DO NOT recommend them as locations):\n{json.dumps(existing_competitors)}")
        
        try:
            response = self._generate_with_strict_schema(contents, schema)
            res_json = json.loads(response.text)
            locations_data = res_json.get('recommended_locations', [])
            failure_reason = res_json.get('failure_reason', "")
            return [RecommendedLocation(**l) for l in locations_data[:3]], failure_reason
        except Exception as e:
            raise Exception(f"Phase 2 AI Selection Failed: {str(e)}")
