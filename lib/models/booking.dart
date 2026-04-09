class Booking {
  final int id;
  final int fkUserId;
  final int fkFieldId;
  final String teamName;
  final String bookingDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.fkUserId,
    required this.fkFieldId,
    required this.teamName,
    required this.bookingDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      fkUserId: json['fk_user_id'] as int,
      fkFieldId: json['fk_field_id'] as int,
      teamName: json['team_name'] as String,
      bookingDate: json['booking_date'] as String,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fk_user_id': fkUserId,
      'fk_field_id': fkFieldId,
      'team_name': teamName,
      'booking_date': bookingDate,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Booking(id: $id, teamName: $teamName, bookingDate: $bookingDate)';
}
