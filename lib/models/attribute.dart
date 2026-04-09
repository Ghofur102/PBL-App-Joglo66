class Attribute {
  final int id;
  final int fkFieldId;
  final String name;
  final int stock;
  final int priceHour;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Attribute({
    required this.id,
    required this.fkFieldId,
    required this.name,
    required this.stock,
    required this.priceHour,
    this.createdAt,
    this.updatedAt,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: json['id'] as int,
      fkFieldId: json['fk_field_id'] as int,
      name: json['name'] as String,
      stock: json['stock'] as int,
      priceHour: json['price_hour'] as int,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fk_field_id': fkFieldId,
      'name': name,
      'stock': stock,
      'price_hour': priceHour,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Attribute(id: $id, name: $name, stock: $stock, priceHour: $priceHour)';
}
