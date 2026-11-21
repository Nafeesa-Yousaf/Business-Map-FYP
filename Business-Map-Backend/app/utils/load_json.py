import json
from functools import lru_cache
from pathlib import Path


@lru_cache(maxsize=16)
def load_json(file_name: str):
    file_path = Path(__file__).parent.parent / "data" / file_name
    with open(file_path, "r", encoding="utf-8") as f:
        return json.load(f)
