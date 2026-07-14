import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:quintou_app/features/bookings/presentation/widgets/guest_count_modal.dart';

class BookingSetupScreen extends ConsumerStatefulWidget {
  final Space space;

  const BookingSetupScreen({super.key, required this.space});

  @override
  ConsumerState<BookingSetupScreen> createState() => _BookingSetupScreenState();
}

class _BookingSetupScreenState extends ConsumerState<BookingSetupScreen> {
  int _adults = 1;
  int _children = 0;
  int _infants = 0;
  final _messageController = TextEditingController();

  DateTime? _startDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  bool _isLoading = false;

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

  Future<void> _pickDateAndTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? startPicked = await showTimePicker(
        context: context,
        initialTime: _startTime ?? TimeOfDay.now(),
        helpText: 'Select Start Time',
      );
      if (startPicked != null) {
        final TimeOfDay? endPicked = await showTimePicker(
          context: context,
          initialTime: _endTime ?? TimeOfDay.now(),
          helpText: 'Select End Time',
        );
        if (endPicked != null) {
          setState(() {
            _startDate = pickedDate;
            _startTime = startPicked;
            _endTime = endPicked;
          });
        }
      }
    }
  }

  String _formatDate() {
    if (_startDate == null || _startTime == null || _endTime == null) {
      return 'Add date & time';
    }
    final sd = _startDate!;
    final st = _startTime!;
    final et = _endTime!;
    return '${sd.day.toString().padLeft(2, '0')}/${sd.month.toString().padLeft(2, '0')}/${sd.year}, ${st.format(context)} - ${et.format(context)}';
  }

  double _calculatePrice() {
    if (_startTime == null || _endTime == null) return widget.space.price;
    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;
    double hours = (endMinutes - startMinutes) / 60.0;
    if (hours <= 0) hours = 1; // Minimum 1 hour if invalid for UI calculation
    return hours * widget.space.price;
  }

  Future<void> _submitBooking() async {
    if (_startDate == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select date and time')));
      return;
    }

    setState(() => _isLoading = true);

    final startDateTime = DateTime(
      _startDate!.year, _startDate!.month, _startDate!.day,
      _startTime!.hour, _startTime!.minute
    );
    final endDateTime = DateTime(
      _startDate!.year, _startDate!.month, _startDate!.day,
      _endTime!.hour, _endTime!.minute
    );

    final payload = {
      "space_id": widget.space.id,
      "start_time": startDateTime.toIso8601String(),
      "end_time": endDateTime.toIso8601String(),
      "num_guests": _adults + _children + _infants,
      "message": _messageController.text,
      "total_price": _calculatePrice(),
    };

    try {
      final repo = ref.read(bookingRepositoryProvider);
      await repo.createBooking(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking request sent!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to book: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                        Text('Hosted by ${widget.space.hostName}', style: const TextStyle(color: Colors.grey)),
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
                  TextButton(onPressed: _pickDateAndTime, child: const Text('Edit', style: TextStyle(color: Color(0xFF00AEEF)))),
                ],
              ),
              Text(_formatDate(), style: const TextStyle(fontSize: 16, color: Colors.grey)),
              
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Who's coming? *", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: _showGuestModal, child: const Text('Edit', style: TextStyle(color: Color(0xFF00AEEF)))),
                ],
              ),
              Text(
                (_adults + _children + _infants) > 1 ? '${_adults + _children + _infants} guests' : '1 guest',
                style: TextStyle(fontSize: 16, color: (_adults + _children + _infants) > 0 ? Colors.black : Colors.grey),
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
              Text('You\'d pay \$${_calculatePrice().toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            onPressed: _isLoading ? null : _submitBooking,
            child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Start conversation', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
