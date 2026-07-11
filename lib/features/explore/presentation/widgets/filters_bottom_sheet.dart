import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/core/widgets/ds_button.dart';
import 'package:quintou_app/features/spaces/presentation/providers/spaces_provider.dart';

class FiltersBottomSheet extends ConsumerStatefulWidget {
  const FiltersBottomSheet({super.key});

  @override
  ConsumerState<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends ConsumerState<FiltersBottomSheet> {
  late SpaceFilterState _tempState;

  @override
  void initState() {
    super.initState();
    _tempState = ref.read(spaceFilterProvider);
  }

  void _applyFilters() {
    ref.read(spaceFilterProvider.notifier).updateFilters(_tempState);
    context.pop();
  }
  
  void _clearFilters() {
    setState(() {
      _tempState = SpaceFilterState(category: _tempState.category); // Limpa tudo exceto a categoria
    });
  }
  
  void _toggleAmenity(String am) {
    final list = List<String>.from(_tempState.amenities);
    if (list.contains(am)) list.remove(am);
    else list.add(am);
    setState(() {
      _tempState = _tempState.copyWith(amenities: list);
    });
  }

  void _toggleTag(String tag) {
    final list = List<String>.from(_tempState.tags);
    if (list.contains(tag)) list.remove(tag);
    else list.add(tag);
    setState(() {
      _tempState = _tempState.copyWith(tags: list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material( // Precisamos de Material aqui se estiver no showModalBottomSheet para ListTiles funcionarem
      color: Colors.white,
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.95,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstantBook(),
                      _buildDivider(),
                      
                      _buildSpaceType(),
                      _buildDivider(),
                      
                      _buildWaterType(), // Só faria sentido se category fosse piscina, mas vamos deixar genérico
                      _buildDivider(),
                      
                      _buildEssentials(),
                      _buildDivider(),
                      
                      _buildHostAllowed(),
                      _buildDivider(),
                      
                      _buildPopularAmenities(),
                      _buildDivider(),
                      
                      _buildSpaceAmenities(),
                      _buildDivider(),
                      
                      _buildAdditionalSpaces(),
                      _buildDivider(),
                      
                      _buildGreatFor(),
                      _buildDivider(),
                      
                      _buildPrivacy(),
                    ],
                  ),
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
          const Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Limpar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Divider(color: Colors.grey[200]),
  );

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: DsButton(
        text: 'Mostrar Resultados',
        onPressed: _applyFilters,
      ),
    );
  }

  // Seção 1: Reserva Instantânea
  Widget _buildInstantBook() {
    return SwitchListTile(
      title: const Text('Reserva Instantânea', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Reserve sem precisar de aprovação do anfitrião', style: TextStyle(color: Colors.grey, fontSize: 13)),
      value: _tempState.requiresApproval == false,
      onChanged: (val) {
        setState(() => _tempState = _tempState.copyWith(requiresApproval: !val));
      },
      activeColor: const Color(0xFF00AEEF),
      contentPadding: EdgeInsets.zero,
    );
  }

  // Seção 2: Tipo de Espaço (Outdoor/Indoor)
  Widget _buildSpaceType() {
    return _buildSection(
      title: 'Tipo de Espaço',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChoiceChip('Ao ar livre', _tempState.isOutdoor == true, () => setState(() => _tempState = _tempState.copyWith(isOutdoor: true))),
          _buildChoiceChip('Coberto', _tempState.isOutdoor == false, () => setState(() => _tempState = _tempState.copyWith(isOutdoor: false))),
          _buildChoiceChip('Piscina Aquecida', _tempState.hasHeatedPool == true, () => setState(() => _tempState = _tempState.copyWith(hasHeatedPool: !(_tempState.hasHeatedPool ?? false)))),
          _buildChoiceChip('Jacuzzi / Hidromassagem', _tempState.hasHotTub == true, () => setState(() => _tempState = _tempState.copyWith(hasHotTub: !(_tempState.hasHotTub ?? false)))),
        ],
      ),
    );
  }

