// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  phone: json['phone'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  isHost: json['isHost'] as bool,
  isActive: json['isActive'] as bool,
  emailVerified: json['emailVerified'] as bool,
  kycStatus: json['kycStatus'] as String,
  isVerifiedHost: json['isVerifiedHost'] as bool,
  averageRating: (json['averageRating'] as num).toDouble(),
  totalReviews: (json['totalReviews'] as num).toInt(),
  stripeOnboardingComplete: json['stripeOnboardingComplete'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'fullName': instance.fullName,
  'phone': instance.phone,
  'avatarUrl': instance.avatarUrl,
  'isHost': instance.isHost,
  'isActive': instance.isActive,
  'emailVerified': instance.emailVerified,
  'kycStatus': instance.kycStatus,
  'isVerifiedHost': instance.isVerifiedHost,
  'averageRating': instance.averageRating,
  'totalReviews': instance.totalReviews,
  'stripeOnboardingComplete': instance.stripeOnboardingComplete,
  'createdAt': instance.createdAt.toIso8601String(),
};

UserSummary _$UserSummaryFromJson(Map<String, dynamic> json) => UserSummary(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  isVerifiedHost: json['isVerifiedHost'] as bool,
  averageRating: (json['averageRating'] as num).toDouble(),
  totalReviews: (json['totalReviews'] as num).toInt(),
);

Map<String, dynamic> _$UserSummaryToJson(UserSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'avatarUrl': instance.avatarUrl,
      'isVerifiedHost': instance.isVerifiedHost,
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
    };

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  tokenType: json['tokenType'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'tokenType': instance.tokenType,
  'user': instance.user,
};
