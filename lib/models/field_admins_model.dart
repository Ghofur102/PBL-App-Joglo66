import 'fields_model.dart';
import 'users_model.dart';

class FieldAdmin {
  final int id;
  final int fieldId;
  final int userId;
  final Field? field;
  final User? user;

  FieldAdmin({
    required this.id,
    required this.fieldId,
    required this.userId,
    this.field,
    this.user,
  });

  factory FieldAdmin.fromJson(Map<String, dynamic> json) {
    return FieldAdmin(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fieldId: int.tryParse(json['field_id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      field: json['field'] != null ? Field.fromJson(json['field']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'field_id': fieldId,
    'user_id': userId,
  };
}
