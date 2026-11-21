class BusinessIdeaSuggestionRequest {
  final String businessTypeId;
  final int minBudget;
  final int maxBudget;
  final String currency;
  final String targetAreaId;

  BusinessIdeaSuggestionRequest({
    required this.businessTypeId,
    required this.minBudget,
    required this.maxBudget,
    this.currency = "PKR",
    required this.targetAreaId,
  });

  Map<String, dynamic> toJson() {
    return {
      "business_type_id": businessTypeId,
      "min_budget": minBudget,
      "max_budget": maxBudget,
      "currency": currency,
      "target_area_id": targetAreaId,
    };
  }

  factory BusinessIdeaSuggestionRequest.fromJson(Map<String, dynamic> json) {
    return BusinessIdeaSuggestionRequest(
      businessTypeId: json['business_type_id'] ?? '',
      minBudget: (json['min_budget'] ?? 0).toInt(),
      maxBudget: (json['max_budget'] ?? 0).toInt(),
      currency: json['currency'] ?? 'PKR',
      targetAreaId: json['target_area_id'] ?? '',
    );
  }
}
