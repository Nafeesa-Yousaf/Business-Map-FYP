from app.schemas.responses import BudgetConfig
from app.utils.load_json import load_json

def get_budget_config() -> BudgetConfig:
    data = load_json("budget_data.json")
    return BudgetConfig(**data)