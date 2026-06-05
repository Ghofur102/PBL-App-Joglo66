class TransaksiHarian {
  final int id;
  final String namaCustomer; // dari bookings.team_name
  final String jenisTransaksi; // payments.payment_type
  final String status; // payments.status
  final int nominal; // payments.amount
  final DateTime? waktu; // payments.paid_at
  final String? referenceId; // payments.reference_id
  final String? fieldName; // dari relasi field

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
      id: json['id'] as int,
      namaCustomer: json['team_name'] as String? ?? '-',
      jenisTransaksi: json['payment_type'] as String? ?? '-',
      status: json['status'] as String? ?? 'pending',
      nominal: (json['amount'] as num?)?.toInt() ?? 0,
      waktu: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'] as String)
          : null,
      referenceId: json['reference_id'] as String?,
      fieldName: json['field_name'] as String?,
    );
  }
}