class TargetAreaModel {
  final String id;
  final String cityId;
  final String name;
  final String type;
  final Coordinates coordinates;

  TargetAreaModel({
    required this.id,
    required this.cityId,
    required this.name,
    required this.type,
    required this.coordinates,
  });

  factory TargetAreaModel.fromJson(Map<String, dynamic> json) {
    return TargetAreaModel(
      id: json['id']?.toString() ?? '',
      cityId: json['city_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_id': cityId,
      'name': name,
      'type': type,
      'coordinates': coordinates.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TargetAreaModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Coordinates {
  final double lat;
  final double lng;

  Coordinates({
    required this.lat,
    required this.lng,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}
