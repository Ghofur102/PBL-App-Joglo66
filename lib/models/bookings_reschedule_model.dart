import 'booking_details_model.dart';
import 'field_closures_model.dart';

class BookingReschedule {
  final int id;
  final int fkBookingDetailId;
  final int? fkFieldClosureId;
  final String oldDate;
  final String statusRefund;
  final String reason;

  final BookingDetail? bookingDetail;
  final FieldClosure? fieldClosure;

  BookingReschedule({
    required this.id,
    required this.fkBookingDetailId,
    this.fkFieldClosureId,
    required this.oldDate,
    required this.statusRefund,
    required this.reason,
    this.bookingDetail,
    this.fieldClosure,
  });

  factory BookingReschedule.fromJson(Map<String, dynamic> json) {
    return BookingReschedule(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkBookingDetailId: int.tryParse(json['fk_booking_detail_id'].toString()) ?? 0,
      fkFieldClosureId: json['fk_field_closure_id'] != null ? int.tryParse(json['fk_field_closure_id'].toString()) : null,
      oldDate: json['old_date'] ?? '',
      statusRefund: json['status_refund'] ?? 'none',
      reason: json['reason'] ?? '',
      bookingDetail: json['booking_detail'] != null ? BookingDetail.fromJson(json['booking_detail']) : null,
      fieldClosure: json['field_closure'] != null ? FieldClosure.fromJson(json['field_closure']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_booking_detail_id': fkBookingDetailId,
    'fk_field_closure_id': fkFieldClosureId,
    'old_date': oldDate,
    'status_refund': statusRefund,
    'reason': reason,
  };
}
