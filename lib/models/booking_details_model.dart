import 'bookings_model.dart';
import 'payments_model.dart';
import 'bookings_reschedule_model.dart';
import 'bookings_cancelled_model.dart';

class BookingDetail {
  final int id;
  final int fkBookingId;
  final String startPlayTime;
  final String endPlayTime;
  final String playDate;
  final int price;
  final String status;

  final Booking? booking;
  final List<Payment> payments;
  final List<BookingReschedule> reschedules;
  final List<BookingCancelled> cancellations;

  BookingDetail({
    required this.id,
    required this.fkBookingId,
    required this.startPlayTime,
    required this.endPlayTime,
    required this.playDate,
    required this.price,
    required this.status,
    this.booking,
    this.payments = const [],
    this.reschedules = const [],
    this.cancellations = const [],
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkBookingId: int.tryParse(json['fk_booking_id'].toString()) ?? 0,
      startPlayTime: json['start_play_time'] ?? '',
      endPlayTime: json['end_play_time'] ?? '',
      playDate: json['play_date'] ?? '',
      price: int.tryParse(json['price'].toString()) ?? 0,
      status: json['status'] ?? 'waiting',
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
      payments: (json['payment'] as List?)?.map((e) => Payment.fromJson(e)).toList() ?? [],
      reschedules: (json['booking_reschedule'] as List?)?.map((e) => BookingReschedule.fromJson(e)).toList() ?? [],
      cancellations: (json['booking_cancelled'] as List?)?.map((e) => BookingCancelled.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_booking_id': fkBookingId,
    'start_play_time': startPlayTime,
    'end_play_time': endPlayTime,
    'play_date': playDate,
    'price': price,
    'status': status,
  };
}
