enum FieldCategory {
  futsal('futsal'),
  miniSoccer('mini soccer');

  final String value;
  const FieldCategory(this.value);

  static FieldCategory fromString(String val) {
    return FieldCategory.values.firstWhere(
      (e) => e.value == val,
      orElse: () => FieldCategory.futsal,
    );
  }
}

class Field {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final FieldCategory category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Field({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      category: FieldCategory.fromString(json['category'] as String),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category.value,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'Field(id: $id, name: $name, category: $category)';
}
