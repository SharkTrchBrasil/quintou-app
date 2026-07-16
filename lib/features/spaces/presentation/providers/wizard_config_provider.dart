import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/providers/providers.dart';

class WizardConfigModel {
  final Map<String, dynamic> steps;
  final Map<String, dynamic> labels;
  final List<Map<String, dynamic>> amenities;
  final String categoryName;

  WizardConfigModel({
    required this.steps,
    required this.labels,
    required this.amenities,
    required this.categoryName,
  });

  factory WizardConfigModel.fromJson(Map<String, dynamic> json) {
    return WizardConfigModel(
      steps: json['steps'] != null ? Map<String, dynamic>.from(json['steps']) : {},
      labels: json['labels'] != null ? Map<String, dynamic>.from(json['labels']) : {},
      amenities: json['amenities'] != null
          ? (json['amenities'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList()
          : [],
      categoryName: json['category']?['name']?.toString() ?? '',
    );
  }
}

final wizardConfigProvider = FutureProvider.family<WizardConfigModel, String>((ref, slug) async {
  final dio = ref.read(apiClientProvider).dio;
  final response = await dio.get('/categories/$slug/wizard-config');
  return WizardConfigModel.fromJson(response.data);
});
