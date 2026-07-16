import 'package:json_annotation/json_annotation.dart';
import 'package:quintou_app/core/models/user_model.dart';
import 'package:quintou_app/core/models/space_model.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class Booking {
  final String id;
  final String guestId;
  final String spaceId;
  final DateTime startTime;
  final DateTime endTime;
  final int numGuests;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final UserSummary? guest;
  final Space? space;

  Booking({
    required this.id,
    required this.guestId,
    required this.spaceId,
    required this.startTime,
    required this.endTime,
    required this.numGuests,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.guest,
    this.space,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'];
    final startStr = json['startTime'] ?? json['start_time'];
    final endStr = json['endTime'] ?? json['end_time'];

    // Concatenate date + time for proper DateTime parsing
    if (dateStr != null && startStr != null && !startStr.toString().contains('T')) {
      json['startTime'] = '${dateStr}T$startStr';
    }
    if (dateStr != null && endStr != null && !endStr.toString().contains('T')) {
      json['endTime'] = '${dateStr}T$endStr';
    }

    // Map snake_case to camelCase in case the API changed
    json['guestId'] ??= json['guest_id'];
    json['spaceId'] ??= json['space_id'];
    // Parse numGuests
    var nGuests = json['numGuests'] ?? json['num_guests'];
    if (nGuests is String) {
      json['numGuests'] = int.tryParse(nGuests) ?? 1;
    } else {
      json['numGuests'] = nGuests;
    }

    // Parse totalPrice
    var tPrice = json['totalPrice'] ?? json['total_price'];
    if (tPrice is String) {
      json['totalPrice'] = double.tryParse(tPrice) ?? 0.0;
    } else {
      json['totalPrice'] = tPrice;
    }
    
    json['createdAt'] ??= json['created_at'];

    return _$BookingFromJson(json);
  }
  
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}
