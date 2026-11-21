import 'package:business_map/utils/media_url.dart';

class BusinessIdeaSuggestionResponse {
  final String status;
  final String message;
  final IdeaRequestSummary? requestSummary;
  final List<BusinessIdea> businessIdeas;

  BusinessIdeaSuggestionResponse({
    required this.status,
    required this.message,
    this.requestSummary,
    required this.businessIdeas,
  });

  factory BusinessIdeaSuggestionResponse.fromJson(Map<String, dynamic> json) {
    return BusinessIdeaSuggestionResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      requestSummary: json['request_summary'] != null
          ? IdeaRequestSummary.fromJson(json['request_summary'])
          : null,
      businessIdeas: (json['business_ideas'] as List?)
              ?.map((e) => BusinessIdea.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'request_summary': requestSummary?.toJson(),
      'business_ideas': businessIdeas.map((e) => e.toJson()).toList(),
    };
  }
}

class IdeaRequestSummary {
  final String businessType;
  final String targetArea;
  final String budgetRange;

  IdeaRequestSummary({
    required this.businessType,
    required this.targetArea,
    required this.budgetRange,
  });

  factory IdeaRequestSummary.fromJson(Map<String, dynamic> json) {
    return IdeaRequestSummary(
      businessType: json['business_type']?.toString() ?? '',
      targetArea: json['target_area']?.toString() ?? '',
      budgetRange: json['budget_range']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_type': businessType,
      'target_area': targetArea,
      'budget_range': budgetRange,
    };
  }
}

class BusinessIdea {
  final String? _id;
  final String? _businessName;
  final String? _description;
  final List<String> images;
  final List<String> fitTags;
  final List<String> challenges;
  final List<String> practicalTips;
  final String? usp;
  final List<String> coreServices;
  final List<String> targetAudience;
  final String? whyItFits;
  
  // Context fields for Saved Gallery
  final String? categoryContext;
  final String? areaContext;
  final DateTime? createdAt;

  // Safe Getters
  String get id => _id ?? '';
  String get businessName => _businessName ?? 'New Business Idea';
  String get description => _description ?? '';

  BusinessIdea({
    String? id,
    String? businessName,
    String? description,
    required this.images,
    required this.fitTags,
    required this.challenges,
    required this.practicalTips,
    this.usp,
    required this.coreServices,
    required this.targetAudience,
    this.whyItFits,
    this.categoryContext,
    this.areaContext,
    this.createdAt,
  })  : _id = id,
        _businessName = businessName,
        _description = description;

  factory BusinessIdea.fromJson(Map<String, dynamic> json) {
    return BusinessIdea(
      id: json['id']?.toString() ?? json['business_name']?.toString().replaceAll(' ', '_'),
      businessName: json['business_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images: MediaUrl.resolveAll(
        (json['images'] as List?)?.map((e) => e.toString()),
      ),
      fitTags: List<String>.from(json['fit_tags'] ?? []),
      challenges: List<String>.from(json['challenges'] ?? []),
      practicalTips: List<String>.from(json['practical_tips'] ?? []),
      usp: json['usp']?.toString(),
      coreServices: List<String>.from(json['core_services'] ?? []),
      targetAudience: List<String>.from(json['target_audience'] ?? []),
      whyItFits: json['why_it_fits']?.toString(),
      categoryContext: json['category_context']?.toString(),
      areaContext: json['area_context']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'description': description,
      'images': images,
      'fit_tags': fitTags,
      'challenges': challenges,
      'practical_tips': practicalTips,
      'usp': usp,
      'core_services': coreServices,
      'target_audience': targetAudience,
      'why_it_fits': whyItFits,
      'category_context': categoryContext,
      'area_context': areaContext,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
