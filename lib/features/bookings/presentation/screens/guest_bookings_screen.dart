import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/features/bookings/presentation/providers/guest_bookings_provider.dart';
import 'package:intl/intl.dart';

class GuestBookingsScreen extends ConsumerWidget {
  const GuestBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(guestBookingsProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Cancelled'),
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
                _BookingList(bookings: pending, emptyMessage: 'No pending bookings.'),
                _BookingList(bookings: confirmed, emptyMessage: 'No confirmed bookings.'),
                _BookingList(bookings: cancelled, emptyMessage: 'No cancelled bookings.'),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final space = booking.space;
        final start = DateFormat('MMM d, y').format(booking.startTime);
        final end = DateFormat('MMM d, y').format(booking.endTime);
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (space != null)
                  Text(space.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                Text('$start - $end', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Text('Guests: ${booking.numGuests}', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Text('Total: \$${booking.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        );
      },
    );
  }
}
