import 'payments_model.dart';

class TransaksiHarian {
  final int id;
  final String namaCustomer;
  final String jenisTransaksi;
  final String status;
  final int nominal;
  final DateTime? waktu;
  final String? referenceId;
  final String? fieldName;

  const TransaksiHarian({
    required this.id,
    required this.namaCustomer,
    required this.jenisTransaksi,
    required this.status,
    required this.nominal,
    this.waktu,
    this.referenceId,
    this.fieldName,
  });

  factory TransaksiHarian.fromJson(Map<String, dynamic> json) {
    return TransaksiHarian(
      id: int.tryParse(json['id'].toString()) ?? 0,
      namaCustomer: json['team_name']?.toString() ?? json['booking']?['team_name']?.toString() ?? '-',
      jenisTransaksi: json['payment_type']?.toString() ?? '-',
      status: json['status']?.toString() ?? 'pending',
      nominal: int.tryParse(json['amount'].toString()) ?? 0,
      waktu: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
      referenceId: json['reference_id']?.toString(),
      fieldName: json['field_name']?.toString() ?? json['booking']?['field']?['name']?.toString() ?? '-',
    );
  }

  factory TransaksiHarian.fromPayment(Payment payment) {
    return TransaksiHarian(
      id: payment.id,
      namaCustomer: payment.booking?.teamName ?? '-',
      jenisTransaksi: payment.paymentType,
      status: payment.status,
      nominal: payment.amount,
      waktu: payment.paidAt,
      referenceId: payment.referenceId,
      fieldName: payment.booking?.field?.name ?? '-',
    );
  }
}
