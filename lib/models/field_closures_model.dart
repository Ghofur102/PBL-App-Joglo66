import 'fields_model.dart';
import 'users_model.dart';

class FieldClosure {
  final int id;
  final int fkUserId;
  final int fkFieldId;
  final DateTime? fieldClosureStartTime;
  final DateTime? fieldClosureEndTime;
  final String reason;
  final User? user;
  final Field? field;

  FieldClosure({
    required this.id,
    required this.fkUserId,
    required this.fkFieldId,
    this.fieldClosureStartTime,
    this.fieldClosureEndTime,
    required this.reason,
    this.user,
    this.field,
  });

  factory FieldClosure.fromJson(Map<String, dynamic> json) {
    return FieldClosure(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkUserId: int.tryParse(json['fk_user_id'].toString()) ?? 0,
      fkFieldId: int.tryParse(json['fk_field_id'].toString()) ?? 0,
      fieldClosureStartTime: json['field_closure_start_time'] != null
          ? DateTime.tryParse(json['field_closure_start_time'])
          : null,
      fieldClosureEndTime: json['field_closure_end_time'] != null
          ? DateTime.tryParse(json['field_closure_end_time'])
          : null,
      reason: json['reason'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      field: json['field'] != null ? Field.fromJson(json['field']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_user_id': fkUserId,
    'fk_field_id': fkFieldId,
    'field_closure_start_time': fieldClosureStartTime?.toIso8601String(),
    'field_closure_end_time': fieldClosureEndTime?.toIso8601String(),
    'reason': reason,
  };
}
