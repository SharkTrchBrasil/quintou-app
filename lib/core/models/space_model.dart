import 'package:json_annotation/json_annotation.dart';

part 'space_model.g.dart';

@JsonSerializable()
class SpaceImage {
  final String id;
  final String url;
  final bool isPrimary;

  SpaceImage({
    required this.id,
    required this.url,
    required this.isPrimary,
  });

  factory SpaceImage.fromJson(Map<String, dynamic> json) => _$SpaceImageFromJson(json);
  Map<String, dynamic> toJson() => _$SpaceImageToJson(this);
}

@JsonSerializable()
class Space {
  final String id;
  final String hostId;
  final String title;
  final String description;
  @JsonKey(fromJson: _categoryFromJson)
  final String category;
  final String listingType;
  final String pricingType;
  final double price;
  final String city;
  final String state;
  final double latitude;
  final double longitude;
  final int maxGuests;
  final bool instantBook;
  final double averageRating;
  final int totalReviews;
  final List<SpaceImage> images;
  final List<String> amenities;
  final List<String> tags;

  // Host info
  @JsonKey(fromJson: _hostNameFromJson)
  final String hostName;
  @JsonKey(fromJson: _hostAvatarFromJson)
  final String hostAvatar;
  @JsonKey(fromJson: _hostVerifiedFromJson)
  final bool isVerifiedHost;
  @JsonKey(fromJson: _hostProFromJson)
  final bool isProHost;
  @JsonKey(fromJson: _hostRatingFromJson)
  final double hostRating;
  @JsonKey(fromJson: _hostReviewsFromJson)
  final int hostTotalReviews;

  // Space details
  final String spaceType;
  final double sizeLength;
  final double sizeWidth;
  final double? depthMin;
  final double? depthMax;
  final bool isOutdoor;
  final bool isAdaFriendly;
  final String? accessibilityDescription;

  // Rules
  final bool allowsParties;
  final bool allowsSmoking;
  final bool allowsAlcohol;
  final bool allowsLoudMusic;
  final bool allowsCommercial;
  final bool allowsPets;
  final String? petRules;
  final bool allowsChildren;
  final bool allowsInfants;
  final String? rules;
  final bool hasHeatedPool;
  final bool hasHotTub;

  // Infrastructure
  final bool hasRestroom;
  final String? restroomDescription;
  final bool hasParking;
  final String? parkingDescription;
  final int? parkingCapacity;
  final bool hasStreetParking;
  final bool hasPaidParking;
  final bool hasParkingLot;

  // Privacy
  final String privacyLevel;
  final String? privacyDescription;

  // Booking
  final int minHours;
  final int maxHours;
  final String cancellationPolicy;
  final int cancellationHoursBefore;
  final double securityDeposit;
  final bool requiresApproval;

  // Location
  final String addressLine;
  final String neighborhood;
  final String zipCode;

  // Delivery
  final bool deliveryAvailable;
  final double deliveryFee;
  final int deliveryRadiusKm;

  // Status
  final bool isFeatured;
  final bool isHighlyRebooked;
  final int totalViews;

  Space({
    required this.id,
    required this.hostId,
    required this.title,
    required this.description,
    required this.category,
    required this.listingType,
    required this.pricingType,
    required this.price,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.maxGuests,
    required this.instantBook,
    required this.averageRating,
    required this.totalReviews,
    required this.images,
    required this.amenities,
    required this.tags,
    required this.hostName,
    required this.hostAvatar,
    required this.isVerifiedHost,
    required this.isProHost,
    required this.hostRating,
    required this.hostTotalReviews,
    required this.spaceType,
    required this.sizeLength,
    required this.sizeWidth,
    this.depthMin,
    this.depthMax,
    required this.isOutdoor,
    required this.isAdaFriendly,
    this.accessibilityDescription,
    required this.allowsParties,
    required this.allowsSmoking,
    required this.allowsAlcohol,
    required this.allowsLoudMusic,
    required this.allowsCommercial,
    required this.allowsPets,
    this.petRules,
    required this.allowsChildren,
    required this.allowsInfants,
    this.rules,
    required this.hasHeatedPool,
    required this.hasHotTub,
    required this.hasRestroom,
    this.restroomDescription,
    required this.hasParking,
    this.parkingDescription,
    this.parkingCapacity,
    required this.hasStreetParking,
    required this.hasPaidParking,
    required this.hasParkingLot,
    required this.privacyLevel,
    this.privacyDescription,
    required this.minHours,
    required this.maxHours,
    required this.cancellationPolicy,
    required this.cancellationHoursBefore,
    required this.securityDeposit,
    required this.requiresApproval,
    required this.addressLine,
    required this.neighborhood,
    required this.zipCode,
    required this.deliveryAvailable,
    required this.deliveryFee,
    required this.deliveryRadiusKm,
    required this.isFeatured,
    required this.isHighlyRebooked,
    required this.totalViews,
  });

  factory Space.fromJson(Map<String, dynamic> json) => _$SpaceFromJson(json);
  Map<String, dynamic> toJson() => _$SpaceToJson(this);
}

String _categoryFromJson(dynamic json) {
  if (json is Map) {
    return json['name'] as String? ?? '';
  }
  return json as String? ?? '';
}

String _hostNameFromJson(dynamic json) {
  if (json is Map) {
    return json['fullName'] as String? ?? 'Anfitrião';
  }
  return 'Anfitrião';
}

String _hostAvatarFromJson(dynamic json) {
  if (json is Map) {
    return json['avatarUrl'] as String? ?? '';
  }
  return '';
}

bool _hostVerifiedFromJson(dynamic json) {
  if (json is Map) {
    return json['isVerifiedHost'] as bool? ?? false;
  }
  return false;
}

bool _hostProFromJson(dynamic json) {
  if (json is Map) {
    return json['isProHost'] as bool? ?? false;
  }
  return false;
}

double _hostRatingFromJson(dynamic json) {
  if (json is Map) {
    return (json['averageRating'] as num?)?.toDouble() ?? 0.0;
  }
  return 0.0;
}

int _hostReviewsFromJson(dynamic json) {
  if (json is Map) {
    return (json['totalReviews'] as num?)?.toInt() ?? 0;
  }
  return 0;
}
