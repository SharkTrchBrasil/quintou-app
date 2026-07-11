import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatarUrl;
  final bool isHost;
  final bool isActive;
  final bool emailVerified;
  final String kycStatus;
  final bool isVerifiedHost;
  final double averageRating;
  final int totalReviews;
  final bool stripeOnboardingComplete;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatarUrl,
    required this.isHost,
    required this.isActive,
    required this.emailVerified,
    required this.kycStatus,
    required this.isVerifiedHost,
    required this.averageRating,
    required this.totalReviews,
    this.stripeOnboardingComplete = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserSummary {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final bool isVerifiedHost;
  final double averageRating;
  final int totalReviews;

  UserSummary({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    required this.isVerifiedHost,
    required this.averageRating,
    required this.totalReviews,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) => _$UserSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$UserSummaryToJson(this);
}

@JsonSerializable()
class Token {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final User user;

  Token({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);
  Map<String, dynamic> toJson() => _$TokenToJson(this);
}
