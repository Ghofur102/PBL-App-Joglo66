import 'bookings_model.dart';
import 'attributes_model.dart';

class BookingAttribute {
  final int id;
  final int fkBookingId;
  final int fkAttributeId;
  final int quantity;
  final int price;
  final int total;
  final String transactionDate;
  final String status;
  final String customerName;
  final String customerPhone;
  final int durationHours;
  final String reason;

  final Booking? booking;
  final Attribute? attribute;

  BookingAttribute({
    required this.id,
    required this.fkBookingId,
    required this.fkAttributeId,
    required this.quantity,
    required this.price,
    required this.total,
    required this.transactionDate,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.durationHours,
    required this.reason,
    this.booking,
    this.attribute,
  });

  factory BookingAttribute.fromJson(Map<String, dynamic> json) {
    return BookingAttribute(
      id: int.tryParse(json['id'].toString()) ?? 0,
      fkBookingId: int.tryParse(json['fk_booking_id'].toString()) ?? 0,
      fkAttributeId: int.tryParse(json['fk_attribute_id'].toString()) ?? 0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      price: int.tryParse(json['price'].toString()) ?? 0,
      total: int.tryParse(json['total'].toString()) ?? 0,
      transactionDate: json['transaction_date'] ?? '',
      status: json['status'] ?? 'pending',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      durationHours: int.tryParse(json['duration_hours'].toString()) ?? 0,
      reason: json['reason'] ?? '',
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
      attribute: json['attribute'] != null ? Attribute.fromJson(json['attribute']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fk_booking_id': fkBookingId,
    'fk_attribute_id': fkAttributeId,
    'quantity': quantity,
    'price': price,
    'total': total,
    'transaction_date': transactionDate,
    'status': status,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'duration_hours': durationHours,
    'reason': reason,
  };
}
