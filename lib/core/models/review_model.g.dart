// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  reviewerId: json['reviewerId'] as String,
  spaceId: json['spaceId'] as String,
  rating: (json['rating'] as num).toInt(),
  valueRating: (json['valueRating'] as num).toInt(),
  comment: json['comment'] as String?,
  hostResponse: json['hostResponse'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  reviewer: json['reviewer'] == null
      ? null
      : UserSummary.fromJson(json['reviewer'] as Map<String, dynamic>),
  space: json['space'] == null
      ? null
      : Space.fromJson(json['space'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'bookingId': instance.bookingId,
  'reviewerId': instance.reviewerId,
  'spaceId': instance.spaceId,
  'rating': instance.rating,
  'valueRating': instance.valueRating,
  'comment': instance.comment,
  'hostResponse': instance.hostResponse,
  'createdAt': instance.createdAt.toIso8601String(),
  'reviewer': instance.reviewer,
  'space': instance.space,
};
