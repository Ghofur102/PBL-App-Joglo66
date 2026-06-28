import 'fields_model.dart';

class Attribute {
  final int id;
  final int fkFieldId;
  final String name;
  final String type;
  final int stock;
  final int priceHour;
  final String status;
  final Field? field;

  Attribute({
    required this.id,
    required this.fkFieldId,
    required this.name,
    required this.type,
    required this.stock,
    required this.priceHour,
    required this.status,
    this.field,
  });

  factory Attribute.fromJson(Map<String, dynamic> json) {
    return Attribute(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkFieldId: int.tryParse(json['fk_field_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      stock: int.tryParse(json['stock'].toString()) ?? 0,
      priceHour: int.tryParse(json['price_hour'].toString()) ?? 0,
      status: json['status'] ?? 'active',
      field: json['field'] != null ? Field.fromJson(json['field']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_field_id': fkFieldId,
    'name': name,
    'type': type,
    'stock': stock,
    'price_hour': priceHour,
    'status': status,
  };
}
