import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/core/providers/providers.dart';

class Category {
  final String id;
  final String name;
  final String slug;
  final String icon;
  final String listingType;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.listingType,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String,
      listingType: json['listingType'] as String,
    );
  }
}

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.dio.get('/categories');
    final List<dynamic> data = response.data;
    return data.map((json) => Category.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Failed to load categories: \$e');
  }
});
