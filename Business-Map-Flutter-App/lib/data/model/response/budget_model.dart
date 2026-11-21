class BudgetModel {
  final int minLimit;
  final int maxLimit;
  final int interval;
  final String currency;

  BudgetModel({
    required this.minLimit,
    required this.maxLimit,
    required this.interval,
    required this.currency,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      minLimit: json['min_limit'] as int? ?? 0,
      maxLimit: json['max_limit'] as int? ?? 0,
      interval: json['interval'] as int? ?? 0,
      currency: json['currency']?.toString() ?? 'PKR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_limit': minLimit,
      'max_limit': maxLimit,
      'interval': interval,
      'currency': currency,
    };
  }
}
