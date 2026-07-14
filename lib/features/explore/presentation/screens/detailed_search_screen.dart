import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/features/explore/presentation/providers/search_autocomplete_provider.dart';
import 'package:quintou_app/features/spaces/presentation/providers/spaces_provider.dart';

class DetailedSearchScreen extends ConsumerStatefulWidget {
  const DetailedSearchScreen({super.key});

  @override
  ConsumerState<DetailedSearchScreen> createState() => _DetailedSearchScreenState();
}

class _DetailedSearchScreenState extends ConsumerState<DetailedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _selectedCategory = 'Tudo no Quintou';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    if (query.isNotEmpty) {
      ref.read(spaceFilterProvider.notifier).setSearchQuery(query);
    }
    // Opcional: setar a categoria também se foi escolhida.
    // ref.read(spaceFilterProvider.notifier).setCategory(_selectedCategory != 'Tudo no Quintou' ? _selectedCategory : null);
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onSubmitted: (value) => _submitSearch(value),
            decoration: InputDecoration(
              hintText: 'O que você está buscando?',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: (value) {
              setState(() {});
              ref.read(searchAutocompleteProvider.notifier).search(value);
            },
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Tudo no Quintou'),
                const SizedBox(width: 8),
                _buildFilterChip('Casamentos'),
                const SizedBox(width: 8),
                _buildFilterChip('Festas'),
                const SizedBox(width: 8),
                _buildFilterChip('Corporativo'),
                const SizedBox(width: 8),
                _buildFilterChip('Infantil'),
              ],
            ),
          ),
        ),
      ),
      body: _searchController.text.isEmpty
          ? const Center(
              child: Text(
                'Digite o nome ou cidade',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : Consumer(
              builder: (context, ref, child) {
                final searchState = ref.watch(searchAutocompleteProvider);

                return searchState.when(
                  data: (results) {
                    if (results.isEmpty) {
                      return ListTile(
                        leading: const Icon(Icons.search, color: Colors.black54),
                        title: Text(
                          'Buscar por "${_searchController.text}"',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onTap: () => _submitSearch(_searchController.text),
                      );
                    }

                    return ListView.builder(
                      itemCount: results.length + 1, // +1 para o item "Buscar por X" no início
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            leading: const Icon(Icons.search, color: Colors.black54),
                            title: Text(
                              'Buscar por "${_searchController.text}"',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            onTap: () => _submitSearch(_searchController.text),
                          );
                        }

                        final item = results[index - 1];
                        final title = item['title'] as String? ?? '';
                        final city = item['city'] as String? ?? '';
                        
                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: Colors.black54),
                          title: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(city, style: const TextStyle(fontSize: 13)),
                          onTap: () => _submitSearch(title),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Erro: $error')),
                );
              },
            ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB7F65E) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFFB7F65E) : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
