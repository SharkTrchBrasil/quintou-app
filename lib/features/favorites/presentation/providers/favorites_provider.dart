import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:quintou_app/core/models/space_model.dart';

/// State for the favorites feature
class FavoritesState {
  final Set<String> favoriteSpaceIds;
  final List<Space> favoriteSpaces;
  final bool isLoading;
  final String? error;

  FavoritesState({
    this.favoriteSpaceIds = const {},
    this.favoriteSpaces = const [],
    this.isLoading = false,
    this.error,
  });

  FavoritesState copyWith({
    Set<String>? favoriteSpaceIds,
    List<Space>? favoriteSpaces,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return FavoritesState(
      favoriteSpaceIds: favoriteSpaceIds ?? this.favoriteSpaceIds,
      favoriteSpaces: favoriteSpaces ?? this.favoriteSpaces,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool isFavorited(String spaceId) => favoriteSpaceIds.contains(spaceId);
}

/// Notifier for managing favorites state
class FavoritesNotifier extends Notifier<FavoritesState> {
  @override
  FavoritesState build() {
    return FavoritesState();
  }

  /// Load all user favorites from the API
  Future<void> loadFavorites() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final repo = ref.read(favoriteRepositoryProvider);

      final favoritesData = await repo.listFavorites(limit: 100);
      
      final spaceIds = <String>{};
      final spaces = <Space>[];

      for (final fav in favoritesData) {
        final spaceId = fav['space_id'] as String?;
        if (spaceId != null) {
          spaceIds.add(spaceId);
        }

        // Parse the space data if included in the response
        final spaceData = fav['space'] as Map<String, dynamic>?;
        if (spaceData != null) {
          try {
            final parsedSpace = Space.fromJson(spaceData);
            if (!spaces.any((s) => s.id == parsedSpace.id)) {
              spaces.add(parsedSpace);
            }
          } catch (_) {
            // Space data might be a summary, skip if it can't be parsed
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        favoriteSpaceIds: spaceIds,
        favoriteSpaces: spaces,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar favoritos',
      );
    }
  }

  /// Toggle favorite status for a space (optimistic UI)
  Future<void> toggleFavorite(String spaceId, {Space? space}) async {
    final wasFavorited = state.isFavorited(spaceId);
    final repo = ref.read(favoriteRepositoryProvider);

    // Optimistic update
    final newIds = Set<String>.from(state.favoriteSpaceIds);
    final newSpaces = List<Space>.from(state.favoriteSpaces);

    if (wasFavorited) {
      newIds.remove(spaceId);
      newSpaces.removeWhere((s) => s.id == spaceId);
    } else {
      newIds.add(spaceId);
      if (space != null && !newSpaces.any((s) => s.id == space.id)) {
        newSpaces.insert(0, space);
      }
    }

    state = state.copyWith(
      favoriteSpaceIds: newIds,
      favoriteSpaces: newSpaces,
    );

    try {
      if (wasFavorited) {
        await repo.removeFavorite(spaceId);
      } else {
        await repo.addFavorite(spaceId);
      }
    } catch (e) {
      // Revert on error
      final revertIds = Set<String>.from(state.favoriteSpaceIds);
      final revertSpaces = List<Space>.from(state.favoriteSpaces);

      if (wasFavorited) {
        revertIds.add(spaceId);
        if (space != null) {
          revertSpaces.insert(0, space);
        }
      } else {
        revertIds.remove(spaceId);
        revertSpaces.removeWhere((s) => s.id == spaceId);
      }

      state = state.copyWith(
        favoriteSpaceIds: revertIds,
        favoriteSpaces: revertSpaces,
        error: 'Erro ao atualizar favorito',
      );
    }
  }
}

/// Provider for favorites state
final favoritesProvider = NotifierProvider<FavoritesNotifier, FavoritesState>(() {
  return FavoritesNotifier();
});
