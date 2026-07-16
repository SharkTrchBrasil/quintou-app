import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';

import 'package:quintou_app/features/explore/data/providers/categories_provider.dart';
import 'package:quintou_app/features/spaces/presentation/providers/spaces_provider.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:quintou_app/core/repositories/space_repository.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/features/spaces/presentation/widgets/space_list_card.dart';
import 'package:quintou_app/features/spaces/presentation/widgets/space_grid_card.dart';
import 'package:quintou_app/features/explore/presentation/widgets/filters_bottom_sheet.dart';
import 'package:quintou_app/core/shell/app_shell.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

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
  final PagingController<int, Space> _pagingController = PagingController(firstPageKey: 0);
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final repository = ref.read(spaceRepositoryProvider);
      final spaceFilter = ref.read(spaceFilterProvider);
      final sortOption = ref.read(sortOptionProvider);
      final category = ref.read(searchCategoryProvider);

      final spaces = await repository.getSpaces(
        limit: _pageSize,
        offset: pageKey,
        searchQuery: spaceFilter.searchQuery,
        minPrice: spaceFilter.minPrice,
        maxPrice: spaceFilter.maxPrice,
        minGuests: spaceFilter.minGuests,
        sortBy: sortOption,
        category: category,
      );

      final isLastPage = spaces.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(spaces);
      } else {
        final nextPageKey = pageKey + spaces.length;
        _pagingController.appendPage(spaces, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pagingController.dispose();
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
      backgroundColor: Colors.white,
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
    final isGridMode = ref.watch(isGridModeProvider);
    final spaceFilter = ref.watch(spaceFilterProvider);
    final searchCategory = ref.watch(searchCategoryProvider);
    
    ref.listen<SpaceFilterState>(spaceFilterProvider, (previous, next) {
      _pagingController.refresh();
    });
    ref.listen<String>(sortOptionProvider, (previous, next) {
      _pagingController.refresh();
    });
    ref.listen<String>(searchCategoryProvider, (previous, next) {
      _pagingController.refresh();
    });

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
                          spaceFilter.searchQuery?.isNotEmpty == true 
                            ? spaceFilter.searchQuery! 
                            : 'O que você está buscando?',
                          style: TextStyle(
                            color: spaceFilter.searchQuery?.isNotEmpty == true ? Colors.black87 : Colors.grey[600],
                            fontSize: 15,
                            fontWeight: spaceFilter.searchQuery?.isNotEmpty == true ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (spaceFilter.searchQuery?.isNotEmpty == true)
                        GestureDetector(
                          onTap: () {
                            ref.read(spaceFilterProvider.notifier).setSearchQuery(null);
                          },
                          child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Chips de Filtros Ativos
            if (searchCategory != 'Tudo no Quintou')
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB7F65E).withOpacity(0.2),
                          border: Border.all(color: const Color(0xFFB7F65E)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              searchCategory,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                ref.read(searchCategoryProvider.notifier).setCategory('Tudo no Quintou');
                              },
                              child: const Icon(Icons.close, size: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                        backgroundColor: Colors.white,
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
              child: RefreshIndicator(
                onRefresh: () => Future.sync(() => _pagingController.refresh()),
                child: isGridMode 
                ? PagedGridView<int, Space>(
                    pagingController: _pagingController,
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    builderDelegate: PagedChildBuilderDelegate<Space>(
                      itemBuilder: (BuildContext context, Space item, int index) => SpaceGridCard(
                        space: item,
                        imageAspectRatio: 1, // Square image for grid view
                        onTap: () => context.push('/space-details', extra: item),
                      ),
                      firstPageErrorIndicatorBuilder: (_) => const Center(child: Text('Erro ao carregar')),
                      noItemsFoundIndicatorBuilder: (_) => const Center(child: Text('Nenhum anúncio encontrado.', style: TextStyle(color: Colors.grey))),
                    ),
                  )
                : PagedListView<int, Space>(
                    pagingController: _pagingController,
                    padding: EdgeInsets.zero,
                    builderDelegate: PagedChildBuilderDelegate<Space>(
                      itemBuilder: (BuildContext context, Space item, int index) => SpaceListCard(
                        space: item,
                        onTap: () => context.push('/space-details', extra: item),
                      ),
                      firstPageErrorIndicatorBuilder: (_) => const Center(child: Text('Erro ao carregar')),
                      noItemsFoundIndicatorBuilder: (_) => const Center(child: Text('Nenhum anúncio encontrado.', style: TextStyle(color: Colors.grey))),
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
