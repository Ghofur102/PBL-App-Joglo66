import 'booking_details_model.dart';
import 'bookings_model.dart';

class Payment {
  final int id;
  final int fkBookingId;
  final int? fkBookingDetailId;
  final String referenceId;
  final String paymentUrl;
  final String paymentType;
  final String method;
  final int amount;
  final String status;
  final DateTime? paidAt;

  final Booking? booking;
  final BookingDetail? bookingDetail;

  Payment({
    required this.id,
    required this.fkBookingId,
    this.fkBookingDetailId,
    required this.referenceId,
    required this.paymentUrl,
    required this.paymentType,
    required this.method,
    required this.amount,
    required this.status,
    this.paidAt,
    this.booking,
    this.bookingDetail,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkBookingId: int.tryParse(json['fk_booking_id'].toString()) ?? 0,
      fkBookingDetailId: json['fk_booking_detail_id'] != null ? int.tryParse(json['fk_booking_detail_id'].toString()) : null,
      referenceId: json['reference_id'] ?? '',
      paymentUrl: json['payment_url'] ?? '',
      paymentType: json['payment_type'] ?? '',
      method: json['method'] ?? 'transfer',
      amount: int.tryParse(json['amount'].toString()) ?? 0,
      status: json['status'] ?? 'pending',
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at']) : null,
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
      bookingDetail: json['booking_detail'] != null ? BookingDetail.fromJson(json['booking_detail']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_booking_id': fkBookingId,
    'fk_booking_detail_id': fkBookingDetailId,
    'reference_id': referenceId,
    'payment_url': paymentUrl,
    'payment_type': paymentType,
    'method': method,
    'amount': amount,
    'status': status,
    'paid_at': paidAt?.toIso8601String(),
  };
}
