import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/features/bookings/presentation/providers/guest_bookings_provider.dart';
import 'package:intl/intl.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/core/widgets/login_required_placeholder.dart';
import 'package:quintou_app/features/bookings/presentation/widgets/booking_card.dart';
import 'package:go_router/go_router.dart';

class GuestBookingsScreen extends ConsumerWidget {
  const GuestBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    if (authState.user == null) {
      return const LoginRequiredPlaceholder(
        title: 'Agendamentos',
        message: 'Faça login para ver seus agendamentos',
        subMessage: 'Acompanhe o status das suas reservas e históricos de agendamentos.',
        icon: Icons.luggage_outlined,
      );
    }
    final bookingsAsync = ref.watch(guestBookingsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
        title: const Text('Meus Agendamentos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Pendentes'),
              Tab(text: 'Confirmadas'),
              Tab(text: 'Canceladas'),
            ],
          ),
        ),
        body: bookingsAsync.when(
          data: (bookings) {
            final pending = bookings.where((b) => b.status == 'pending').toList();
            final confirmed = bookings.where((b) => b.status == 'confirmed').toList();
            final cancelled = bookings.where((b) => b.status == 'cancelled').toList();

            return TabBarView(
              children: [
                _BookingList(bookings: pending, emptyMessage: 'Nenhuma viagem pendente.'),
                _BookingList(bookings: confirmed, emptyMessage: 'Nenhuma viagem confirmada.'),
                _BookingList(bookings: cancelled, emptyMessage: 'Nenhuma viagem cancelada.'),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Erro: $err')),
        ),
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<dynamic> bookings;
  final String emptyMessage;

  const _BookingList({required this.bookings, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return BookingCard(
          booking: booking,
          onTap: () {
            context.push('/booking-details', extra: {
              'booking': booking,
              'isHostMode': false,
            });
          },
        );
      },
    );
  }
}
