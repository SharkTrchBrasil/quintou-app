import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:quintou_app/core/repositories/space_repository.dart';
import 'dart:async';

class SearchAutocompleteNotifier extends Notifier<AsyncValue<List<Map<String, dynamic>>>> {
  Timer? _debounce;

  @override
  AsyncValue<List<Map<String, dynamic>>> build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return const AsyncValue.data([]);
  }

  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final repository = ref.read(spaceRepositoryProvider);
        final results = await repository.autocompleteSpaces(query);
        state = AsyncValue.data(results);
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    });
  }
}

final searchAutocompleteProvider = NotifierProvider<SearchAutocompleteNotifier, AsyncValue<List<Map<String, dynamic>>>>(() {
  return SearchAutocompleteNotifier();
});
