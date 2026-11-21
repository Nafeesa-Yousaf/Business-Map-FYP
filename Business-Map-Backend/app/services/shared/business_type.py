from app.schemas.responses import BusinessType
from app.utils.load_json import load_json

def get_all_business_types() -> list[BusinessType]:
    data = load_json("business_type_data.json")
    return [BusinessType(**bt) for bt in data]

def get_business_type_by_id(business_type_id: str, sub_type_id: str = None) -> BusinessType:
    types = get_all_business_types()
    for bt in types:
        if bt.id == business_type_id:
            if sub_type_id:
                bt.sub_types = [st for st in bt.sub_types if st.id == sub_type_id]
            return bt
    return None
