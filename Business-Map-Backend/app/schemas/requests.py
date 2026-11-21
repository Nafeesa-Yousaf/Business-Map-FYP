from typing import Optional

from pydantic import BaseModel, Field, field_validator, model_validator

_ALLOWED_CURRENCIES = frozenset({"PKR", "USD", "EUR", "GBP", "AED", "SAR", "INR"})


class BusinessLocationRequest(BaseModel):
    business_type_id: str = Field(..., min_length=1, max_length=64)
    sub_type_id: str = Field(..., min_length=1, max_length=64)
    business_description: str = Field(..., min_length=1, max_length=500)
    min_budget: Optional[int] = Field(None, ge=0, le=1_000_000_000)
    max_budget: Optional[int] = Field(None, ge=0, le=1_000_000_000)
    currency: Optional[str] = Field(default="PKR", max_length=8)
    target_area_id: str = Field(..., min_length=1, max_length=64)
    is_prioritize_budget: bool = False

    @field_validator("currency")
    @classmethod
    def normalize_currency(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return value
        code = value.strip().upper()
        if code not in _ALLOWED_CURRENCIES:
            raise ValueError(f"currency must be one of: {', '.join(sorted(_ALLOWED_CURRENCIES))}")
        return code

    @model_validator(mode="after")
    def budgets_ordered(self) -> "BusinessLocationRequest":
        if self.min_budget is not None and self.max_budget is not None:
            if self.min_budget > self.max_budget:
                raise ValueError("min_budget must be less than or equal to max_budget")
        return self


class BusinessIdeaRequest(BaseModel):
    business_type_id: str = Field(..., min_length=1, max_length=64)
    min_budget: int = Field(..., ge=0, le=1_000_000_000)
    max_budget: int = Field(..., ge=0, le=1_000_000_000)
    currency: str = Field(default="PKR", max_length=8)
    target_area_id: str = Field(..., min_length=1, max_length=64)

    @field_validator("currency")
    @classmethod
    def normalize_currency(cls, value: str) -> str:
        code = value.strip().upper()
        if code not in _ALLOWED_CURRENCIES:
            raise ValueError(f"currency must be one of: {', '.join(sorted(_ALLOWED_CURRENCIES))}")
        return code

    @model_validator(mode="after")
    def budgets_ordered(self) -> "BusinessIdeaRequest":
        if self.min_budget > self.max_budget:
            raise ValueError("min_budget must be less than or equal to max_budget")
        return self
