import 'package:flutter/material.dart';

class GuestCountModal extends StatefulWidget {
  final int maxGuests;
  final Function(int adults, int children, int infants) onSave;

  const GuestCountModal({super.key, required this.maxGuests, required this.onSave});

  @override
  State<GuestCountModal> createState() => _GuestCountModalState();
}

class _GuestCountModalState extends State<GuestCountModal> {
  int adults = 1;
  int children = 0;
  int infants = 0;

  int get totalGuests => adults + children + infants;

  void _increment(String type) {
    if (totalGuests >= widget.maxGuests) return;
    setState(() {
      if (type == 'adults') adults++;
      if (type == 'children') children++;
      if (type == 'infants') infants++;
    });
  }

  void _decrement(String type) {
    setState(() {
      if (type == 'adults' && adults > 1) adults--;
      if (type == 'children' && children > 0) children--;
      if (type == 'infants' && infants > 0) infants--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text('Set guest count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Up to ${widget.maxGuests} guests are allowed, no pets allowed.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 32, thickness: 1),
            ),
            _buildCounter('Adults', '', 'adults', adults),
            _buildCounter('Children (2-12)', '', 'children', children),
            _buildCounter('Infants (under 2)', 'Younger than 2', 'infants', infants),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFF00AEEF)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('You can always add more guests later', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            'Please note: arriving with more guests than specified in your reservation will result in a penalty',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        'R\$ ${(totalGuests * 150).toStringAsFixed(0)}', // placeholder calc
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text('See details', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AEEF),
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      widget.onSave(adults, children, infants);
                      Navigator.pop(context);
                    },
                    child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(String title, String subtitle, String type, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18)),
              if (subtitle.isNotEmpty)
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                color: value > (type == 'adults' ? 1 : 0) ? Colors.black : Colors.grey.shade300,
                onPressed: () => _decrement(type),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                color: const Color(0xFF00AEEF),
                onPressed: () => _increment(type),
              ),
            ],
          )
        ],
      ),
    );
  }
}
