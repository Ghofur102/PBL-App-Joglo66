import 'fields_model.dart';

class FieldPrice {
  final int id;
  final int fkFieldId;
  final String startTime;
  final String endTime;
  final String dayType;
  final int price;
  final Field? field;

  FieldPrice({
    required this.id,
    required this.fkFieldId,
    required this.startTime,
    required this.endTime,
    required this.dayType,
    required this.price,
    this.field,
  });

  factory FieldPrice.fromJson(Map<String, dynamic> json) {
    return FieldPrice(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkFieldId: int.tryParse(json['fk_field_id'].toString()) ?? 0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      dayType: json['day_type'] ?? '',
      price: int.tryParse(json['price'].toString()) ?? 0,
      field: json['field'] != null ? Field.fromJson(json['field']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_field_id': fkFieldId,
    'start_time': startTime,
    'end_time': endTime,
    'day_type': dayType,
    'price': price,
  };
}
