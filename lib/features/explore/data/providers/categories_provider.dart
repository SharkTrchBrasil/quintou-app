import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/providers/providers.dart';

class Category {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String listingType;
  final String? parentGroup;
  final String? description;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.listingType,
    this.parentGroup,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String,
      listingType: json['listingType'] as String? ?? 'SPACE',
      parentGroup: json['parentGroup'] as String?,
      description: json['description'] as String?,
    );
  }
}

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.dio.get('/categories');
    final List<dynamic> data = response.data;
    final allCategories = data.map((json) => Category.fromJson(json)).toList();
    
    final uniqueCategories = <String, Category>{};
    for (var cat in allCategories) {
      if (!uniqueCategories.containsKey(cat.name)) {
        uniqueCategories[cat.name] = cat;
      }
    }
    return uniqueCategories.values.toList();
  } catch (e) {
    throw Exception('Failed to load categories: \$e');
  }
});

class CurrentCityNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setCity(String? city) => state = city;
}

final currentCityProvider = NotifierProvider<CurrentCityNotifier, String?>(() {
  return CurrentCityNotifier();
});

final homeCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final city = ref.watch(currentCityProvider);
  
  try {
    final Map<String, dynamic> queryParams = {'active_only': 'true'};
    if (city != null) {
      queryParams['city'] = city;
    }
    
    final response = await apiClient.dio.get('/categories', queryParameters: queryParams);
    final List<dynamic> data = response.data;
    final allCategories = data.map((json) => Category.fromJson(json)).toList();
    
    final uniqueCategories = <String, Category>{};
    for (var cat in allCategories) {
      if (!uniqueCategories.containsKey(cat.name)) {
        uniqueCategories[cat.name] = cat;
      }
    }
    return uniqueCategories.values.toList();
  } catch (e) {
    throw Exception('Failed to load home categories: $e');
  }
});
