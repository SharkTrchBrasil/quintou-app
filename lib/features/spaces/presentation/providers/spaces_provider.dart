import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:quintou_app/core/services/location_service.dart';

final spacesProvider = FutureProvider<List<Space>>((ref) async {
  final repository = ref.watch(spaceRepositoryProvider);
  final locationService = LocationService();
  
  final position = await locationService.getCurrentLocation();
  
  if (position != null) {
    return repository.getSpaces(lat: position.latitude, lng: position.longitude, radius: 50.0);
  }
  
  // If permission denied or services disabled, fetch without location
  return repository.getSpaces();
});

class CategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setCategory(String? category) => state = category;
}

final categoryFilterProvider = NotifierProvider<CategoryFilterNotifier, String?>(() {
  return CategoryFilterNotifier();
});

final filteredSpacesProvider = FutureProvider<List<Space>>((ref) async {
  final category = ref.watch(categoryFilterProvider);
  final repository = ref.watch(spaceRepositoryProvider);
  
  return repository.getSpaces(category: category);
});
