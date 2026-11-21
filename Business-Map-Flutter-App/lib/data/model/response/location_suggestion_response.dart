import 'package:business_map/utils/media_url.dart';

class LocationSuggestionResponse {
  final String status;
  final String message;
  final RequestSummary? requestSummary;
  final List<TopLocation> topLocations;

  LocationSuggestionResponse({
    required this.status,
    required this.message,
    this.requestSummary,
    required this.topLocations,
  });

  factory LocationSuggestionResponse.fromJson(Map<String, dynamic> json) {
    final summary = json['request_summary'] != null
        ? RequestSummary.fromJson(json['request_summary'])
        : null;

    final String bType = summary?.businessType ?? "Unknown";
    final String tArea = summary?.targetArea ?? "Unknown";
    final String bRange = summary?.budgetRange ?? "Unknown";

    return LocationSuggestionResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      requestSummary: summary,
      topLocations: (json['top_locations'] as List?)
              ?.map((e) {
                var map = Map<String, dynamic>.from(e);
                map['business_type'] = bType;
                map['target_area'] = tArea;
                map['budget_range'] = bRange;
                return TopLocation.fromJson(map);
              })
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'request_summary': requestSummary?.toJson(),
      'top_locations': topLocations.map((e) => e.toJson()).toList(),
    };
  }
}

class RequestSummary {
  final String businessType;
  final String targetArea;
  final String budgetRange;

  RequestSummary({
    required this.businessType,
    required this.targetArea,
    required this.budgetRange,
  });

