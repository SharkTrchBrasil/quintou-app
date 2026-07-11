import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quintou_app/core/providers/providers.dart';

class CreateSpaceState {
  // Passo 1: O que
  final String listingType;
  final String category;
  final String title;
  final String description;

  // Passo 2: Onde
  final String zipCode;
  final String addressLine;
  final String city;
  final String state;
  final String neighborhood;

  // Passo 3: Detalhes
  final int maxGuests;
  final bool isOutdoor;
  final String spaceType;
  final double sizeLength;
  final double sizeWidth;
  final String privacyLevel;
  final String checkInType;

  // Passo 4: Comodidades & Extras
  final List<String> amenities;
  final List<String> tags;
  final bool hasRestroom;
  final bool hasParking;
  final int parkingCapacity;
  final bool isAdaFriendly;
  final bool hasHeatedPool;
  final bool hasHotTub;

  // Passo 5: Regras
  final bool allowsParties;
  final bool allowsSmoking;
  final bool allowsPets;
  final bool allowsChildren;
  final bool allowsAlcohol;
  final bool allowsLoudMusic;
  final bool allowsCommercial;

  // Passo 6: Preço
  final double price;
  final String pricingMode;
  final int weekdayDiscountPercent;
  final String cancellationPolicy;
  final bool requiresApproval;

  // Passo 8: Imagens
  final List<XFile> images;

  final bool isLoading;
  final String? error;

  CreateSpaceState({
    this.listingType = 'SPACE',
    this.category = 'PISCINA',
    this.title = '',
    this.description = '',
    this.zipCode = '',
    this.addressLine = '',
    this.city = '',
    this.state = '',
    this.neighborhood = '',
    this.maxGuests = 10,
    this.isOutdoor = true,
    this.spaceType = 'Cloro',
    this.sizeLength = 0,
    this.sizeWidth = 0,
    this.privacyLevel = 'Standard',
    this.checkInType = 'Meet host',
    this.amenities = const [],
    this.tags = const [],
    this.hasRestroom = false,
    this.hasParking = false,
    this.parkingCapacity = 0,
    this.isAdaFriendly = false,
    this.hasHeatedPool = false,
    this.hasHotTub = false,
    this.allowsParties = false,
    this.allowsSmoking = false,
    this.allowsPets = false,
    this.allowsChildren = true,
    this.allowsAlcohol = false,
    this.allowsLoudMusic = false,
    this.allowsCommercial = false,
    this.price = 50.0,
    this.pricingMode = 'PER_HOUR',
    this.weekdayDiscountPercent = 0,
    this.cancellationPolicy = 'FLEXIVEL',
    this.requiresApproval = true,
    this.images = const [],
    this.isLoading = false,
    this.error,
  });

