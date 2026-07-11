import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  void _submitSearch() {
    // TODO: Implementar lógica de salvar no provider e disparar busca
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
            onSubmitted: (_) => _submitSearch(),
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
            onChanged: (_) {
              setState(() {});
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
                'Digite algo para buscar',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                ListTile(
                  leading: const Icon(Icons.search, color: Colors.black54),
                  title: Text(
                    _searchController.text,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('Em \$_selectedCategory', style: const TextStyle(fontSize: 13)),
                  onTap: _submitSearch,
                ),
              ],
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
