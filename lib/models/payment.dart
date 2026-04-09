enum PaymentStatus {
  pending('pending'),
  success('success'),
  failed('failed');

  final String value;
  const PaymentStatus(this.value);

  static PaymentStatus fromString(String val) {
    return PaymentStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => PaymentStatus.pending,
    );
  }
}

enum PaymentMethod {
  cash('cash'),
  transfer('transfer');

  final String value;
  const PaymentMethod(this.value);

  static PaymentMethod fromString(String val) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == val,
      orElse: () => PaymentMethod.cash,
    );
  }
}

enum PaymentType {
  downPayment('down payment'),
  finalPayment('final payment'),
  rescheduleFee('reschedule fee'),
  refund('refund');

  final String value;
  const PaymentType(this.value);

  static PaymentType fromString(String val) {
    return PaymentType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => PaymentType.downPayment,
    );
  }
}

class Payment {
  final int id;
  final int fkBookingId;
  final int? fkBookingDetailId;
  final String? referenceId;
  final String? paymentUrl;
  final PaymentType paymentType;
  final PaymentMethod method;
  final int amount;
  final PaymentStatus status;
  final DateTime? paidAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payment({
    required this.id,
    required this.fkBookingId,
    this.fkBookingDetailId,
    this.referenceId,
    this.paymentUrl,
    required this.paymentType,
    required this.method,
    required this.amount,
    required this.status,
    this.paidAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      fkBookingId: json['fk_booking_id'] as int,
      fkBookingDetailId: json['fk_booking_detail_id'] as int?,
      referenceId: json['reference_id'] as String?,
      paymentUrl: json['payment_url'] as String?,
      paymentType: PaymentType.fromString(json['payment_type'] as String),
      method: PaymentMethod.fromString(json['method'] as String),
      amount: json['amount'] as int,
      status: PaymentStatus.fromString(json['status'] as String),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fk_booking_id': fkBookingId,
      'fk_booking_detail_id': fkBookingDetailId,
      'reference_id': referenceId,
      'payment_url': paymentUrl,
      'payment_type': paymentType.value,
      'method': method.value,
      'amount': amount,
      'status': status.value,
      'paid_at': paidAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Payment(id: $id, amount: $amount, status: $status, paymentType: $paymentType)';
}
