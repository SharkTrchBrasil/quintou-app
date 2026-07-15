import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/features/explore/data/providers/categories_provider.dart';
import 'package:quintou_app/features/spaces/presentation/providers/spaces_provider.dart';
import 'package:quintou_app/features/spaces/presentation/widgets/space_grid_card.dart';
import 'package:quintou_app/core/shell/app_shell.dart';
import 'package:quintou_app/features/explore/presentation/screens/search_screen.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/core/providers/notification_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _currentLocation = 'Buscando...';
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _currentLocation = 'Localização desativada';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _currentLocation = 'Sem permissão';
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _currentLocation = 'Permissão negada';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        if (mounted) {
          setState(() {
            _currentLocation = '${place.subAdministrativeArea ?? place.locality ?? 'Sua Localização'}, ${place.administrativeArea ?? ''}';
            _isLoadingLocation = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentLocation = 'Localização não encontrada';
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocation = 'Erro ao buscar local';
          _isLoadingLocation = false;
        });
      }
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'pool': return Icons.pool;
      case 'nature_people': return Icons.nature_people;
      case 'celebration': return Icons.celebration;
      case 'sports_tennis': return Icons.sports_tennis;
      case 'camera_alt': return Icons.camera_alt;
      case 'toys': return Icons.toys;
      case 'chair': return Icons.chair;
      case 'outdoor_grill': return Icons.outdoor_grill;
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final spacesAsyncValue = ref.watch(spacesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Localização e Notificações
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.black87),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _determinePosition();
                      },
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              _currentLocation,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isLoadingLocation)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          else
                            const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                        ],
                      ),
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final unreadAsync = ref.watch(unreadNotificationsCountProvider);
                      final unreadCount = unreadAsync.value ?? 0;
                      
                      return IconButton(
                        icon: unreadCount > 0
                            ? Badge(
                                label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                                backgroundColor: const Color(0xFFB7F65E),
                                textColor: Colors.black,
                                child: const Icon(Icons.notifications_none, color: Colors.black87),
                              )
                            : const Icon(Icons.notifications_none, color: Colors.black87),
                        onPressed: () {
                          context.push('/notifications');
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Categorias
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: categoriesAsyncValue.when(
                data: (categories) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      final selectedCategory = ref.watch(searchCategoryProvider);
                      
                      if (index == 0) {
                        final isSelected = selectedCategory == 'Tudo no Quintou';
                        return GestureDetector(
                          onTap: () {
                            ref.read(searchCategoryProvider.notifier).setCategory('Tudo no Quintou');
                            ref.read(guestTabIndexProvider.notifier).setIndex(1); // Vai para aba Buscar
                          },
                          child: _buildCategoryPill('Tudo', Icons.apps, isSelected),
                        );
                      }
                      
                      final cat = categories[index - 1];
                      // Ajustando o nome da categoria pra bater com as tags da SearchScreen
                      String categoryName = cat.name;
                      if (cat.name.toLowerCase().contains('casamento')) categoryName = 'Casamentos';
                      if (cat.name.toLowerCase().contains('festa')) categoryName = 'Festas';
                      
                      final isSelected = selectedCategory == categoryName;
                      return GestureDetector(
                        onTap: () {
                          ref.read(searchCategoryProvider.notifier).setCategory(categoryName);
                          ref.read(guestTabIndexProvider.notifier).setIndex(1); // Vai para aba Buscar
                        },
                        child: _buildCategoryPill(cat.name, _getIconData(cat.icon), isSelected),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: SizedBox(
                    width: 20, height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                ),
                error: (err, stack) => const Center(child: Text('Erro ao carregar categorias')),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Feed Real (Backend)
            Expanded(
              child: spacesAsyncValue.when(
                data: (spaces) {
                  if (spaces.isEmpty) {
                    return const Center(child: Text('Nenhum espaço encontrado.', style: TextStyle(color: Colors.grey)));
                  }

                  // Agrupar espaços por categoria
                  final Map<String, List<Space>> spacesByCategory = {};
                  for (var space in spaces) {
                    final cat = (space.category.isEmpty) ? 'Destaques' : space.category;
                    if (!spacesByCategory.containsKey(cat)) {
                      spacesByCategory[cat] = [];
                    }
                    spacesByCategory[cat]!.add(space);
                  }

                  return RefreshIndicator(
                    color: const Color(0xFFB7F65E),
                    onRefresh: () => ref.refresh(spacesProvider.future),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                      itemCount: spacesByCategory.keys.length,
                      itemBuilder: (context, index) {
                        final category = spacesByCategory.keys.elementAt(index);
                        final catSpaces = spacesByCategory[category]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 330,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: catSpaces.length,
                                itemBuilder: (context, cardIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: SpaceGridCard(
                                      space: catSpaces[cardIndex],
                                      width: 160,
                                      onTap: () {
                                        context.push('/space-details', extra: catSpaces[cardIndex]);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFB7F65E))),
                error: (err, stack) => Center(child: Text('Erro ao carregar os espaços: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String label, IconData icon, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFB7F65E) : Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isSelected ? const Color(0xFFB7F65E) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.black : Colors.black87,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
