import 'users_model.dart';
import 'employee_salaries_model.dart';

class Employee {
  final int id;
  final int fkUserId;
  final String name;
  final String phoneNumber;
  final String address;
  final String position;
  final int baseSalary;
  final String joinDate;
  final String status;

  final User? user;
  final List<EmployeeSalary> salaries;

  Employee({
    required this.id,
    required this.fkUserId,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.position,
    required this.baseSalary,
    required this.joinDate,
    required this.status,
    this.user,
    this.salaries = const [],
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkUserId: int.tryParse(json['fk_user_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      address: json['address'] ?? '',
      position: json['position'] ?? '',
      baseSalary: int.tryParse(json['base_salary'].toString()) ?? 0,
      joinDate: json['join_date'] ?? '',
      status: json['status'] ?? 'active',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      salaries: (json['salaries'] as List?)?.map((e) => EmployeeSalary.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_user_id': fkUserId,
    'name': name,
    'phone_number': phoneNumber,
    'address': address,
    'position': position,
    'base_salary': baseSalary,
    'join_date': joinDate,
    'status': status,
  };

  String get activePhone {
    if (phoneNumber.isNotEmpty && phoneNumber != '-') return phoneNumber;
    if (user != null && user!.phone.isNotEmpty) return user!.phone;
    return '-';
  }
}
