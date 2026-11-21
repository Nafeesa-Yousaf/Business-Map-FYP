class LocationSuggestionRequest {
  final String businessTypeId;
  final String subTypeId;
  final String businessDescription;
  final int? minBudget;
  final int? maxBudget;
  final String currency;
  final String targetAreaId;
  final bool isPrioritizeBudget;

  LocationSuggestionRequest({
    required this.businessTypeId,
    required this.subTypeId,
    required this.businessDescription,
    this.minBudget,
    this.maxBudget,
    this.currency = "PKR",
    required this.targetAreaId,
    this.isPrioritizeBudget = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "business_type_id": businessTypeId,
      "sub_type_id": subTypeId,
      "business_description": businessDescription,
      "min_budget": minBudget,
      "max_budget": maxBudget,
      "currency": currency,
      "target_area_id": targetAreaId,
      "is_prioritize_budget": isPrioritizeBudget,
    };
  }
}
