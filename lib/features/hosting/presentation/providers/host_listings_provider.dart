import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/core/providers/providers.dart';

final hostListingsProvider = FutureProvider.autoDispose<List<Space>>((ref) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return repository.getMyListings();
});
