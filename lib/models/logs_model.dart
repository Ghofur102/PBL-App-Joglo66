import 'users_model.dart';

class Log {
  final int id;
  final int fkUserId;
  final String action;
  final String tableName;
  final int recordId;
  final String description;
  final User? user;

  Log({
    required this.id,
    required this.fkUserId,
    required this.action,
    required this.tableName,
    required this.recordId,
    required this.description,
    this.user,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkUserId: int.tryParse(json['fk_user_id'].toString()) ?? 0,
      action: json['action'] ?? '',
      tableName: json['table_name'] ?? '',
      recordId: int.tryParse(json['record_id'].toString()) ?? 0,
      description: json['description'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_user_id': fkUserId,
    'action': action,
    'table_name': tableName,
    'record_id': recordId,
    'description': description,
  };
}
