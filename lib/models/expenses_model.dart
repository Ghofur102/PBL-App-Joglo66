import 'fields_model.dart';
import 'users_model.dart';
import 'employee_salaries_model.dart';

class Expense {
  final int id;
  final int fkFieldId;
  final int fkUserId;
  final String category;
  final int amount;
  final String expenseDate;
  final String proofPhoto;
  final DateTime? generateAt;

  final Field? field;
  final User? user;
  final List<EmployeeSalary> salaries;

  Expense({
    required this.id,
    required this.fkFieldId,
    required this.fkUserId,
    required this.category,
    required this.amount,
    required this.expenseDate,
    required this.proofPhoto,
    this.generateAt,
    this.field,
    this.user,
    this.salaries = const [],
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkFieldId: int.tryParse(json['fk_field_id'].toString()) ?? 0,
      fkUserId: int.tryParse(json['fk_user_id'].toString()) ?? 0,
      category: json['category'] ?? '',
      amount: int.tryParse(json['amount'].toString()) ?? 0,
      expenseDate: json['expense_date'] ?? '',
      proofPhoto: json['proof_photo'] ?? '',
      generateAt: json['generate_at'] != null ? DateTime.tryParse(json['generate_at']) : null,
      field: json['field'] != null ? Field.fromJson(json['field']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      salaries: (json['salaries'] as List?)?.map((e) => EmployeeSalary.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_field_id': fkFieldId,
    'fk_user_id': fkUserId,
    'category': category,
    'amount': amount,
    'expense_date': expenseDate,
    'proof_photo': proofPhoto,
    'generate_at': generateAt?.toIso8601String(),
  };
}
