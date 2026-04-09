enum BookingStatus {
  active('active'),
  waiting('waiting'),
  finish('finish'),
  cancelled('cancelled'),
  reschedule('reschedule');

  final String value;
  const BookingStatus(this.value);

  static BookingStatus fromString(String val) {
    return BookingStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => BookingStatus.waiting,
    );
  }
}

class BookingDetail {
  final int id;
  final int fkBookingId;
  final String startPlayTime;
  final String endPlayTime;
  final String playDate;
  final int price;
  final BookingStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingDetail({
    required this.id,
    required this.fkBookingId,
    required this.startPlayTime,
    required this.endPlayTime,
    required this.playDate,
    required this.price,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory BookingDetail.fromJson(Map<String, dynamic> json) {
    return BookingDetail(
      id: json['id'] as int,
      fkBookingId: json['fk_booking_id'] as int,
      startPlayTime: json['start_play_time'] as String,
      endPlayTime: json['end_play_time'] as String,
      playDate: json['play_date'] as String,
      price: json['price'] as int,
      status: BookingStatus.fromString(json['status'] as String),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fk_booking_id': fkBookingId,
      'start_play_time': startPlayTime,
      'end_play_time': endPlayTime,
      'play_date': playDate,
      'price': price,
      'status': status.value,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'BookingDetail(id: $id, playDate: $playDate, status: $status, price: $price)';
}
