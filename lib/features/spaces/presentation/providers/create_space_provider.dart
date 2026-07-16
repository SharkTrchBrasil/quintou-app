import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quintou_app/core/providers/providers.dart';

class AvailabilityRule {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  AvailabilityRule({required this.dayOfWeek, required this.startTime, required this.endTime});
  
  Map<String, dynamic> toJson() => {
    "day_of_week": dayOfWeek,
    "start_time": startTime,
    "end_time": endTime,
    "is_available": true
  };
}


class CreateSpaceState {
  // Step 0: Categoria
  final String? categoryId;
  final String? categorySlug;
  final String listingType;

  // Step 1: Titulo e Descrição
  final String title;
  final String description;

  // Step 2: Localização / Entrega
  final String zipCode;
  final String addressLine;
  final String city;
  final String state;
  final String neighborhood;
  final String referencePoint;
  
  final bool deliveryAvailable;
  final double deliveryFee;
  final int deliveryRadiusKm;
  final String deliveryDescription;

  // Step 3: Capacidade
  final int maxGuests;
  final bool isOutdoor;
  final String spaceType;
  final double sizeLength;
  final double sizeWidth;
  final String privacyLevel;

  // Step 4: Regras
  final bool allowsParties;
  final bool allowsSmoking;
  final bool allowsPets;
  final bool allowsChildren;
  final bool allowsAlcohol;
  final bool allowsLoudMusic;
  final bool allowsCommercial;
  
  // SERVICE fields
  final String serviceAreaDescription;
  final int yearsExperience;
  final String portfolioUrl;
  
  // VEHICLE fields
  final String vehicleMake;
  final String vehicleModel;
  final int vehicleYear;
  final double vehicleLengthFt;
  final int engineHp;
  final bool hasCaptain;
  final bool requiresLicense;
  final String embarkLocation;

  // Step 5: Comodidades
  final List<String> amenities;
  final List<String> tags;
  final bool hasRestroom;
  final bool hasParking;
  final bool isAdaFriendly;
  final bool hasHeatedPool;
  final bool hasHotTub;

  // Step 6: Imagens
  final List<XFile> images;

  // Step 7: Disponibilidade
  final List<AvailabilityRule> availabilityRules;
  final int minHours;
  final int maxHours;

  // Step 8: Preço
  final double price;
  final String pricingMode;
  final String cancellationPolicy;
  final bool requiresApproval;
  final double securityDeposit;

  final bool isLoading;
  final String? error;

  CreateSpaceState({
    this.categoryId,
    this.categorySlug,
    this.listingType = 'SPACE',
    this.title = '',
    this.description = '',
    
    this.zipCode = '',
    this.addressLine = '',
    this.city = '',
    this.state = '',
    this.neighborhood = '',
    this.referencePoint = '',
    this.deliveryAvailable = false,
    this.deliveryFee = 0.0,
    this.deliveryRadiusKm = 10,
    this.deliveryDescription = '',
    
    this.maxGuests = 10,
    this.isOutdoor = true,
    this.spaceType = 'Cloro',
    this.sizeLength = 0.0,
    this.sizeWidth = 0.0,
    this.privacyLevel = 'Standard',
    
    this.allowsParties = false,
    this.allowsSmoking = false,
    this.allowsPets = false,
    this.allowsChildren = false,
    this.allowsAlcohol = false,
    this.allowsLoudMusic = false,
    this.allowsCommercial = false,
    
    this.amenities = const [],
    this.tags = const [],
    this.hasRestroom = false,
    this.hasParking = false,
    this.isAdaFriendly = false,
    this.hasHeatedPool = false,
    this.hasHotTub = false,
    
    this.serviceAreaDescription = '',
    this.yearsExperience = 0,
    this.portfolioUrl = '',
    
    this.vehicleMake = '',
    this.vehicleModel = '',
    this.vehicleYear = 2020,
    this.vehicleLengthFt = 0.0,
    this.engineHp = 0,
    this.hasCaptain = false,
    this.requiresLicense = false,
    this.embarkLocation = '',
    
    this.images = const [],
    
    this.availabilityRules = const [],
    this.minHours = 2,
    this.maxHours = 12,
    
    this.price = 50.0,
    this.pricingMode = 'PER_HOUR',
    this.cancellationPolicy = 'FLEXIVEL',
    this.requiresApproval = true,
    this.securityDeposit = 0.0,
    
    this.isLoading = false,
    this.error,
  });

