import 'booking_details_model.dart';
import 'field_closures_model.dart';

class BookingCancelled {
  final int id;
  final int fkBookingDetailId;
  final int? fkFieldClosureId;
  final String reason;
  final String? cancelDate;
  final String statusRefund;
  final String approvalStatus;
  final String senderBy;
  final String? rejectionReason;

  final BookingDetail? bookingDetail;
  final FieldClosure? fieldClosure;

  BookingCancelled({
    required this.id,
    required this.fkBookingDetailId,
    this.fkFieldClosureId,
    required this.reason,
    this.cancelDate,
    required this.statusRefund,
    this.approvalStatus = 'approved',
    this.senderBy = 'admin',
    this.rejectionReason,
    this.bookingDetail,
    this.fieldClosure,
  });

  factory BookingCancelled.fromJson(Map<String, dynamic> json) {
    return BookingCancelled(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkBookingDetailId: int.tryParse(json['fk_booking_detail_id'].toString()) ?? 0,
      fkFieldClosureId: json['fk_field_closure_id'] != null ? int.tryParse(json['fk_field_closure_id'].toString()) : null,
      reason: json['reason'] ?? '',
      cancelDate: json['cancle_date'] ?? json['cancel_date'] ?? '',
      statusRefund: json['status_refund'] ?? 'none',
      approvalStatus: json['approval_status'] ?? 'approved',
      senderBy: json['sender_by'] ?? 'admin',
      rejectionReason: json['rejection_reason'],
      bookingDetail: json['booking_detail'] != null ? BookingDetail.fromJson(json['booking_detail']) : null,
      fieldClosure: json['field_closure'] != null ? FieldClosure.fromJson(json['field_closure']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_booking_detail_id': fkBookingDetailId,
    'fk_field_closure_id': fkFieldClosureId,
    'reason': reason,
    'cancle_date': cancelDate,
    'status_refund': statusRefund,
    'approval_status': approvalStatus,
    'sender_by': senderBy,
    'rejection_reason': rejectionReason,
  };
}