  factory RequestSummary.fromJson(Map<String, dynamic> json) {
    return RequestSummary(
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

class TopLocation {
  final String? _id;
  final String? _locationName;
  final String? _location;
  final String? _businessType;
  final String? _targetArea;
  final String? _budgetRange;
  final Coordinates coordinates;
  final List<String> locationImages;
  final String? _locationDescription;
  final Suitability suitability;
  final BudgetAnalysis budgetAnalysis;
  final CompetitorAnalysis competitorAnalysis;
  final int? matchPercentage;
  final ArConfig arConfig;
  final DateTime? createdAt;

  // Getters that guarantee a non-null String result
  String get id => _id ?? '';
  String get locationName => _locationName ?? 'Unnamed Location';
  String get location => _location ?? '';
  String get businessType => _businessType ?? 'Business';
  String get targetArea => _targetArea ?? 'Not Specified';
  String get budgetRange => _budgetRange ?? 'N/A';
  String get locationDescription => _locationDescription ?? 'No details provided.';

  TopLocation({
    String? id,
    String? locationName,
    String? location,
    String? businessType,
    String? targetArea,
    String? budgetRange,
    required this.coordinates,
    required this.locationImages,
    String? locationDescription,
    required this.suitability,
    required this.budgetAnalysis,
    required this.competitorAnalysis,
    this.matchPercentage,
    required this.arConfig,
    this.createdAt,
  })  : _id = id,
        _locationName = locationName,
        _location = location,
        _businessType = businessType,
        _targetArea = targetArea,
        _budgetRange = budgetRange,
        _locationDescription = locationDescription;

  factory TopLocation.fromJson(Map<String, dynamic> json) {
    return TopLocation(
      id: json['id']?.toString() ?? '',
      locationName: json['location_name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      businessType: json['business_type']?.toString() ?? '',
      targetArea: json['target_area']?.toString() ?? '',
      budgetRange: json['budget_range']?.toString() ?? '',
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
      locationImages: MediaUrl.resolveAll(
        (json['location_images'] as List?)?.map((e) => e.toString()),
      ),
      locationDescription: json['location_description']?.toString() ?? '',
      suitability: Suitability.fromJson(json['suitability'] ?? {}),
      budgetAnalysis: BudgetAnalysis.fromJson(json['budget_analysis'] ?? {}),
      competitorAnalysis:
          CompetitorAnalysis.fromJson(json['competitor_analysis'] ?? {}),
      matchPercentage: json['match_percentage'] is int ? json['match_percentage'] : (json['match_percentage'] is String ? int.tryParse(json['match_percentage']) : null),
      arConfig: ArConfig.fromJson(json['ar_config'] ?? {}),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_name': locationName,
      'location': location,
      'business_type': businessType,
      'target_area': targetArea,
      'budget_range': budgetRange,
      'coordinates': coordinates.toJson(),
      'location_images': locationImages,
      'location_description': locationDescription,
      'suitability': suitability.toJson(),
      'budget_analysis': budgetAnalysis.toJson(),
      'competitor_analysis': competitorAnalysis.toJson(),
      'match_percentage': matchPercentage,
      'ar_config': arConfig.toJson(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class Coordinates {
  final double lat;
  final double lng;

  Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    double lat = (json['lat'] ?? 0.0).toDouble();
    double lng = (json['lng'] ?? 0.0).toDouble();

    if (lat == 0.0 && lng == 0.0) {
      lat = 33.6844;
      lng = 73.0479;
    }

    return Coordinates(lat: lat, lng: lng);
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}

class Suitability {
  final List<String> tags;
  final String summary;

  Suitability({required this.tags, required this.summary});

  factory Suitability.fromJson(Map<String, dynamic> json) {
    return Suitability(
      tags: List<String>.from(json['tags'] ?? []),
      summary: json['summary']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tags': tags,
      'summary': summary,
    };
  }
}

class BudgetAnalysis {
  final String? status;
  final num totalEstimatedBudget;
  final List<CostBreakdown> costBreakdown;
  final List<String> optimizationTips;

  BudgetAnalysis({
    this.status,
    required this.totalEstimatedBudget,
    required this.costBreakdown,
    required this.optimizationTips,
  });

  factory BudgetAnalysis.fromJson(Map<String, dynamic> json) {
    return BudgetAnalysis(
      status: json['status']?.toString(),
      totalEstimatedBudget: json['total_estimated_budget'] ?? 0,
      costBreakdown: (json['cost_breakdown'] as List?)
              ?.map((e) => CostBreakdown.fromJson(e))
              .toList() ??
          [],
      optimizationTips: List<String>.from(json['optimization_tips'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'total_estimated_budget': totalEstimatedBudget,
      'cost_breakdown': costBreakdown.map((e) => e.toJson()).toList(),
      'optimization_tips': optimizationTips,
    };
  }
}

class CostBreakdown {
  final String categoryName;
  final num estimatedCost;
  final num proportionPercentage;

  CostBreakdown({
    required this.categoryName,
    required this.estimatedCost,
    required this.proportionPercentage,
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    return CostBreakdown(
      categoryName: json['category_name']?.toString() ?? '',
      estimatedCost: json['estimated_cost'] ?? 0,
      proportionPercentage: json['proportion_percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'estimated_cost': estimatedCost,
      'proportion_percentage': proportionPercentage,
    };
  }
}

class CompetitorAnalysis {
  final int totalCompetitorsCount;
  final String competitionLevel;
  final List<TopCompetitor> topCompetitors;
  final Insights insights;

  CompetitorAnalysis({
    required this.totalCompetitorsCount,
    required this.competitionLevel,
    required this.topCompetitors,
    required this.insights,
  });

  factory CompetitorAnalysis.fromJson(Map<String, dynamic> json) {
    return CompetitorAnalysis(
      totalCompetitorsCount: json['total_competitors_count'] ?? 0,
      competitionLevel: json['competition_level']?.toString() ?? '',
      topCompetitors: (json['top_competitors'] as List?)
              ?.map((e) => TopCompetitor.fromJson(e))
              .toList() ??
          [],
      insights: Insights.fromJson(json['insights'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_competitors_count': totalCompetitorsCount,
      'competition_level': competitionLevel,
      'top_competitors': topCompetitors.map((e) => e.toJson()).toList(),
      'insights': insights.toJson(),
    };
  }
}

class TopCompetitor {
  final String id;
  final String name;
  final String location;
  final Coordinates coordinates;
  final num rating;
  final num distanceMeters;
  final String imageUrl;

  TopCompetitor({
    required this.id,
    required this.name,
    required this.location,
    required this.coordinates,
    required this.rating,
    required this.distanceMeters,
    required this.imageUrl,
  });

  factory TopCompetitor.fromJson(Map<String, dynamic> json) {
    return TopCompetitor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
      rating: json['rating'] ?? 0,
      distanceMeters: json['distance_meters'] ?? 0,
      imageUrl: MediaUrl.resolve(json['image_url']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'coordinates': coordinates.toJson(),
      'rating': rating,
      'distance_meters': distanceMeters,
      'image_url': imageUrl,
    };
  }
}

class Insights {
  final List<String> opportunities;
  final List<String> threats;
  final List<String> strengths;
  final List<String> weaknesses;

  Insights({
    required this.opportunities,
    required this.threats,
    required this.strengths,
    required this.weaknesses,
  });

  factory Insights.fromJson(Map<String, dynamic> json) {
    return Insights(
      opportunities: List<String>.from(json['opportunities'] ?? []),
      threats: List<String>.from(json['threats'] ?? []),
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opportunities': opportunities,
      'threats': threats,
      'strengths': strengths,
      'weaknesses': weaknesses,
    };
  }
}

class ArConfig {
  final String externalUrl;
  final String internalUrl;
  final bool isUnified;

  ArConfig({
    required this.externalUrl,
    required this.internalUrl,
    required this.isUnified,
  });

  factory ArConfig.fromJson(Map<String, dynamic> json) {
    return ArConfig(
      externalUrl: json['external_url']?.toString() ?? '',
      internalUrl: json['internal_url']?.toString() ?? '',
      isUnified: json['is_unified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'external_url': externalUrl,
      'internal_url': internalUrl,
      'is_unified': isUnified,
    };
  }
}
