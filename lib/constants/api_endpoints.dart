import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static String get login => '$baseUrl/api/login';
  static String get logout => '$baseUrl/api/admin/logout';
  static String get profile => '$baseUrl/api/admin/profile';
  static String get activeBookings => '$baseUrl/api/admin/active-bookings';
  static String get rentAttribute => '$baseUrl/api/admin/rent-attribute';
  static String get returnAttribute => '$baseUrl/api/admin/return-rent-attribute';
  static String get historyAttribute => '$baseUrl/api/admin/history-rent-attribute';
  static String get detailAttribute => '$baseUrl/api/admin/detail-attribute';
  static String get listAttribute => '$baseUrl/api/admin/list-attribute';
  static String get attributeTypes => '$baseUrl/api/admin/attribute-types';
  static String get createAttribute => '$baseUrl/api/admin/create-attribute';
  static String get updateAttribute => '$baseUrl/api/admin/update-attribute';
  static String get deleteAttribute => '$baseUrl/api/admin/delete-attribute';
  static String get toggleAttribute => '$baseUrl/api/admin/toggle-attribute-status';
  static String get listBooking => '$baseUrl/api/admin/list-booking';
  static String get createBooking => '$baseUrl/api/admin/create-booking';
  static String get detailBooking => '$baseUrl/api/admin/detail-booking';
  static String get rescheduleBooking => '$baseUrl/api/admin/reschedule-booking';
  static String get cancelBooking => '$baseUrl/api/admin/cancel-booking';
  static String get listClosedBooking => '$baseUrl/api/admin/list-close-booking';
  static String get dashboard => '$baseUrl/api/admin/dashboard';
  static String get listExpense => '$baseUrl/api/admin/list-expense';
  static String get expenseCategories => '$baseUrl/api/admin/expense-categories';
  static String get createExpense => '$baseUrl/api/admin/create-expense';
  static String get updateExpense => '$baseUrl/api/admin/update-expense';
  static String get deleteExpense => '$baseUrl/api/admin/delete-expense';
  static String get listField => '$baseUrl/api/admin/list-field';
  static String get detailField => '$baseUrl/api/admin/detail-field';
  static String get updateField => '$baseUrl/api/admin/update-field';
  static String get checkSlot => '$baseUrl/api/admin/check-slot-availability';
  static String get closeField => '$baseUrl/api/admin/close-field';
  static String get salary => '$baseUrl/api/treasurer/gaji';
  static String get salaryUpdate => '$baseUrl/api/treasurer/gaji/update';
  static String get salarySync => '$baseUrl/api/treasurer/gaji/sync';
  static String get employee => '$baseUrl/api/owner/karyawan';
  static String get monthlyReport => '$baseUrl/api/laporan-bulanan';
  static String get dailyRecap => '$baseUrl/api/admin/rekap-harian';
  static String get paymentBooking => '$baseUrl/api/admin/payment-booking';
}
