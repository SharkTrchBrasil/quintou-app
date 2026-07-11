import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';

import 'package:quintou_app/features/explore/data/providers/categories_provider.dart';
import 'package:quintou_app/features/spaces/presentation/providers/spaces_provider.dart';
import 'package:quintou_app/features/spaces/presentation/widgets/space_list_card.dart';
import 'package:quintou_app/features/spaces/presentation/widgets/space_grid_card.dart';
import 'package:quintou_app/features/explore/presentation/widgets/filters_bottom_sheet.dart';
import 'package:quintou_app/core/shell/app_shell.dart';

class IsGridModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}
final isGridModeProvider = NotifierProvider<IsGridModeNotifier, bool>(() => IsGridModeNotifier());

class SortOptionNotifier extends Notifier<String> {
  @override
  String build() => 'Mais Relevantes';
  void setOption(String option) => state = option;
}
final sortOptionProvider = NotifierProvider<SortOptionNotifier, String>(() => SortOptionNotifier());

class SearchCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'Tudo no Quintou';
  void setCategory(String cat) => state = cat;
}
final searchCategoryProvider = NotifierProvider<SearchCategoryNotifier, String>(() => SearchCategoryNotifier());

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _currentLocation = 'Buscando...';
  bool _isLoadingLocation = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  void _openDetailedSearch() {
    context.push('/detailed-search');
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final currentSort = ref.read(sortOptionProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ordenar por',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black87),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSortOption('Mais relevantes', 'Mais Relevantes', currentSort, setSheetState),
                    _buildSortOption('Menor preço', 'Menor Preço', currentSort, setSheetState),
                    _buildSortOption('Maior preço', 'Maior Preço', currentSort, setSheetState),
                    _buildSortOption('Melhor avaliados', 'Melhor Avaliados', currentSort, setSheetState),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildSortOption(String label, String value, String currentSort, StateSetter setSheetState) {
    final bool isSelected = currentSort == value;
    return InkWell(
      onTap: () {
        ref.read(sortOptionProvider.notifier).setOption(value);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.black87 : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacesAsyncValue = ref.watch(spacesProvider);
    final isGridMode = ref.watch(isGridModeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Localização e Notificações (igual à Home)
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
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.black87),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Search Bar (Fake)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: GestureDetector(
                onTap: _openDetailedSearch,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'O que você está buscando?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Filtros and Ordenar Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Filtros
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const FiltersBottomSheet(),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.tune, color: Colors.black87, size: 20),
                        SizedBox(width: 6),
                        Text('Filtros', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  
                  // Divider
                  Container(
                    height: 16,
                    width: 1,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  
                  // Ordenar
                  InkWell(
                    onTap: _showSortBottomSheet,
                    child: const Row(
                      children: [
                        Icon(Icons.swap_vert, color: Colors.black87, size: 20),
                        SizedBox(width: 6),
                        Text('Ordenar', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),

                  const Spacer(),
                  
                  // View Toggles (Lista / Grid)
                  Row(
                    children: [
                      InkWell(
                        onTap: () => ref.read(isGridModeProvider.notifier).toggle(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: !isGridMode ? Colors.grey[100] : Colors.white,
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                          ),
                          child: Icon(Icons.list, color: !isGridMode ? Colors.black87 : Colors.grey[600], size: 20),
                        ),
                      ),
                      InkWell(
                        onTap: () => ref.read(isGridModeProvider.notifier).toggle(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isGridMode ? Colors.grey[100] : Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.grey[300]!),
                              bottom: BorderSide(color: Colors.grey[300]!),
                              right: BorderSide(color: Colors.grey[300]!),
                            ),
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                          ),
                          child: Icon(Icons.grid_view, color: isGridMode ? Colors.black87 : Colors.grey[600], size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 16, color: Color(0xFFEEEEEE)),

            // Feed Real (Backend)
            Expanded(
              child: spacesAsyncValue.when(
                data: (spaces) {
                  if (spaces.isEmpty) {
                    return const Center(child: Text('Nenhum anúncio encontrado.', style: TextStyle(color: Colors.grey)));
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(spacesProvider.future),
                    child: isGridMode 
                    ? GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75, // Ajuste para caber as imagens
                        ),
                        itemCount: spaces.length,
                        itemBuilder: (context, index) {
                          return SpaceGridCard(
                            space: spaces[index],
                            onTap: () => context.push('/space-details', extra: spaces[index]),
                          );
                        },
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: spaces.length,
                        itemBuilder: (context, index) {
                          return SpaceListCard(
                            space: spaces[index],
                            onTap: () => context.push('/space-details', extra: spaces[index]),
                            onChatPressed: () {
                              // TODO: Navegar para tela de chat
                            },
                          );
                        },
                      ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Erro ao carregar os espaços: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
