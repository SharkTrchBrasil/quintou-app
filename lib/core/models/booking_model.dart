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

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}
