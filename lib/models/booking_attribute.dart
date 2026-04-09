class BookingAttribute {
  final int id;
  final int fkBookingId;
  final int fkAttributeId;
  final int quantity;
  final int price;
  final int total;
  final String? reason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingAttribute({
    required this.id,
    required this.fkBookingId,
    required this.fkAttributeId,
    required this.quantity,
    required this.price,
    required this.total,
    this.reason,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingAttribute.fromJson(Map<String, dynamic> json) {
    return BookingAttribute(
      id: json['id'] as int,
      fkBookingId: json['fk_booking_id'] as int,
      fkAttributeId: json['fk_attribute_id'] as int,
      quantity: json['quantity'] as int,
      price: json['price'] as int,
      total: json['total'] as int,
      reason: json['reason'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fk_booking_id': fkBookingId,
      'fk_attribute_id': fkAttributeId,
      'quantity': quantity,
      'price': price,
      'total': total,
      'reason': reason,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'BookingAttribute(id: $id, quantity: $quantity, total: $total)';
}
