import 'fields_model.dart';

class FinancialReport {
  final int id;
  final int fkFieldId;
  final int year;
  final int month;
  final int totalIncome;
  final int totalExpense;
  final int netProfit;
  final DateTime? generateAt;
  final Field? field;

  FinancialReport({
    required this.id,
    required this.fkFieldId,
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netProfit,
    this.generateAt,
    this.field,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkFieldId: int.tryParse(json['fk_field_id'].toString()) ?? 0,
      year: int.tryParse(json['year'].toString()) ?? 2026,
      month: int.tryParse(json['mont'].toString()) ?? int.tryParse(json['month'].toString()) ?? 1, // Mengantisipasi typo kolom 'mont' di database laravel
      totalIncome: int.tryParse(json['total_income'].toString()) ?? 0,
      totalExpense: int.tryParse(json['total_expense'].toString()) ?? 0,
      netProfit: int.tryParse(json['net_profit'].toString()) ?? 0,
      generateAt: json['generate_at'] != null ? DateTime.tryParse(json['generate_at']) : null,
      field: json['field'] != null ? Field.fromJson(json['field']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_field_id': fkFieldId,
    'year': year,
    'mont': month,
    'total_income': totalIncome,
    'total_expense': totalExpense,
    'net_profit': netProfit,
    'generate_at': generateAt?.toIso8601String(),
  };
}
