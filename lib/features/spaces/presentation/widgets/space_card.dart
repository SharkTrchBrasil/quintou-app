import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:go_router/go_router.dart';

class SpaceCard extends ConsumerWidget {
  final Space space;
  final VoidCallback onTap;

  const SpaceCard({super.key, required this.space, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favoritesProvider);
    final authState = ref.watch(authProvider);
    final isFavorited = favState.isFavorited(space.id);
    // Pegar a imagem primária ou a primeira disponível
    final primaryImage = space.images.isNotEmpty 
        ? (space.images.firstWhere((img) => img.isPrimary, orElse: () => space.images.first).url)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem e Favorito
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: primaryImage != null 
                    ? Image.network(
                        primaryImage,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    icon: Icon(
                      isFavorited ? Icons.favorite : Icons.favorite_border, 
                      color: isFavorited ? Colors.red : Colors.white, 
                      size: 28
                    ),
                    onPressed: () {
                      if (authState.user == null) {
                        BotToast.showText(text: 'Faça login para favoritar');
                        context.push('/login');
                        return;
                      }
                      ref.read(favoritesProvider.notifier).toggleFavorite(space.id, space: space);
                    },
                  ),
                ),
                // Preço flutuante
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'R\$ ${space.price.toStringAsFixed(2)}/${space.pricingType == 'hourly' ? 'hr' : 'dia'}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            // Título e Avaliação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    space.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      space.averageRating > 0 ? space.averageRating.toStringAsFixed(1) : 'Novo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (space.totalReviews > 0)
                      Text(
                        ' (${space.totalReviews})',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Localização e Hóspedes
            Text(
              '${space.city}, ${space.state} • Até ${space.maxGuests} convidados',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }
}
