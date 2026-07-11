import 'package:flutter/material.dart';
import 'package:quintou_app/core/models/space_model.dart';

class SpaceListCard extends StatelessWidget {
  final Space space;
  final VoidCallback onTap;
  final VoidCallback? onChatPressed;

  const SpaceListCard({
    super.key,
    required this.space,
    required this.onTap,
    this.onChatPressed,
  });

  String _formatPrice(double price) {
    return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryImage = space.images.isNotEmpty 
        ? (space.images.firstWhere((img) => img.isPrimary, orElse: () => space.images.first).url)
        : null;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: primaryImage != null
                          ? Image.network(
                              primaryImage,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                            )
                          : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.favorite_border, size: 20, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: SizedBox(
                    height: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          space.title,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Guests info
                        Text(
                          'Até ${space.maxGuests} convidados',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Price
                        Text(
                          _formatPrice(space.price),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Location
                        Text(
                          '${space.city}, ${space.state}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Chat Button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Colors.black87),
                label: const Text(
                  'Chat',
                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: onChatPressed ?? () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