  // Seção 3: Tipo de Água
  Widget _buildWaterType() {
    return _buildSection(
      title: 'Tipo de Água',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChoiceChip('Cloro', _tempState.spaceType == 'Cloro', () => setState(() => _tempState = _tempState.copyWith(spaceType: _tempState.spaceType == 'Cloro' ? null : 'Cloro'))),
          _buildChoiceChip('Água Salgada', _tempState.spaceType == 'Salgada', () => setState(() => _tempState = _tempState.copyWith(spaceType: _tempState.spaceType == 'Salgada' ? null : 'Salgada'))),
          _buildChoiceChip('Água Doce', _tempState.spaceType == 'Doce', () => setState(() => _tempState = _tempState.copyWith(spaceType: _tempState.spaceType == 'Doce' ? null : 'Doce'))),
        ],
      ),
    );
  }

  // Seção 4: Essenciais
  Widget _buildEssentials() {
    final essentials = [
      {'icon': Icons.wc, 'label': 'Banheiro', 'value': _tempState.hasRestroom ?? false, 'onTap': () => setState(() => _tempState = _tempState.copyWith(hasRestroom: !(_tempState.hasRestroom ?? false)))},
      {'icon': Icons.local_parking, 'label': 'Estacionamento', 'value': _tempState.hasParking ?? false, 'onTap': () => setState(() => _tempState = _tempState.copyWith(hasParking: !(_tempState.hasParking ?? false)))},
      {'icon': Icons.accessible, 'label': 'Acessibilidade', 'value': _tempState.isAdaFriendly ?? false, 'onTap': () => setState(() => _tempState = _tempState.copyWith(isAdaFriendly: !(_tempState.isAdaFriendly ?? false)))},
    ];

    return _buildSection(
      title: 'Essenciais',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: essentials.length,
        itemBuilder: (context, i) {
          final item = essentials[i];
          final bool isSelected = item['value'] as bool;
          return GestureDetector(
            onTap: item['onTap'] as VoidCallback,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? const Color(0xFF00AEEF) : Colors.grey[300]!, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? const Color(0xFF00AEEF).withOpacity(0.05) : Colors.transparent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'] as IconData, color: isSelected ? const Color(0xFF00AEEF) : Colors.grey[700], size: 32),
                  const SizedBox(height: 8),
                  Text(item['label'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Seção 5: Permitido pelo Anfitrião
  Widget _buildHostAllowed() {
    return _buildSection(
      title: 'Permitido pelo Anfitrião',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChoiceChip('Pets', _tempState.allowsPets == true, () => setState(() => _tempState = _tempState.copyWith(allowsPets: !(_tempState.allowsPets ?? false)))),
          _buildChoiceChip('Bebida Alcoólica', _tempState.allowsAlcohol == true, () => setState(() => _tempState = _tempState.copyWith(allowsAlcohol: !(_tempState.allowsAlcohol ?? false)))),
          _buildChoiceChip('Fumar', _tempState.allowsSmoking == true, () => setState(() => _tempState = _tempState.copyWith(allowsSmoking: !(_tempState.allowsSmoking ?? false)))),
          _buildChoiceChip('Uso Comercial', _tempState.allowsCommercial == true, () => setState(() => _tempState = _tempState.copyWith(allowsCommercial: !(_tempState.allowsCommercial ?? false)))),
          _buildChoiceChip('Som Alto', _tempState.allowsLoudMusic == true, () => setState(() => _tempState = _tempState.copyWith(allowsLoudMusic: !(_tempState.allowsLoudMusic ?? false)))),
          _buildChoiceChip('Festas', _tempState.allowsParties == true, () => setState(() => _tempState = _tempState.copyWith(allowsParties: !(_tempState.allowsParties ?? false)))),
        ],
      ),
    );
  }

  // Seção 6: Comodidades Populares
  Widget _buildPopularAmenities() {
    final amenities = ['Tobogã', 'Trampolim', 'Piscina Infantil', 'Área Rasa', 'Cascata', 'Sauna'];
    return _buildSection(
      title: 'Comodidades Populares',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: amenities.map((am) => _buildFilterChip(am, _tempState.amenities.contains(am), () => _toggleAmenity(am))).toList(),
      ),
    );
  }

  // Seção 7: Comodidades do Espaço
  Widget _buildSpaceAmenities() {
    final amenities = ['Ducha', 'Wi-Fi', 'Som', 'Churrasqueira', 'Forno de Pizza', 'Espreguiçadeiras', 'Guarda-sol', 'Rede de Descanso', 'Ar Condicionado', 'TV'];
    return _buildSection(
      title: 'Comodidades do Espaço',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: amenities.map((am) => _buildFilterChip(am, _tempState.amenities.contains(am), () => _toggleAmenity(am))).toList(),
      ),
    );
  }

  // Seção 8: Espaços Adicionais
  Widget _buildAdditionalSpaces() {
    final amenities = ['Campo de Futebol', 'Quadra de Areia', 'Playground', 'Espaço Gourmet'];
    return _buildSection(
      title: 'Espaços Adicionais',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: amenities.map((am) => _buildFilterChip(am, _tempState.amenities.contains(am), () => _toggleAmenity(am))).toList(),
      ),
    );
  }

  // Seção 9: Ideal Para
  Widget _buildGreatFor() {
    final tags = ['Festa', 'Churrasco com Amigos', 'Reunião Familiar', 'Ensaio Fotográfico', 'Gravação de Vídeo', 'Corporativo', 'Day Use'];
    return _buildSection(
      title: 'Ideal Para',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tg) => _buildFilterChip(tg, _tempState.tags.contains(tg), () => _toggleTag(tg))).toList(),
      ),
    );
  }

  // Seção 10: Privacidade
  Widget _buildPrivacy() {
    return _buildSection(
      title: 'Privacidade',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildChoiceChip('Padrão (Visualizável)', _tempState.privacyLevel == 'Standard', () => setState(() => _tempState = _tempState.copyWith(privacyLevel: _tempState.privacyLevel == 'Standard' ? null : 'Standard'))),
          _buildChoiceChip('Isolado (100% Privado)', _tempState.privacyLevel == 'Secluded', () => setState(() => _tempState = _tempState.copyWith(privacyLevel: _tempState.privacyLevel == 'Secluded' ? null : 'Secluded'))),
        ],
      ),
    );
  }

  // Helper widgets
  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFF00AEEF).withOpacity(0.2),
      checkmarkColor: const Color(0xFF00AEEF),
      side: BorderSide(color: isSelected ? const Color(0xFF00AEEF) : Colors.grey[300]!),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF00AEEF) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
    );
  }
  
  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFF00AEEF).withOpacity(0.2),
      checkmarkColor: const Color(0xFF00AEEF),
      side: BorderSide(color: isSelected ? const Color(0xFF00AEEF) : Colors.grey[300]!),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF00AEEF) : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
    );
  }
}
