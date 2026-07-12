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
  @JsonKey(fromJson: _hostNameFromJson)
  final String hostName;
  @JsonKey(fromJson: _hostAvatarFromJson)
  final String hostAvatar;

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
    required this.hostName,
    required this.hostAvatar,
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
