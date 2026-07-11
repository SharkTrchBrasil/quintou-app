import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quintou_app/core/providers/providers.dart';

class CreateSpaceState {
  // Passo 1
  final String listingType; // "SPACE" ou "EQUIPMENT"
  final String category;
  final String title;
  final String description;

  // Passo 2
  final String zipCode;
  final String addressLine;
  final String city;
  final String state;
  final String neighborhood;

  // Passo 3
  final int maxGuests;
  final bool isOutdoor;

  // Passo 4
  final double price;
  final String pricingMode; // "PER_HOUR"
  final bool allowsParties;
  final bool allowsSmoking;
  final bool allowsPets;
  final bool allowsChildren;

  // Passo 5
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
    this.price = 50.0,
    this.pricingMode = 'PER_HOUR',
    this.allowsParties = false,
    this.allowsSmoking = false,
    this.allowsPets = false,
    this.allowsChildren = true,
    this.images = const [],
    this.isLoading = false,
    this.error,
  });

  CreateSpaceState copyWith({
    String? listingType,
    String? category,
    String? title,
    String? description,
    String? zipCode,
    String? addressLine,
    String? city,
    String? state,
    String? neighborhood,
    int? maxGuests,
    bool? isOutdoor,
    double? price,
    String? pricingMode,
    bool? allowsParties,
    bool? allowsSmoking,
    bool? allowsPets,
    bool? allowsChildren,
    List<XFile>? images,
    bool? isLoading,
    String? error,
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
      price: price ?? this.price,
      pricingMode: pricingMode ?? this.pricingMode,
      allowsParties: allowsParties ?? this.allowsParties,
      allowsSmoking: allowsSmoking ?? this.allowsSmoking,
      allowsPets: allowsPets ?? this.allowsPets,
      allowsChildren: allowsChildren ?? this.allowsChildren,
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
    String? listingType,
    String? category,
    String? title,
    String? description,
    String? zipCode,
    String? addressLine,
    String? city,
    String? state,
    String? neighborhood,
    int? maxGuests,
    bool? isOutdoor,
    double? price,
    bool? allowsParties,
    bool? allowsSmoking,
    bool? allowsPets,
    bool? allowsChildren,
  }) {
    state = state.copyWith(
      listingType: listingType,
      category: category,
      title: title,
      description: description,
      zipCode: zipCode,
      addressLine: addressLine,
      city: city,
      state: state,
      neighborhood: neighborhood,
      maxGuests: maxGuests,
      isOutdoor: isOutdoor,
      price: price,
      allowsParties: allowsParties,
      allowsSmoking: allowsSmoking,
      allowsPets: allowsPets,
      allowsChildren: allowsChildren,
    );
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
      // 1. Criar Espaço
      final payload = {
        "listing_type": state.listingType,
        "title": state.title,
        "description": state.description,
        "category": state.category,
        "address_line": state.addressLine,
        "city": state.city,
        "state": state.state,
        "zip_code": state.zipCode,
        "neighborhood": state.neighborhood,
        "pricing_mode": state.pricingMode,
        "price": state.price,
        "price_per_hour": state.price,
        "is_outdoor": state.isOutdoor,
        "allows_parties": state.allowsParties,
        "allows_smoking": state.allowsSmoking,
        "allows_pets": state.allowsPets,
        "allows_children": state.allowsChildren,
        "max_guests": state.maxGuests,
      };

      final response = await _dio.post('/spaces', data: payload);
      final spaceId = response.data['id'];

      // 2. Upload de Imagens
      for (int i = 0; i < state.images.length; i++) {
        final file = state.images[i];
        FormData formData = FormData.fromMap({
          "file": await MultipartFile.fromFile(file.path, filename: file.name),
          "is_cover": i == 0, // A primeira foto é a capa
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
  return CreateSpaceNotifier(ref.read(dioProvider));
});
