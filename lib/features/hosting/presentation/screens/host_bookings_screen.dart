import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/features/hosting/presentation/providers/host_bookings_provider.dart';
import 'package:quintou_app/features/bookings/presentation/widgets/booking_card.dart';
import 'package:go_router/go_router.dart';

class HostBookingsScreen extends ConsumerWidget {
  const HostBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(hostBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text('Nenhuma reserva encontrada.'));
          }
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox.shrink(),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return BookingCard(
                booking: booking,
                isHostMode: true,
                onTap: () {
                  context.push('/booking-details', extra: {
                    'booking': booking,
                    'isHostMode': true,
                  });
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erro: $err')),
      ),
    );
  }
}
