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
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  // Host
  hostName: _hostNameFromJson(json['host']),
  hostAvatar: _hostAvatarFromJson(json['host']),
  isVerifiedHost: _hostVerifiedFromJson(json['host']),
  isProHost: _hostProFromJson(json['host']),
  hostRating: _hostRatingFromJson(json['host']),
  hostTotalReviews: _hostReviewsFromJson(json['host']),
  // Space details
  spaceType: json['spaceType'] as String? ?? '',
  sizeLength: (json['sizeLength'] as num?)?.toDouble() ?? 0.0,
  sizeWidth: (json['sizeWidth'] as num?)?.toDouble() ?? 0.0,
  depthMin: (json['depthMin'] as num?)?.toDouble(),
  depthMax: (json['depthMax'] as num?)?.toDouble(),
  isOutdoor: json['isOutdoor'] as bool? ?? false,
  isAdaFriendly: json['isAdaFriendly'] as bool? ?? false,
  accessibilityDescription: json['accessibilityDescription'] as String?,
  // Rules
  allowsParties: json['allowsParties'] as bool? ?? false,
  allowsSmoking: json['allowsSmoking'] as bool? ?? false,
  allowsAlcohol: json['allowsAlcohol'] as bool? ?? false,
  allowsLoudMusic: json['allowsLoudMusic'] as bool? ?? false,
  allowsCommercial: json['allowsCommercial'] as bool? ?? false,
  allowsPets: json['allowsPets'] as bool? ?? false,
  petRules: json['petRules'] as String?,
  allowsChildren: json['allowsChildren'] as bool? ?? true,
  allowsInfants: json['allowsInfants'] as bool? ?? true,
  rules: json['rules'] as String?,
  hasHeatedPool: json['hasHeatedPool'] as bool? ?? false,
  hasHotTub: json['hasHotTub'] as bool? ?? false,
  // Infrastructure
  hasRestroom: json['hasRestroom'] as bool? ?? false,
  restroomDescription: json['restroomDescription'] as String?,
  hasParking: json['hasParking'] as bool? ?? false,
  parkingDescription: json['parkingDescription'] as String?,
  parkingCapacity: (json['parkingCapacity'] as num?)?.toInt(),
  hasStreetParking: json['hasStreetParking'] as bool? ?? false,
  hasPaidParking: json['hasPaidParking'] as bool? ?? false,
  hasParkingLot: json['hasParkingLot'] as bool? ?? false,
  // Privacy
  privacyLevel: json['privacyLevel'] as String? ?? 'Standard',
  privacyDescription: json['privacyDescription'] as String?,
  // Booking
  minHours: (json['minHours'] as num?)?.toInt() ?? 2,
  maxHours: (json['maxHours'] as num?)?.toInt() ?? 12,
  cancellationPolicy: json['cancellationPolicy'] as String? ?? 'FLEXIVEL',
  cancellationHoursBefore: (json['cancellationHoursBefore'] as num?)?.toInt() ?? 24,
  securityDeposit: (json['securityDeposit'] != null ? double.tryParse(json['securityDeposit'].toString()) : 0.0) ?? 0.0,
  requiresApproval: json['requiresApproval'] as bool? ?? true,
  // Location
  addressLine: json['addressLine'] as String? ?? '',
  neighborhood: json['neighborhood'] as String? ?? '',
  zipCode: json['zipCode'] as String? ?? '',
  // Delivery
  deliveryAvailable: json['deliveryAvailable'] as bool? ?? false,
  deliveryFee: (json['deliveryFee'] != null ? double.tryParse(json['deliveryFee'].toString()) : 0.0) ?? 0.0,
  deliveryRadiusKm: (json['deliveryRadiusKm'] as num?)?.toInt() ?? 10,
  // Status
  isFeatured: json['isFeatured'] as bool? ?? false,
  isHighlyRebooked: json['isHighlyRebooked'] as bool? ?? false,
  totalViews: (json['totalViews'] as num?)?.toInt() ?? 0,
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
  'tags': instance.tags,
};
