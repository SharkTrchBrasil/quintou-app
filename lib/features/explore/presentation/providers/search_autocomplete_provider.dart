import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:quintou_app/core/repositories/space_repository.dart';
import 'dart:async';

class SearchAutocompleteNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final SpaceRepository _repository;
  Timer? _debounce;

  SearchAutocompleteNotifier(this._repository) : super(const AsyncValue.data([]));

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await _repository.autocompleteSpaces(query);
        if (mounted) {
          state = AsyncValue.data(results);
        }
      } catch (e, st) {
        if (mounted) {
          state = AsyncValue.error(e, st);
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final searchAutocompleteProvider = StateNotifierProvider<SearchAutocompleteNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final repository = ref.watch(spaceRepositoryProvider);
  return SearchAutocompleteNotifier(repository);
});
