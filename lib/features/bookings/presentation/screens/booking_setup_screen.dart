import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/features/bookings/presentation/widgets/guest_count_modal.dart';

class BookingSetupScreen extends StatefulWidget {
  final Space space;

  const BookingSetupScreen({super.key, required this.space});

  @override
  State<BookingSetupScreen> createState() => _BookingSetupScreenState();
}

class _BookingSetupScreenState extends State<BookingSetupScreen> {
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  String _dateText = 'Add date & time';
  final _messageController = TextEditingController();

  void _showGuestModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GuestCountModal(
        maxGuests: widget.space.maxGuests,
        onSave: (a, c, i) {
          setState(() {
            _adults = a;
            _children = c;
            _infants = i;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text('Send a message to host', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.space.images.isNotEmpty
                        ? Image.network(widget.space.images.first.url, width: 100, height: 80, fit: BoxFit.cover)
                        : Container(width: 100, height: 80, color: Colors.grey.shade300),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.space.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Hosted by Host Name', style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFF00AEEF), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.attach_money, color: Colors.white, size: 14),
                            ),
                            const SizedBox(width: 4),
                            Text('\$${widget.space.price}/hour', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            const Icon(Icons.star, color: Color(0xFF00AEEF), size: 16),
                            const SizedBox(width: 4),
                            Text('${widget.space.averageRating} (${widget.space.totalReviews})', style: const TextStyle(color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(thickness: 1, color: Color(0xFFEEEEEE)),
              ),
              
              // Forms
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('When would you like to book? *', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('Edit', style: TextStyle(color: Color(0xFF00AEEF)))),
                ],
              ),
              Text(_dateText, style: const TextStyle(fontSize: 16, color: Colors.grey)),
              
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Who's coming? *", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: _showGuestModal, child: const Text('Edit', style: TextStyle(color: Color(0xFF00AEEF)))),
                ],
              ),
              Text(
                (_adults + _children + _infants) > 1 ? '${_adults + _children + _infants} guests' : 'Add guests',
                style: TextStyle(fontSize: 16, color: (_adults + _children + _infants) > 1 ? Colors.black : Colors.grey),
              ),
              
              const SizedBox(height: 32),
              
              const Text('Message to host', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Let the host know what you\'re looking for', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Hi! I\'m planning...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00AEEF))),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Reminder from Quintou: Sharing contact information and arranging payment off-platform is against our Terms of Service.',
                  style: TextStyle(color: Color(0xFF0088CC)),
                ),
              ),
              
              const SizedBox(height: 32),
              Text('You\'d pay \$${widget.space.price}/hour', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Estimated cost before amenities, taxes, and fees. You won\'t be charged for starting a conversation.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 100), // padding bottom
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00AEEF),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Send message logic
            },
            child: const Text('Start conversation', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
