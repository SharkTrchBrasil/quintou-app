// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpacePromotion _$SpacePromotionFromJson(Map<String, dynamic> json) =>
    SpacePromotion(
      id: json['id'] as String,
      spaceId: json['spaceId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      minHours: (json['minHours'] as num?)?.toInt(),
      minGuests: (json['minGuests'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SpacePromotionToJson(SpacePromotion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'spaceId': instance.spaceId,
      'name': instance.name,
      'description': instance.description,
      'type': instance.type,
      'value': instance.value,
      'isActive': instance.isActive,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'minHours': instance.minHours,
      'minGuests': instance.minGuests,
      'createdAt': instance.createdAt.toIso8601String(),
    };
