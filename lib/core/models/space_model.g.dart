// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpaceImage _$SpaceImageFromJson(Map<String, dynamic> json) => SpaceImage(
  id: json['id'] as String,
  url: json['url'] as String,
  isPrimary: json['isPrimary'] as bool,
);

Map<String, dynamic> _$SpaceImageToJson(SpaceImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'isPrimary': instance.isPrimary,
    };

Space _$SpaceFromJson(Map<String, dynamic> json) => Space(
  id: json['id'] as String,
  hostId: json['hostId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  listingType: json['listingType'] as String,
  pricingType: json['pricingType'] as String,
  price: (json['price'] as num).toDouble(),
  city: json['city'] as String,
  state: json['state'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  maxGuests: (json['maxGuests'] as num).toInt(),
  instantBook: json['instantBook'] as bool,
  averageRating: (json['averageRating'] as num).toDouble(),
  totalReviews: (json['totalReviews'] as num).toInt(),
  images: (json['images'] as List<dynamic>)
      .map((e) => SpaceImage.fromJson(e as Map<String, dynamic>))
      .toList(),
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
};
