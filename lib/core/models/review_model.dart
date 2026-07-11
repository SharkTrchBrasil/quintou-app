import 'package:json_annotation/json_annotation.dart';
import 'package:quintou_app/core/models/user_model.dart';
import 'package:quintou_app/core/models/space_model.dart';

part 'review_model.g.dart';

@JsonSerializable()
class Review {
  final String id;
  final String bookingId;
  final String reviewerId;
  final String spaceId;
  final int rating;
  final int valueRating;
  final String? comment;
  final String? hostResponse;
  final DateTime createdAt;
  final UserSummary? reviewer;
  final Space? space;

  Review({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.spaceId,
    required this.rating,
    required this.valueRating,
    this.comment,
    this.hostResponse,
    required this.createdAt,
    this.reviewer,
    this.space,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
