import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/features/spaces/presentation/widgets/space_list_card.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(favoritesProvider.notifier).loadFavorites();
    });
  }

  String _formatPrice(double price, String pricingType) {
    String suffix = '/hora';
    final type = pricingType.toLowerCase();
    if (type.contains('day') || type.contains('dia') || type == 'daily') {
      suffix = '/dia';
    }
    return 'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final favState = ref.watch(favoritesProvider);

    // Not logged in
    if (authState.user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Favoritos',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Faça login para ver seus favoritos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Salve os espaços que mais gostou para encontrá-los facilmente depois.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Favoritos',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildBody(favState),
    );
  }

  Widget _buildBody(FavoritesState favState) {
    if (favState.isLoading && favState.favoriteSpaces.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFB7F65E)),
      );
    }

    if (favState.favoriteSpaceIds.isEmpty) {
      return _buildEmptyState();
    }

    // If we have space IDs but no full space data, show a simpler list
    if (favState.favoriteSpaces.isEmpty) {
      return _buildSimpleFavoritesList(favState);
    }

    return RefreshIndicator(
      color: const Color(0xFFB7F65E),
      onRefresh: () => ref.read(favoritesProvider.notifier).loadFavorites(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: favState.favoriteSpaces.length,
        itemBuilder: (context, index) {
          final space = favState.favoriteSpaces[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SpaceListCard(
              space: space,
              onTap: () => context.push('/space-details', extra: space),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFB7F65E).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 64,
                color: Color(0xFF8BC34A),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum favorito ainda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore os espaços disponíveis e toque no ❤️ para salvar seus preferidos aqui.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to explore tab (index 1)
                // Using the shell's tab index provider
                context.go('/');
              },
              icon: const Icon(Icons.search),
              label: const Text('Explorar espaços'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.black87),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleFavoritesList(FavoritesState favState) {
    return RefreshIndicator(
      color: const Color(0xFFB7F65E),
      onRefresh: () => ref.read(favoritesProvider.notifier).loadFavorites(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: favState.favoriteSpaceIds.length,
        itemBuilder: (context, index) {
          final spaceId = favState.favoriteSpaceIds.elementAt(index);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home_work, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Espaço favoritado',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red, size: 24),
                  onPressed: () {
                    ref.read(favoritesProvider.notifier).toggleFavorite(spaceId);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
