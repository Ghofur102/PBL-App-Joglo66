import 'users_model.dart';
import 'fields_model.dart';
import 'booking_details_model.dart';
import 'booking_attributes_model.dart';
import 'payments_model.dart';

class Booking {
  final int id;
  final int fkUserId;
  final int fkFieldId;
  final String bookingDate;
  final String teamName;
  final String customerPhone;
  final String customerEmail;
  final String notes;

  // Relasi Ter-Eager Load (Nullable untuk fleksibilitas API)
  final User? user;
  final Field? field;
  final List<BookingDetail> details;
  final List<BookingAttribute> bookingAttributes;
  final List<Payment> payments;

  Booking({
    required this.id,
    required this.fkUserId,
    required this.fkFieldId,
    required this.bookingDate,
    required this.teamName,
    required this.customerPhone,
    required this.customerEmail,
    required this.notes,
    this.user,
    this.field,
    this.details = const [],
    this.bookingAttributes = const [],
    this.payments = const [],
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkUserId: int.tryParse(json['fk_user_id'].toString()) ?? 0,
      fkFieldId: int.tryParse(json['fk_field_id'].toString()) ?? 0,
      bookingDate: json['booking_date'] ?? '',
      teamName: json['team_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      notes: json['notes'] ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      field: json['field'] != null ? Field.fromJson(json['field']) : null,
      details: (json['details'] as List?)?.map((e) => BookingDetail.fromJson(e)).toList() ?? [],
      bookingAttributes: (json['attributes'] as List?)?.map((e) => BookingAttribute.fromJson(e)).toList() ?? [],
      payments: (json['payments'] as List?)?.map((e) => Payment.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_user_id': fkUserId,
    'fk_field_id': fkFieldId,
    'booking_date': bookingDate,
    'team_name': teamName,
    'customer_phone': customerPhone,
    'customer_email': customerEmail,
    'notes': notes,
  };
}
