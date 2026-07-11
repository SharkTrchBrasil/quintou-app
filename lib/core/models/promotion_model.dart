import 'package:json_annotation/json_annotation.dart';

part 'promotion_model.g.dart';

@JsonSerializable()
class SpacePromotion {
  final String id;
  final String spaceId;
  final String name;
  final String? description;
  final String type;
  final double value;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minHours;
  final int? minGuests;
  final DateTime createdAt;

  SpacePromotion({
    required this.id,
    required this.spaceId,
    required this.name,
    this.description,
    required this.type,
    required this.value,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.minHours,
    this.minGuests,
    required this.createdAt,
  });

  factory SpacePromotion.fromJson(Map<String, dynamic> json) => _$SpacePromotionFromJson(json);
  Map<String, dynamic> toJson() => _$SpacePromotionToJson(this);
}