  CreateSpaceState copyWith({
    String? categoryId, String? categorySlug, String? listingType,
    String? title, String? description,
    String? zipCode, String? addressLine, String? city, String? state, String? neighborhood, String? referencePoint,
    bool? deliveryAvailable, double? deliveryFee, int? deliveryRadiusKm, String? deliveryDescription,
    int? maxGuests, bool? isOutdoor, String? spaceType, double? sizeLength, double? sizeWidth, String? privacyLevel,
    bool? allowsParties, bool? allowsSmoking, bool? allowsPets, bool? allowsChildren, bool? allowsAlcohol, bool? allowsLoudMusic, bool? allowsCommercial,
    String? serviceAreaDescription, int? yearsExperience, String? portfolioUrl,
    String? vehicleMake, String? vehicleModel, int? vehicleYear, double? vehicleLengthFt, int? engineHp, bool? hasCaptain, bool? requiresLicense, String? embarkLocation,
    List<String>? amenities, List<String>? tags, bool? hasRestroom, bool? hasParking, bool? isAdaFriendly, bool? hasHeatedPool, bool? hasHotTub,
    List<XFile>? images,
    List<AvailabilityRule>? availabilityRules, int? minHours, int? maxHours,
    double? price, String? pricingMode, String? cancellationPolicy, bool? requiresApproval, double? securityDeposit,
    bool? isLoading, String? error,
  }) {
    return CreateSpaceState(
      categoryId: categoryId ?? this.categoryId,
      categorySlug: categorySlug ?? this.categorySlug,
      listingType: listingType ?? this.listingType,
      title: title ?? this.title,
      description: description ?? this.description,
      zipCode: zipCode ?? this.zipCode,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      state: state ?? this.state,
      neighborhood: neighborhood ?? this.neighborhood,
      referencePoint: referencePoint ?? this.referencePoint,
      deliveryAvailable: deliveryAvailable ?? this.deliveryAvailable,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
      deliveryDescription: deliveryDescription ?? this.deliveryDescription,
      maxGuests: maxGuests ?? this.maxGuests,
      isOutdoor: isOutdoor ?? this.isOutdoor,
      spaceType: spaceType ?? this.spaceType,
      sizeLength: sizeLength ?? this.sizeLength,
      sizeWidth: sizeWidth ?? this.sizeWidth,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      allowsParties: allowsParties ?? this.allowsParties,
      allowsSmoking: allowsSmoking ?? this.allowsSmoking,
      allowsPets: allowsPets ?? this.allowsPets,
      allowsChildren: allowsChildren ?? this.allowsChildren,
      allowsAlcohol: allowsAlcohol ?? this.allowsAlcohol,
      allowsLoudMusic: allowsLoudMusic ?? this.allowsLoudMusic,
      allowsCommercial: allowsCommercial ?? this.allowsCommercial,
      serviceAreaDescription: serviceAreaDescription ?? this.serviceAreaDescription,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleLengthFt: vehicleLengthFt ?? this.vehicleLengthFt,
      engineHp: engineHp ?? this.engineHp,
      hasCaptain: hasCaptain ?? this.hasCaptain,
      requiresLicense: requiresLicense ?? this.requiresLicense,
      embarkLocation: embarkLocation ?? this.embarkLocation,
      amenities: amenities ?? this.amenities,
      tags: tags ?? this.tags,
      hasRestroom: hasRestroom ?? this.hasRestroom,
      hasParking: hasParking ?? this.hasParking,
      isAdaFriendly: isAdaFriendly ?? this.isAdaFriendly,
      hasHeatedPool: hasHeatedPool ?? this.hasHeatedPool,
      hasHotTub: hasHotTub ?? this.hasHotTub,
      images: images ?? this.images,
      availabilityRules: availabilityRules ?? this.availabilityRules,
      minHours: minHours ?? this.minHours,
      maxHours: maxHours ?? this.maxHours,
      price: price ?? this.price,
      pricingMode: pricingMode ?? this.pricingMode,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CreateSpaceNotifier extends Notifier<CreateSpaceState> {
  @override
  CreateSpaceState build() {
    return CreateSpaceState();
  }
  
  Dio get _dio => ref.read(apiClientProvider).dio;

  void updateField({
    String? categoryId, String? listingType,
    String? title, String? description,
    String? zipCode, String? addressLine, String? city, String? stateValue, String? neighborhood, String? referencePoint,
    bool? deliveryAvailable, double? deliveryFee, int? deliveryRadiusKm, String? deliveryDescription,
    int? maxGuests, bool? isOutdoor, String? spaceType, double? sizeLength, double? sizeWidth, String? privacyLevel,
    bool? allowsParties, bool? allowsSmoking, bool? allowsPets, bool? allowsChildren, bool? allowsAlcohol, bool? allowsLoudMusic, bool? allowsCommercial,
    List<String>? amenities, List<String>? tags, bool? hasRestroom, bool? hasParking, bool? isAdaFriendly, bool? hasHeatedPool, bool? hasHotTub,
    List<AvailabilityRule>? availabilityRules, int? minHours, int? maxHours,
    double? price, String? pricingMode, String? cancellationPolicy, bool? requiresApproval, double? securityDeposit,
  }) {
    this.state = this.state.copyWith(
      categoryId: categoryId, listingType: listingType,
      title: title, description: description,
      zipCode: zipCode, addressLine: addressLine, city: city, state: stateValue, neighborhood: neighborhood, referencePoint: referencePoint,
      deliveryAvailable: deliveryAvailable, deliveryFee: deliveryFee, deliveryRadiusKm: deliveryRadiusKm, deliveryDescription: deliveryDescription,
      maxGuests: maxGuests, isOutdoor: isOutdoor, spaceType: spaceType, sizeLength: sizeLength, sizeWidth: sizeWidth, privacyLevel: privacyLevel,
      allowsParties: allowsParties, allowsSmoking: allowsSmoking, allowsPets: allowsPets, allowsChildren: allowsChildren, allowsAlcohol: allowsAlcohol, allowsLoudMusic: allowsLoudMusic, allowsCommercial: allowsCommercial,
      amenities: amenities, tags: tags, hasRestroom: hasRestroom, hasParking: hasParking, isAdaFriendly: isAdaFriendly, hasHeatedPool: hasHeatedPool, hasHotTub: hasHotTub,
      availabilityRules: availabilityRules, minHours: minHours, maxHours: maxHours,
      price: price, pricingMode: pricingMode, cancellationPolicy: cancellationPolicy, requiresApproval: requiresApproval, securityDeposit: securityDeposit,
    );
  }

  void updateServiceVehicleFields({
    String? categorySlug,
    String? serviceAreaDescription, int? yearsExperience, String? portfolioUrl,
    String? vehicleMake, String? vehicleModel, int? vehicleYear, double? vehicleLengthFt, int? engineHp, bool? hasCaptain, bool? requiresLicense, String? embarkLocation,
  }) {
    this.state = this.state.copyWith(
      categorySlug: categorySlug,
      serviceAreaDescription: serviceAreaDescription ?? this.state.serviceAreaDescription,
      yearsExperience: yearsExperience ?? this.state.yearsExperience,
      portfolioUrl: portfolioUrl ?? this.state.portfolioUrl,
      vehicleMake: vehicleMake ?? this.state.vehicleMake,
      vehicleModel: vehicleModel ?? this.state.vehicleModel,
      vehicleYear: vehicleYear ?? this.state.vehicleYear,
      vehicleLengthFt: vehicleLengthFt ?? this.state.vehicleLengthFt,
      engineHp: engineHp ?? this.state.engineHp,
      hasCaptain: hasCaptain ?? this.state.hasCaptain,
      requiresLicense: requiresLicense ?? this.state.requiresLicense,
      embarkLocation: embarkLocation ?? this.state.embarkLocation,
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
  
  void setAvailabilityRules(List<AvailabilityRule> rules) {
    state = state.copyWith(availabilityRules: rules);
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
    if (state.categoryId == null) {
      state = state.copyWith(error: "Selecione uma categoria");
      return false;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = {
        "listing_type": state.listingType,
        "title": state.title,
        "description": state.description,
        "category_id": state.categoryId,
        "address_line": state.addressLine,
        "city": state.city,
        "state": state.state,
        "zip_code": state.zipCode,
        "neighborhood": state.neighborhood,
        "reference_point": state.referencePoint,
        
        "delivery_available": state.deliveryAvailable,
        "delivery_fee": state.deliveryFee,
        "delivery_radius_km": state.deliveryRadiusKm,
        "delivery_description": state.deliveryDescription,
        
        "pricing_mode": state.pricingMode,
        "price": state.price,
        "price_per_hour": state.price,
        "security_deposit": state.securityDeposit,
        
        "max_guests": state.maxGuests,
        "is_outdoor": state.isOutdoor,
        "space_type": state.spaceType,
        "size_length": state.sizeLength,
        "size_width": state.sizeWidth,
        "privacy_level": state.privacyLevel,
        
        "amenities": state.amenities,
        "tags": state.tags,
        "has_restroom": state.hasRestroom,
        "has_parking": state.hasParking,
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
        
        "service_area_description": state.serviceAreaDescription,
        "years_experience": state.yearsExperience,
        "portfolio_url": state.portfolioUrl,
        
        "vehicle_make": state.vehicleMake,
        "vehicle_model": state.vehicleModel,
        "vehicle_year": state.vehicleYear,
        "vehicle_length_ft": state.vehicleLengthFt,
        "engine_hp": state.engineHp,
        "has_captain": state.hasCaptain,
        "requires_license": state.requiresLicense,
        "embark_location": state.embarkLocation,
        
        "cancellation_policy": state.cancellationPolicy,
        "requires_approval": state.requiresApproval,
        "min_hours": state.minHours,
        "max_hours": state.maxHours,
        "availability_rules": state.availabilityRules.map((r) => r.toJson()).toList(),
      };

      final response = await _dio.post('/spaces', data: payload);
      final spaceId = response.data['id'];

      // Upload real das imagens para o S3 via multipart
      if (state.images.isNotEmpty) {
        final formData = FormData();
        for (int i = 0; i < state.images.length; i++) {
          final file = state.images[i];
          formData.files.add(MapEntry(
            'images',
            await MultipartFile.fromFile(
              file.path,
              filename: file.name,
            ),
          ));
        }

        try {
          await _dio.post(
            '/upload/spaces/$spaceId/media',
            data: formData,
            options: Options(
              headers: {'Content-Type': 'multipart/form-data'},
            ),
          );
        } catch (e) {
          // Se o upload falhar, não impede a criação do espaço
          // As imagens podem ser adicionadas depois
          print('Erro no upload de imagens: $e');
        }
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

final createSpaceProvider = NotifierProvider<CreateSpaceNotifier, CreateSpaceState>(() {
  return CreateSpaceNotifier();
});
