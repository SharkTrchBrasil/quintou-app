// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceImage _$SpaceImageFromJson(Map<String, dynamic> json) => SpaceImage(
  id: json['id'] as String? ?? '',
  url: json['url'] as String? ?? '',
  isPrimary: json['isCover'] as bool? ?? false,
);

Map<String, dynamic> _$SpaceImageToJson(SpaceImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'isPrimary': instance.isPrimary,
    };

Space _$SpaceFromJson(Map<String, dynamic> json) => Space(
  id: json['id'] as String,
  hostId: json['hostId'] as String? ?? '',
  title: json['title'] as String? ?? '',
  description: json['description'] as String? ?? '',
  category: _categoryFromJson(json['category']),
  listingType: json['listingType'] as String? ?? 'SPACE',
  pricingType: json['pricingMode'] as String? ?? 'PER_HOUR',
  price: (json['price'] != null ? double.tryParse(json['price'].toString()) : 0.0) ?? 0.0,
  city: json['city'] as String? ?? '',
  state: json['state'] as String? ?? '',
  latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
  longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
  maxGuests: (json['maxGuests'] as num?)?.toInt() ?? 1,
  instantBook: json['requiresApproval'] == null ? false : !(json['requiresApproval'] as bool),
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => SpaceImage.fromJson(e as Map<String, dynamic>))
      .toList() ?? [],
  amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  hostName: _hostNameFromJson(json['host']),
  hostAvatar: _hostAvatarFromJson(json['host']),
);

Map<String, dynamic> _$SpaceToJson(Space instance) => <String, dynamic>{
  'id': instance.id,
  'hostId': instance.hostId,
  'title': instance.title,
  'description': instance.description,
  'category': instance.category,
  'listingType': instance.listingType,
  'pricingType': instance.pricingType,
  'price': instance.price,
  'city': instance.city,
  'state': instance.state,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'maxGuests': instance.maxGuests,
  'instantBook': instance.instantBook,
  'averageRating': instance.averageRating,
  'totalReviews': instance.totalReviews,
  'images': instance.images,
  'amenities': instance.amenities,
  'hostName': instance.hostName,
  'hostAvatar': instance.hostAvatar,
};
