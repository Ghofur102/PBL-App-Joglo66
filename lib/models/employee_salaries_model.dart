import 'employees_model.dart';
import 'expenses_model.dart';

class EmployeeSalary {
  final int id;
  final int fkEmployeeId;
  final int fkExpenseId;
  final int amountPaid;
  final int periodMonth;
  final int periodYear;
  final String paymentDate;
  final int bonus;
  final int deduction;
  final String notes;

  final Employee? employee;
  final Expense? expense;

  EmployeeSalary({
    required this.id,
    required this.fkEmployeeId,
    required this.fkExpenseId,
    required this.amountPaid,
    required this.periodMonth,
    required this.periodYear,
    required this.paymentDate,
    required this.bonus,
    required this.deduction,
    required this.notes,
    this.employee,
    this.expense,
  });

  factory EmployeeSalary.fromJson(Map<String, dynamic> json) {
    return EmployeeSalary(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkEmployeeId: int.tryParse(json['fk_employee_id'].toString()) ?? 0,
      fkExpenseId: int.tryParse(json['fk_expense_id'].toString()) ?? 0,
      amountPaid: int.tryParse(json['amount_paid'].toString()) ?? 0,
      periodMonth: int.tryParse(json['period_month'].toString()) ?? 1,
      periodYear: int.tryParse(json['period_year'].toString()) ?? 2026,
      paymentDate: json['payment_date'] ?? '',
      bonus: int.tryParse(json['bonus'].toString()) ?? 0,
      deduction: int.tryParse(json['deduction'].toString()) ?? 0,
      notes: json['notes'] ?? '',
      employee: json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      expense: json['expense'] != null ? Expense.fromJson(json['expense']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_employee_id': fkEmployeeId,
    'fk_expense_id': fkExpenseId,
    'amount_paid': amountPaid,
    'period_month': periodMonth,
    'period_year': periodYear,
    'payment_date': paymentDate,
    'bonus': bonus,
    'deduction': deduction,
    'notes': notes,
  };
}
