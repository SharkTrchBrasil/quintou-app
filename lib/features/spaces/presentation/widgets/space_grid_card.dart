import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpaceGridCard extends ConsumerWidget {
  final Space space;
  final VoidCallback onTap;
  final double width;

  const SpaceGridCard({
    super.key,
    required this.space,
    required this.onTap,
    this.width = 160,
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

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Favorite Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: width,
                    height: width * 1.25, // roughly 4:5 aspect ratio
                    color: Colors.grey[200],
                    child: primaryImage != null 
                      ? CachedNetworkImage(
                          imageUrl: primaryImage,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
                        )
                      : const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
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
                      padding: const EdgeInsets.all(6.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border, 
                        size: 18, 
                        color: isFavorited ? Colors.red : Colors.black87
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              space.title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Badges (Instant Book / Cancelamento)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (space.instantBook)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE4D4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Reserva instantânea', style: TextStyle(fontSize: 10, color: Color(0xFFD67300), fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F0FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Entrega fácil', style: TextStyle(fontSize: 10, color: Color(0xFF8A2BE2), fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Price
            Text(
              _formatPrice(space.price),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 2),
            // Location
            Text(
              '${space.city} - ${space.state}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
