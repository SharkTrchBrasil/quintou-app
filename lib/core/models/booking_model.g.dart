// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
  id: json['id'] as String,
  guestId: json['guestId'] as String,
  spaceId: json['spaceId'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  numGuests: (json['numGuests'] as num).toInt(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  status: json['status'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  guest: json['guest'] == null
      ? null
      : UserSummary.fromJson(json['guest'] as Map<String, dynamic>),
  space: json['space'] == null
      ? null
      : Space.fromJson(json['space'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
  'id': instance.id,
  'guestId': instance.guestId,
  'spaceId': instance.spaceId,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'numGuests': instance.numGuests,
  'totalPrice': instance.totalPrice,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'guest': instance.guest,
  'space': instance.space,
};
