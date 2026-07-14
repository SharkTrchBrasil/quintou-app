import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/models/booking_model.dart';
import 'package:quintou_app/core/providers/providers.dart';

final guestBookingsProvider = FutureProvider.autoDispose<List<Booking>>((ref) async {
  final repository = ref.watch(bookingRepositoryProvider);
  return repository.getGuestBookings();
});
