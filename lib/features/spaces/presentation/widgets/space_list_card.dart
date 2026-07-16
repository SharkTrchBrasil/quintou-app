import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpaceListCard extends ConsumerWidget {
  final Space space;
  final VoidCallback onTap;

  const SpaceListCard({
    super.key,
    required this.space,
    required this.onTap,
  });

  String _formatPrice(double price) {
    String suffix = '/hora';
    if (space.pricingType != null) {
      final type = space.pricingType.toString().toLowerCase();
      if (type.contains('day') || type.contains('dia') || type == 'daily') {
        suffix = '/dia';
      }
    }
    return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}$suffix';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favoritesProvider);
    final authState = ref.watch(authProvider);
    final isFavorited = favState.isFavorited(space.id);
    final primaryImage = space.images.isNotEmpty 
        ? (space.images.firstWhere((img) => img.isPrimary, orElse: () => space.images.first).url)
        : null;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
                          ? CachedNetworkImage(
                              imageUrl: primaryImage,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                            )
                          : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            if (authState.user == null) {
                              BotToast.showText(text: 'Faça login para favoritar');
                              context.push('/login');
                              return;
                            }
                            ref.read(favoritesProvider.notifier).toggleFavorite(space.id, space: space);
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border, 
                                size: 20, 
                                color: isFavorited ? Colors.red : Colors.black87
                              ),
                            ),
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
                        const SizedBox(height: 6),
                        
                        // Badges
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            if (space.instantBook)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt, size: 12, color: Colors.amber[900]),
                                    const SizedBox(width: 2),
                                    Text('Reserva instantânea', style: TextStyle(fontSize: 10, color: Colors.amber[900], fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            if (space.cancellationPolicy.toLowerCase().contains('flex'))
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.event_available, size: 12, color: Colors.green),
                                    const SizedBox(width: 2),
                                    Text('Cancelamento flexível', style: TextStyle(fontSize: 10, color: Colors.green[900], fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                          ],
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
          ],
        ),
      ),
    );
  }
}
