import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class SearchCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'Tudo no Quintou';
  void setCategory(String cat) => state = cat;
}

final searchCategoryProvider = NotifierProvider<SearchCategoryNotifier, String>(() {
  return SearchCategoryNotifier();
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    // Inicia com foco automático
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.isNotEmpty) {
        _fetchSuggestions(query);
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    setState(() => _isLoading = true);
    
    // Simular busca de sugestões (pode ser conectado à API depois)
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      final selectedCategory = ref.read(searchCategoryProvider);
      setState(() {
        _suggestions = [
          {'title': 'Sítio com piscina', 'subtitle': 'Busca sugerida'},
          {'title': 'Salão para casamentos', 'subtitle': 'Em $selectedCategory'},
          {'title': 'Churrasqueira', 'subtitle': 'Comodidade'},
        ];
        _isLoading = false;
      });
    }
  }

  void _handleSuggestionTap(Map<String, dynamic> suggestion) {
    FocusScope.of(context).unfocus();
    // TODO: Implementar navegação para resultados de busca
  }

  void _submitRawSearch() {
    FocusScope.of(context).unfocus();
    // TODO: Implementar busca
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Não mostrar seta voltar no tab bar
        titleSpacing: 16,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          onSubmitted: (_) => _submitRawSearch(),
          decoration: InputDecoration(
            hintText: 'Onde você quer festejar?',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
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
      body: _buildBody(),
    );
  }

  Widget _buildFilterChip(String label) {
    final selectedCategory = ref.watch(searchCategoryProvider);
    final isSelected = selectedCategory == label;
    return InkWell(
      onTap: () {
        ref.read(searchCategoryProvider.notifier).setCategory(label);
        if (_searchController.text.isNotEmpty) {
          _fetchSuggestions(_searchController.text);
        }
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

  Widget _buildBody() {
    if (_isLoading && _suggestions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text(
          'Digite o nome de uma cidade ou espaço',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    if (_suggestions.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhum resultado encontrado para "${_searchController.text}"',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Você está buscando por',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _suggestions[index];
              return ListTile(
                leading: const Icon(Icons.search, color: Colors.black54),
                title: Text(
                  suggestion['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  suggestion['subtitle'] ?? '',
                  style: const TextStyle(fontSize: 13),
                ),
                onTap: () => _handleSuggestionTap(suggestion),
              );
            },
          ),
        ),
      ],
    );
  }
}