  CreateSpaceState copyWith({
    String? listingType, String? category, String? title, String? description,
    String? zipCode, String? addressLine, String? city, String? state, String? neighborhood,
    int? maxGuests, bool? isOutdoor, String? spaceType, double? sizeLength, double? sizeWidth, String? privacyLevel, String? checkInType,
    List<String>? amenities, List<String>? tags, bool? hasRestroom, bool? hasParking, int? parkingCapacity, bool? isAdaFriendly, bool? hasHeatedPool, bool? hasHotTub,
    bool? allowsParties, bool? allowsSmoking, bool? allowsPets, bool? allowsChildren, bool? allowsAlcohol, bool? allowsLoudMusic, bool? allowsCommercial,
    double? price, String? pricingMode, int? weekdayDiscountPercent, String? cancellationPolicy, bool? requiresApproval,
    List<XFile>? images, bool? isLoading, String? error,
  }) {
    return CreateSpaceState(
      listingType: listingType ?? this.listingType,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      zipCode: zipCode ?? this.zipCode,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      state: state ?? this.state,
      neighborhood: neighborhood ?? this.neighborhood,
      maxGuests: maxGuests ?? this.maxGuests,
      isOutdoor: isOutdoor ?? this.isOutdoor,
      spaceType: spaceType ?? this.spaceType,
      sizeLength: sizeLength ?? this.sizeLength,
      sizeWidth: sizeWidth ?? this.sizeWidth,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      checkInType: checkInType ?? this.checkInType,
      amenities: amenities ?? this.amenities,
      tags: tags ?? this.tags,
      hasRestroom: hasRestroom ?? this.hasRestroom,
      hasParking: hasParking ?? this.hasParking,
      parkingCapacity: parkingCapacity ?? this.parkingCapacity,
      isAdaFriendly: isAdaFriendly ?? this.isAdaFriendly,
      hasHeatedPool: hasHeatedPool ?? this.hasHeatedPool,
      hasHotTub: hasHotTub ?? this.hasHotTub,
      allowsParties: allowsParties ?? this.allowsParties,
      allowsSmoking: allowsSmoking ?? this.allowsSmoking,
      allowsPets: allowsPets ?? this.allowsPets,
      allowsChildren: allowsChildren ?? this.allowsChildren,
      allowsAlcohol: allowsAlcohol ?? this.allowsAlcohol,
      allowsLoudMusic: allowsLoudMusic ?? this.allowsLoudMusic,
      allowsCommercial: allowsCommercial ?? this.allowsCommercial,
      price: price ?? this.price,
      pricingMode: pricingMode ?? this.pricingMode,
      weekdayDiscountPercent: weekdayDiscountPercent ?? this.weekdayDiscountPercent,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CreateSpaceNotifier extends StateNotifier<CreateSpaceState> {
  final Dio _dio;

  CreateSpaceNotifier(this._dio) : super(CreateSpaceState());

  void updateField({
    String? listingType, String? category, String? title, String? description,
    String? zipCode, String? addressLine, String? city, String? state, String? neighborhood,
    int? maxGuests, bool? isOutdoor, String? spaceType, double? sizeLength, double? sizeWidth, String? privacyLevel, String? checkInType,
    List<String>? amenities, List<String>? tags, bool? hasRestroom, bool? hasParking, int? parkingCapacity, bool? isAdaFriendly, bool? hasHeatedPool, bool? hasHotTub,
    bool? allowsParties, bool? allowsSmoking, bool? allowsPets, bool? allowsChildren, bool? allowsAlcohol, bool? allowsLoudMusic, bool? allowsCommercial,
    double? price, String? pricingMode, int? weekdayDiscountPercent, String? cancellationPolicy, bool? requiresApproval,
  }) {
    state = state.copyWith(
      listingType: listingType, category: category, title: title, description: description,
      zipCode: zipCode, addressLine: addressLine, city: city, state: state, neighborhood: neighborhood,
      maxGuests: maxGuests, isOutdoor: isOutdoor, spaceType: spaceType, sizeLength: sizeLength, sizeWidth: sizeWidth, privacyLevel: privacyLevel, checkInType: checkInType,
      amenities: amenities, tags: tags, hasRestroom: hasRestroom, hasParking: hasParking, parkingCapacity: parkingCapacity, isAdaFriendly: isAdaFriendly, hasHeatedPool: hasHeatedPool, hasHotTub: hasHotTub,
      allowsParties: allowsParties, allowsSmoking: allowsSmoking, allowsPets: allowsPets, allowsChildren: allowsChildren, allowsAlcohol: allowsAlcohol, allowsLoudMusic: allowsLoudMusic, allowsCommercial: allowsCommercial,
      price: price, pricingMode: pricingMode, weekdayDiscountPercent: weekdayDiscountPercent, cancellationPolicy: cancellationPolicy, requiresApproval: requiresApproval,
    );
  }

  void toggleAmenity(String amenity) {
    final list = List<String>.from(state.amenities);
    if (list.contains(amenity)) list.remove(amenity);
    else list.add(amenity);
    state = state.copyWith(amenities: list);
  }

  void toggleTag(String tag) {
    final list = List<String>.from(state.tags);
    if (list.contains(tag)) list.remove(tag);
    else list.add(tag);
    state = state.copyWith(tags: list);
  }

  void addImages(List<XFile> newImages) {
    state = state.copyWith(images: [...state.images, ...newImages]);
  }

  void removeImage(int index) {
    final images = List<XFile>.from(state.images);
    images.removeAt(index);
    state = state.copyWith(images: images);
  }

  Future<void> fetchAddressFromCep(String cep) async {
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanCep.length == 8) {
      state = state.copyWith(isLoading: true, error: null);
      try {
        final response = await Dio().get('https://viacep.com.br/ws/$cleanCep/json/');
        if (response.data['erro'] != true) {
          state = state.copyWith(
            addressLine: response.data['logradouro'],
            neighborhood: response.data['bairro'],
            city: response.data['localidade'],
            state: response.data['uf'],
            isLoading: false,
          );
        } else {
          state = state.copyWith(isLoading: false, error: "CEP não encontrado");
        }
      } catch (e) {
        state = state.copyWith(isLoading: false, error: "Erro ao buscar CEP");
      }
    }
  }

  Future<bool> submit() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = {
        "listing_type": state.listingType,
        "title": state.title,
        "description": state.description,
        "category_id": "00000000-0000-0000-0000-000000000000", // Categoria temporária
        "address_line": state.addressLine,
        "city": state.city,
        "state": state.state,
        "zip_code": state.zipCode,
        "neighborhood": state.neighborhood,
        "pricing_mode": state.pricingMode,
        "price": state.price,
        "price_per_hour": state.price,
        
        "max_guests": state.maxGuests,
        "is_outdoor": state.isOutdoor,
        "space_type": state.spaceType,
        "size_length": state.sizeLength,
        "size_width": state.sizeWidth,
        "privacy_level": state.privacyLevel,
        "check_in_type": state.checkInType,
        
        "amenities": state.amenities,
        "tags": state.tags,
        "has_restroom": state.hasRestroom,
        "has_parking": state.hasParking,
        "parking_capacity": state.parkingCapacity,
        "is_ada_friendly": state.isAdaFriendly,
        "has_heated_pool": state.hasHeatedPool,
        "has_hot_tub": state.hasHotTub,
        
        "allows_parties": state.allowsParties,
        "allows_smoking": state.allowsSmoking,
        "allows_pets": state.allowsPets,
        "allows_children": state.allowsChildren,
        "allows_alcohol": state.allowsAlcohol,
        "allows_loud_music": state.allowsLoudMusic,
        "allows_commercial": state.allowsCommercial,
        
        "weekday_discount_percent": state.weekdayDiscountPercent,
        "cancellation_policy": state.cancellationPolicy,
        "requires_approval": state.requiresApproval,
      };

      final response = await _dio.post('/spaces', data: payload);
      final spaceId = response.data['id'];

      for (int i = 0; i < state.images.length; i++) {
        final file = state.images[i];
        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path, filename: file.name),
          "is_cover": i == 0,
          "order": i,
        });
        await _dio.post('/spaces/$spaceId/images', data: formData);
      }

      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data?['detail']?.toString() ?? 'Erro ao publicar espaço',
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Erro inesperado: $e');
      return false;
    }
  }
}

final createSpaceProvider = StateNotifierProvider<CreateSpaceNotifier, CreateSpaceState>((ref) {
  return CreateSpaceNotifier(ref.read(apiClientProvider).dio);
});
