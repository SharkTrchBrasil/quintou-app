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
  });

  factory Space.fromJson(Map<String, dynamic> json) => _$SpaceFromJson(json);
  Map<String, dynamic> toJson() => _$SpaceToJson(this);
}
