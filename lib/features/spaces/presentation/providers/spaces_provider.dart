import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:quintou_app/core/services/location_service.dart';

class SpaceFilterState {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final int? minGuests;
  
  // Instant Book
  final bool? requiresApproval; // False = Instant book

  // Estrutura
  final bool? isOutdoor;
  final String? spaceType; // Ex: Cloro, Salgada, Doce
  final String? privacyLevel;
  
  // Regras
  final bool? allowsSmoking;
  final bool? allowsAlcohol;
  final bool? allowsLoudMusic;
  final bool? allowsParties;
  final bool? allowsPets;
  final bool? allowsCommercial;
  
  // Essenciais
  final bool? hasRestroom;
  final bool? hasParking;
  final bool? isAdaFriendly;
  final bool? hasHeatedPool;
  final bool? hasHotTub;

  // Multi-select
  final List<String> amenities;
  final List<String> tags;

  SpaceFilterState({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minGuests,
    this.requiresApproval,
    this.isOutdoor,
    this.spaceType,
    this.privacyLevel,
    this.allowsSmoking,
    this.allowsAlcohol,
    this.allowsLoudMusic,
    this.allowsParties,
    this.allowsPets,
    this.allowsCommercial,
    this.hasRestroom,
    this.hasParking,
    this.isAdaFriendly,
    this.hasHeatedPool,
    this.hasHotTub,
    this.amenities = const [],
    this.tags = const [],
  });

  SpaceFilterState copyWith({
    String? category, double? minPrice, double? maxPrice, int? minGuests,
    bool? requiresApproval, bool? isOutdoor, String? spaceType, String? privacyLevel,
    bool? allowsSmoking, bool? allowsAlcohol, bool? allowsLoudMusic, bool? allowsParties, bool? allowsPets, bool? allowsCommercial,
    bool? hasRestroom, bool? hasParking, bool? isAdaFriendly, bool? hasHeatedPool, bool? hasHotTub,
    List<String>? amenities, List<String>? tags,
  }) {
    return SpaceFilterState(
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minGuests: minGuests ?? this.minGuests,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      isOutdoor: isOutdoor ?? this.isOutdoor,
      spaceType: spaceType ?? this.spaceType,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      allowsSmoking: allowsSmoking ?? this.allowsSmoking,
      allowsAlcohol: allowsAlcohol ?? this.allowsAlcohol,
      allowsLoudMusic: allowsLoudMusic ?? this.allowsLoudMusic,
      allowsParties: allowsParties ?? this.allowsParties,
      allowsPets: allowsPets ?? this.allowsPets,
      allowsCommercial: allowsCommercial ?? this.allowsCommercial,
      hasRestroom: hasRestroom ?? this.hasRestroom,
      hasParking: hasParking ?? this.hasParking,
      isAdaFriendly: isAdaFriendly ?? this.isAdaFriendly,
      hasHeatedPool: hasHeatedPool ?? this.hasHeatedPool,
      hasHotTub: hasHotTub ?? this.hasHotTub,
      amenities: amenities ?? this.amenities,
      tags: tags ?? this.tags,
    );
  }
}

class SpaceFilterNotifier extends Notifier<SpaceFilterState> {
  @override
  SpaceFilterState build() => SpaceFilterState();

  void updateFilters(SpaceFilterState newState) {
    state = newState;
  }
  
  void setCategory(String? cat) {
    state = state.copyWith(category: cat);
  }
  
  void clearFilters() {
    state = SpaceFilterState(category: state.category); // Keep category
  }
}

final spaceFilterProvider = NotifierProvider<SpaceFilterNotifier, SpaceFilterState>(() {
  return SpaceFilterNotifier();
});

final spacesProvider = FutureProvider<List<Space>>((ref) async {
  final filters = ref.watch(spaceFilterProvider);
  final repository = ref.watch(spaceRepositoryProvider);
  final locationService = LocationService();
  
  final position = await locationService.getCurrentLocation();
  
  return repository.getSpaces(
    lat: position?.latitude,
    lng: position?.longitude,
    radius: position != null ? 50.0 : null,
    category: filters.category,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
    minGuests: filters.minGuests,
    allowsSmoking: filters.allowsSmoking,
    allowsAlcohol: filters.allowsAlcohol,
    allowsLoudMusic: filters.allowsLoudMusic,
    allowsParties: filters.allowsParties,
    hasRestroom: filters.hasRestroom,
    hasParking: filters.hasParking,
    isOutdoor: filters.isOutdoor,
    isAdaFriendly: filters.isAdaFriendly,
    hasHeatedPool: filters.hasHeatedPool,
    hasHotTub: filters.hasHotTub,
    allowsCommercial: filters.allowsCommercial,
    spaceType: filters.spaceType,
    amenities: filters.amenities,
    // (Ainda faltam tags, mas o backend não tem suporte nativo para query params de tags list, amenities é suficiente por enquanto)
  );
});
