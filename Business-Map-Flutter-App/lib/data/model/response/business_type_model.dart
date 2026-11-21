class BusinessTypeModel {
  final String id;
  final String name;
  final List<SubtypeModel> subTypes;

  BusinessTypeModel({
    required this.id,
    required this.name,
    required this.subTypes,
  });

  factory BusinessTypeModel.fromJson(Map<String, dynamic> json) {
    return BusinessTypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subTypes: (json['sub_types'] as List? ?? [])
          .map((sub) => SubtypeModel.fromJson(sub))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sub_types': subTypes.map((sub) => sub.toJson()).toList(),
    };
  }
}

class SubtypeModel {
  final String id;
  final String name;

  SubtypeModel({
    required this.id,
    required this.name,
  });

  factory SubtypeModel.fromJson(Map<String, dynamic> json) {
    return SubtypeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
