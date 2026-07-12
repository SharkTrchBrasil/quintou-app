import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quintou_app/core/widgets/ds_button.dart';
import 'package:quintou_app/core/widgets/ds_text_field.dart';
import 'package:quintou_app/features/spaces/presentation/providers/create_space_provider.dart';
import 'package:quintou_app/features/explore/data/providers/categories_provider.dart';

class CreateSpaceScreen extends ConsumerStatefulWidget {
  const CreateSpaceScreen({super.key});

  @override
  ConsumerState<CreateSpaceScreen> createState() => _CreateSpaceScreenState();
}

class _CreateSpaceScreenState extends ConsumerState<CreateSpaceScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 9;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '50');
  
  // Custom theme colors
  final _primaryColor = const Color(0xFF00AEEF);
  final _borderColor = Colors.grey.shade300;
  final _borderWidth = 0.5;

  void _nextPage() {
    final state = ref.read(createSpaceProvider);
    
    // Validations
    if (_currentPage == 0 && state.categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma categoria.')));
      return;
    }
    
    int nextPage = _currentPage + 1;
    
    // Skip steps for EQUIPMENT
    if (state.listingType == 'EQUIPMENT') {
      if (nextPage == 4 || nextPage == 5) {
        nextPage = 6;
      }
    }

    if (nextPage < _totalPages) {
      _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage = nextPage);
    } else {
      _submit();
    }
  }

  void _prevPage() {
    final state = ref.read(createSpaceProvider);
    int prevPage = _currentPage - 1;

    // Skip steps back for EQUIPMENT
    if (state.listingType == 'EQUIPMENT') {
      if (prevPage == 5 || prevPage == 4) {
        prevPage = 3;
      }
    }

    if (prevPage >= 0) {
      _pageController.animateToPage(prevPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage = prevPage);
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    final success = await ref.read(createSpaceProvider.notifier).submit();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anúncio criado com sucesso!')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createSpaceProvider);
    final notifier = ref.read(createSpaceProvider.notifier);

    ref.listen<CreateSpaceState>(createSpaceProvider, (prev, next) {
      if (prev?.error != next.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: _prevPage,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _totalPages,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance back button
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep0Category(state, notifier),
                  _buildStep1TitleDesc(state, notifier),
                  _buildStep2Location(state, notifier),
                  _buildStep3Capacity(state, notifier),
                  _buildStep4Rules(state, notifier),
                  _buildStep5Amenities(state, notifier),
                  _buildStep6Photos(state, notifier),
                  _buildStep7Availability(state, notifier),
                  _buildStep8Price(state, notifier),
                ],
              ),
            ),

            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200, width: _borderWidth)),
              ),
              child: DsButton(
                label: _currentPage == _totalPages - 1 ? 'Publicar Anúncio' : 'Continuar',
                isLoading: state.isLoading,
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI Helpers
  Widget _buildHeader(String title, [String? subtitle]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2, letterSpacing: -0.5)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSelectableCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryColor : _borderColor,
            width: isSelected ? 2 : _borderWidth,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 28, color: isSelected ? _primaryColor : Colors.black87),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? _primaryColor : Colors.black87)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  ]
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? _primaryColor : Colors.grey.shade400,
            )
          ],
        ),
      ),
    );
  }

  // --- STEPS ---

  Widget _buildStep0Category(CreateSpaceState state, CreateSpaceNotifier notifier) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return categoriesAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Erro ao carregar categorias: $err')),
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('Nenhuma categoria disponível.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader('O que você quer anunciar?'),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: categories.map((cat) {
                  final isSelected = state.categoryId == cat.id;
                  // Mapeando icones string para IconData provisoriamente
                  IconData iconData = Icons.place;
                  if (cat.icon == 'pool') iconData = Icons.pool;
                  if (cat.icon == 'nature_people') iconData = Icons.park;
                  if (cat.icon == 'celebration') iconData = Icons.celebration;
                  if (cat.icon == 'outdoor_grill') iconData = Icons.outdoor_grill;
                  if (cat.icon == 'sports_tennis') iconData = Icons.sports_tennis;
                  if (cat.icon == 'camera_alt') iconData = Icons.camera_alt;
                  if (cat.icon == 'toys') iconData = Icons.toys;
                  if (cat.icon == 'chair') iconData = Icons.chair;

                  return GestureDetector(
                    onTap: () {
                      notifier.updateField(categoryId: cat.id, listingType: cat.listingType);
                    },
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 64) / 2,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? _primaryColor.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? _primaryColor : _borderColor,
                          width: isSelected ? 2 : _borderWidth,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(iconData, size: 40, color: isSelected ? _primaryColor : Colors.black87),
                          const SizedBox(height: 12),
                          Text(cat.name, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? _primaryColor : Colors.black87)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep1TitleDesc(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Dê um nome ao seu anúncio', 'Títulos curtos funcionam melhor. Não se preocupe, você pode mudar isso depois.'),
          DsTextField(
            title: 'Título do anúncio',
            controller: _titleCtrl,
            onChanged: (val) => notifier.updateField(title: val),
          ),
          const SizedBox(height: 32),
          const Text('Descreva seu espaço', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DsTextField(
            title: 'Descrição',
            controller: _descCtrl,

            onChanged: (val) => notifier.updateField(description: val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Location(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(state.listingType == 'SPACE' ? 'Onde fica o seu espaço?' : 'Qual é a sua localização?'),
          Row(
            children: [
              Expanded(
                child: DsTextField(
                  title: 'CEP',
                  controller: _cepCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    notifier.updateField(zipCode: val);
                    if (val.length >= 8) {
                      notifier.fetchAddressFromCep(val).then((_) {
                        _addressCtrl.text = ref.read(createSpaceProvider).addressLine;
                        _cityCtrl.text = ref.read(createSpaceProvider).city;
                        _stateCtrl.text = ref.read(createSpaceProvider).state;
                        _neighborhoodCtrl.text = ref.read(createSpaceProvider).neighborhood;
                      });
                    }
                  },
                ),
              ),
              if (state.isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
            ],
          ),
          const SizedBox(height: 16),
          DsTextField(title: 'Rua / Avenida', controller: _addressCtrl, onChanged: (val) => notifier.updateField(addressLine: val)),
          const SizedBox(height: 16),
          DsTextField(title: 'Bairro', controller: _neighborhoodCtrl, onChanged: (val) => notifier.updateField(neighborhood: val)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: DsTextField(title: 'Cidade', controller: _cityCtrl, onChanged: (val) => notifier.updateField(city: val))),
              const SizedBox(width: 16),
              Expanded(child: DsTextField(title: 'Estado', controller: _stateCtrl, onChanged: (val) => notifier.updateField(stateValue: val))),
            ],
          ),
          
          if (state.listingType == 'EQUIPMENT') ...[
            const Divider(height: 48),
            _buildHeader('Opções de Entrega'),
            SwitchListTile(
              title: const Text('Ofereço entrega no local do cliente', style: TextStyle(fontWeight: FontWeight.bold)),
              value: state.deliveryAvailable,
              onChanged: (val) => notifier.updateField(deliveryAvailable: val),
              activeColor: _primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
            if (state.deliveryAvailable) ...[
              const SizedBox(height: 16),
              DsTextField(
                title: 'Taxa de Entrega (R\$)',
                keyboardType: TextInputType.number,
                onChanged: (val) => notifier.updateField(deliveryFee: double.tryParse(val) ?? 0.0),
              ),
              const SizedBox(height: 16),
              DsTextField(
                title: 'Raio de entrega (Km)',
                keyboardType: TextInputType.number,
                onChanged: (val) => notifier.updateField(deliveryRadiusKm: int.tryParse(val) ?? 10),
              ),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildStep3Capacity(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Detalhes do anúncio'),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor, width: _borderWidth),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Número Máximo\nde Pessoas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: _primaryColor,
                      onPressed: () => notifier.updateField(maxGuests: (state.maxGuests > 1) ? state.maxGuests - 1 : 1),
                    ),
                    Text('${state.maxGuests}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      color: _primaryColor,
                      onPressed: () => notifier.updateField(maxGuests: state.maxGuests + 1),
                    ),
                  ],
                )
              ],
            ),
          ),

          if (state.listingType == 'SPACE') ...[
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Espaço ao ar livre (Outdoor)', style: TextStyle(fontWeight: FontWeight.bold)),
              value: state.isOutdoor,
              onChanged: (val) => notifier.updateField(isOutdoor: val),
              activeColor: _primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Possui Banheiro', style: TextStyle(fontWeight: FontWeight.bold)),
              value: state.hasRestroom,
              onChanged: (val) => notifier.updateField(hasRestroom: val),
              activeColor: _primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Acessibilidade (PCD)', style: TextStyle(fontWeight: FontWeight.bold)),
              value: state.isAdaFriendly,
              onChanged: (val) => notifier.updateField(isAdaFriendly: val),
              activeColor: _primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStep4Rules(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Regras da Casa', 'O que é permitido no seu espaço?'),
          
          _buildSelectableCard(title: 'Festas e Eventos', icon: Icons.celebration, isSelected: state.allowsParties, onTap: () => notifier.updateField(allowsParties: !state.allowsParties)),
          const SizedBox(height: 12),
          _buildSelectableCard(title: 'Fumar', icon: Icons.smoking_rooms, isSelected: state.allowsSmoking, onTap: () => notifier.updateField(allowsSmoking: !state.allowsSmoking)),
          const SizedBox(height: 12),
          _buildSelectableCard(title: 'Animais de Estimação (Pets)', icon: Icons.pets, isSelected: state.allowsPets, onTap: () => notifier.updateField(allowsPets: !state.allowsPets)),
          const SizedBox(height: 12),
          _buildSelectableCard(title: 'Crianças', icon: Icons.child_care, isSelected: state.allowsChildren, onTap: () => notifier.updateField(allowsChildren: !state.allowsChildren)),
          const SizedBox(height: 12),
          _buildSelectableCard(title: 'Bebida Alcoólica', icon: Icons.wine_bar, isSelected: state.allowsAlcohol, onTap: () => notifier.updateField(allowsAlcohol: !state.allowsAlcohol)),
          const SizedBox(height: 12),
          _buildSelectableCard(title: 'Som Alto', icon: Icons.volume_up, isSelected: state.allowsLoudMusic, onTap: () => notifier.updateField(allowsLoudMusic: !state.allowsLoudMusic)),
          const SizedBox(height: 12),
          _buildSelectableCard(title: 'Uso Comercial (Fotos/Vídeos)', icon: Icons.camera_alt, isSelected: state.allowsCommercial, onTap: () => notifier.updateField(allowsCommercial: !state.allowsCommercial)),
        ],
      ),
    );
  }

  Widget _buildStep5Amenities(CreateSpaceState state, CreateSpaceNotifier notifier) {
    final availableAmenities = ['Wi-Fi', 'Som', 'TV', 'Ar Condicionado', 'Churrasqueira', 'Forno de Pizza', 'Ducha', 'Cadeiras', 'Guarda-sol', 'Estacionamento'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('O que o espaço oferece?'),
          
          SwitchListTile(
            title: const Text('Piscina Aquecida', style: TextStyle(fontWeight: FontWeight.bold)),
            value: state.hasHeatedPool,
            onChanged: (val) => notifier.updateField(hasHeatedPool: val),
            activeColor: _primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Hidromassagem / Jacuzzi', style: TextStyle(fontWeight: FontWeight.bold)),
            value: state.hasHotTub,
            onChanged: (val) => notifier.updateField(hasHotTub: val),
            activeColor: _primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
          
          const SizedBox(height: 24),
          const Text('Comodidades extras', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: availableAmenities.map((am) {
              final isSelected = state.amenities.contains(am);
              return GestureDetector(
                onTap: () => notifier.toggleAmenity(am),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: _borderWidth),
                  ),
                  child: Text(am, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6Photos(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Mostre o melhor do seu anúncio', 'Adicione 5 ou mais fotos. A primeira será a capa.'),
          
          if (state.images.isEmpty)
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final List<XFile> images = await picker.pickMultiImage();
                if (images.isNotEmpty) notifier.addImages(images);
              },
              child: Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: _primaryColor.withOpacity(0.5), width: 2, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 64, color: _primaryColor),
                    const SizedBox(height: 16),
                    const Text('Toque para adicionar fotos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            )
          else ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.images.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                if (index == state.images.length) {
                  return GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final List<XFile> images = await picker.pickMultiImage();
                      if (images.isNotEmpty) notifier.addImages(images);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: _borderColor, width: _borderWidth),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: Icon(Icons.add, size: 40, color: Colors.grey)),
                    ),
                  );
                }
                final file = state.images[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(File(file.path), fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => notifier.removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.black, size: 16),
                        ),
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                          child: const Text('CAPA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                        ),
                      )
                  ],
                );
              },
            )
          ]
        ],
      ),
    );
  }

  Widget _buildStep7Availability(CreateSpaceState state, CreateSpaceNotifier notifier) {
    final days = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Quando está disponível?'),
          
          ...List.generate(7, (i) {
            final rule = state.availabilityRules.where((r) => r.dayOfWeek == i).firstOrNull;
            final isAvailable = rule != null;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSelectableCard(
                title: days[i],
                subtitle: isAvailable ? '${rule.startTime} - ${rule.endTime}' : 'Fechado',
                isSelected: isAvailable,
                onTap: () {
                  _showTimeSlotPicker(context, i, notifier, state.availabilityRules);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showTimeSlotPicker(BuildContext context, int dayOfWeek, CreateSpaceNotifier notifier, List<AvailabilityRule> currentRules) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Definir Horário', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // Simplificando o modal para demonstração (na vida real usaríamos time pickers)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('08:00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('até', style: TextStyle(color: Colors.grey)),
                  const Text('22:00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 32),
              DsButton(
                label: 'Salvar Horário',
                onPressed: () {
                  final newRules = List<AvailabilityRule>.from(currentRules);
                  newRules.removeWhere((r) => r.dayOfWeek == dayOfWeek);
                  newRules.add(AvailabilityRule(dayOfWeek: dayOfWeek, startTime: '08:00', endTime: '22:00'));
                  notifier.setAvailabilityRules(newRules);
                  context.pop();
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  final newRules = List<AvailabilityRule>.from(currentRules);
                  newRules.removeWhere((r) => r.dayOfWeek == dayOfWeek);
                  notifier.setAvailabilityRules(newRules);
                  context.pop();
                },
                child: const Center(child: Text('Marcar como Fechado', style: TextStyle(color: Colors.red))),
              )
            ],
          ),
        );
      }
    );
  }

  Widget _buildStep8Price(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Defina seu preço'),
          
          DsTextField(
            title: 'Valor (R\$)',
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateField(price: double.tryParse(val) ?? 50.0),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSelectableCard(title: 'Por Hora', isSelected: state.pricingMode == 'PER_HOUR', onTap: () => notifier.updateField(pricingMode: 'PER_HOUR'))),
              const SizedBox(width: 12),
              Expanded(child: _buildSelectableCard(title: 'Diária', isSelected: state.pricingMode == 'PER_DAY', onTap: () => notifier.updateField(pricingMode: 'PER_DAY'))),
            ],
          ),
          
          const Divider(height: 48),
          const Text('Reservas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Reserva Instantânea', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Aprova convidados automaticamente'),
            value: !state.requiresApproval,
            onChanged: (val) => notifier.updateField(requiresApproval: !val),
            activeColor: _primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
          
          const SizedBox(height: 24),
          const Text('Política de Cancelamento', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildSelectableCard(title: 'Flexível', subtitle: 'Reembolso total até 24h antes', isSelected: state.cancellationPolicy == 'FLEXIVEL', onTap: () => notifier.updateField(cancellationPolicy: 'FLEXIVEL')),
          const SizedBox(height: 8),
          _buildSelectableCard(title: 'Moderada', subtitle: 'Reembolso total até 5 dias antes', isSelected: state.cancellationPolicy == 'MODERADA', onTap: () => notifier.updateField(cancellationPolicy: 'MODERADA')),
          const SizedBox(height: 8),
          _buildSelectableCard(title: 'Rigorosa', subtitle: 'Reembolso total até 14 dias antes', isSelected: state.cancellationPolicy == 'RIGOROSA', onTap: () => notifier.updateField(cancellationPolicy: 'RIGOROSA')),
        ],
      ),
    );
  }
}
