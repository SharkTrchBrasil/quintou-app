import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/api/api_client.dart';
import 'package:quintou_app/core/repositories/auth_repository.dart';
import 'package:quintou_app/core/repositories/space_repository.dart';
import 'package:quintou_app/core/repositories/booking_repository.dart';
import 'package:quintou_app/core/repositories/chat_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient);
});

final spaceRepositoryProvider = Provider<SpaceRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SpaceRepository(apiClient);
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingRepository(apiClient);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatRepository(apiClient);
});
