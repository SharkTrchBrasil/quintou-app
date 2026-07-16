import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:quintou_app/core/widgets/ds_button.dart';
import 'package:quintou_app/core/widgets/ds_text_field.dart';
import 'package:quintou_app/features/spaces/presentation/providers/create_space_provider.dart';
import 'package:quintou_app/features/explore/data/providers/categories_provider.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/features/spaces/presentation/providers/wizard_config_provider.dart';

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
  final _referencePointCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '50');
  
  // Custom theme colors
  final _primaryColor = const Color(0xFF00AEEF);
  final _borderColor = Colors.grey.shade300;
  final _borderWidth = 0.5;

  List<int> _getValidSteps(WizardConfigModel? config) {
    if (config == null) return [0, 1, 2, 3, 4, 5, 6, 7, 8];
    final stepsRaw = config.steps['steps'] as List?;
    if (stepsRaw != null) {
      final steps = stepsRaw.map((e) => e as int).toList();
      // Remove step 4 (rules) if there are no rules configured
      final rules = (config.steps['step_4_rules'] as List<dynamic>?)?.cast<String>() ?? [];
      if (rules.isEmpty) steps.remove(4);
      // Remove step 5 (amenities) if there are no amenities configured
      final amenities = config.amenities;
      if (amenities.isEmpty) steps.remove(5);
      return steps;
    }
    return [0, 1, 2, 3, 4, 5, 6, 7, 8];
  }

  void _previousPage(List<int> validSteps) {
    int prevPage = _currentPage - 1;
    while (prevPage >= 0 && !validSteps.contains(prevPage)) {
      prevPage--;
    }

    if (prevPage >= 0) {
      _pageController.animateToPage(prevPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage = prevPage);
    }
  }

  void _nextPage(List<int> validSteps) {
    final state = ref.read(createSpaceProvider);
    
    if (_currentPage == 0 && state.categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma categoria.')));
      return;
    }
    
    int nextPage = _currentPage + 1;
    while (nextPage < _totalPages && !validSteps.contains(nextPage)) {
      nextPage++;
    }

    if (nextPage < _totalPages) {
      _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage = nextPage);
    } else {
      _submit();
    }
  }


  void _prevPage(List<int> validSteps) {
    int prevPage = _currentPage - 1;
    while (prevPage >= 0 && !validSteps.contains(prevPage)) {
      prevPage--;
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
    
    // Obter a configuração da categoria selecionada
    AsyncValue<WizardConfigModel>? configAsync;
    if (state.categorySlug != null) {
      configAsync = ref.watch(wizardConfigProvider(state.categorySlug!));
    }
    
    final config = configAsync?.asData?.value;
    final validSteps = _getValidSteps(config);
    final labels = config?.labels ?? {};

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
            if (_currentPage == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              )
            else if (_currentPage != 1 && _currentPage != 6)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        config?.categoryName ?? '',
                        style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep0Category(state, notifier),
                  _buildStep1TitleDesc(state, notifier, labels),
                  _buildStep2Location(state, notifier, labels, config),
                  _buildStep3Capacity(state, notifier, labels, config),
                  _buildStep4Rules(state, notifier, labels, config),
                  _buildStep5Amenities(state, notifier, labels, config),
                  _buildStep6Photos(state, notifier, labels),
                  _buildStep7Availability(state, notifier, labels),
                  _buildStep8Price(state, notifier, labels, config),
                ],
              ),
            ),

            // Progress Bar
            LinearProgressIndicator(
              value: validSteps.isEmpty ? 0 : (validSteps.indexOf(_currentPage) + 1) / validSteps.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              minHeight: 4,
            ),
            // Bottom Bar
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200, width: _borderWidth)),
              ),
              child: Row(
                children: [
                  if (_currentPage > validSteps.first) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => _prevPage(validSteps),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          side: const BorderSide(color: Colors.black),
                        ),
                        child: const Text(
                          'Voltar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    flex: _currentPage > validSteps.first ? 1 : 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: state.isLoading ? null : () => _nextPage(validSteps),
                      child: state.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              _currentPage == validSteps.last ? 'Publicar Anúncio' : 'Continuar',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryColor : _borderColor,
            width: isSelected ? 2.0 : 0.5,
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
        if (categories.isEmpty) return const Center(child: Text('Nenhuma categoria disponível.'));
        
        final authState = ref.watch(authProvider);
        final userName = authState.user?.fullName.split(' ').first ?? '';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  userName.isNotEmpty 
                    ? 'Olá, $userName!\nO que você gostaria de anunciar hoje?'
                    : 'Olá!\nO que você gostaria de anunciar hoje?',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2, letterSpacing: -0.5),
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: categories.length,
                itemBuilder: (context, idx) {
                  final cat = categories[idx];
                  final isSelected = state.categoryId == cat.id;
                  
                  return GestureDetector(
                    onTap: () {
                      notifier.updateField(categoryId: cat.id, listingType: cat.listingType);
                      notifier.updateServiceVehicleFields(categorySlug: cat.slug);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? _primaryColor : Colors.grey.shade300,
                          width: isSelected ? 2.0 : 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.icon, style: const TextStyle(fontSize: 28)),
                          const Spacer(),
                          Text(
                            cat.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                          ),
                          if (cat.description != null && cat.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              cat.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.2),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep1TitleDesc(CreateSpaceState state, CreateSpaceNotifier notifier, Map<String, dynamic> labels) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(labels['step_1_title'] ?? 'Dê um nome ao seu anúncio', 'Títulos curtos funcionam melhor. Não se preocupe, você pode mudar isso depois.'),
          DsTextField(
            title: 'Título do anúncio',
            controller: _titleCtrl,
            onChanged: (val) => notifier.updateField(title: val),
          ),
          const SizedBox(height: 32),
          const Text('Descrição', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DsTextField(
            title: 'Conte um pouco sobre o que você oferece...',
            controller: _descCtrl,
            maxLines: 5,
            onChanged: (val) => notifier.updateField(description: val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Location(CreateSpaceState state, CreateSpaceNotifier notifier, Map<String, dynamic> labels, WizardConfigModel? config) {
    final mode = config?.steps['step_2_mode'] as String?;
    
    if (mode == 'service_area') {
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(labels['step_2_title'] ?? 'Onde você atende?'),
            DsTextField(
              title: 'Área de atuação (Ex: Toda SP, Baixada Santista)',
              onChanged: (val) => notifier.updateServiceVehicleFields(serviceAreaDescription: val),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(labels['step_2_title'] ?? 'Qual é a sua localização?'),
          Row(
            children: [
              Expanded(
                child: DsTextField(
                  title: 'CEP',
                  controller: _cepCtrl,
                  keyboardType: TextInputType.number,
                  formatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    CepInputFormatter(),
                  ],
                  onChanged: (val) {
                    final cleanVal = val.replaceAll(RegExp(r'[^0-9]'), '');
                    notifier.updateField(zipCode: cleanVal);
                    if (cleanVal.length >= 8) {
                      notifier.fetchAddressFromCep(cleanVal).then((_) {
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
          const SizedBox(height: 16),
          DsTextField(title: 'Ponto de Referência', controller: _referencePointCtrl, onChanged: (val) => notifier.updateField(referencePoint: val)),
          
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
              const SizedBox(height: 16),
              DsTextField(
                title: 'Descrição da Entrega',
                onChanged: (val) => notifier.updateField(deliveryDescription: val),
              ),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildStep3Capacity(CreateSpaceState state, CreateSpaceNotifier notifier, Map<String, dynamic> labels, WizardConfigModel? config) {
    final fields = (config?.steps['step_3_fields'] as List<dynamic>?)?.cast<String>() ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(labels['step_3_title'] ?? 'Detalhes do anúncio'),
          
          if (fields.contains('max_guests'))
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                border: Border.all(color: _borderColor, width: _borderWidth),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Capacidade Máxima', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

          if (fields.contains('years_experience')) ...[
            DsTextField(
              title: 'Anos de Experiência',
              keyboardType: TextInputType.number,
              onChanged: (val) => notifier.updateServiceVehicleFields(yearsExperience: int.tryParse(val) ?? 0),
            ),
            const SizedBox(height: 16),
          ],
          if (fields.contains('portfolio_url')) ...[
            DsTextField(
              title: 'Link do Portfolio (Instagram, Site)',
              onChanged: (val) => notifier.updateServiceVehicleFields(portfolioUrl: val),
            ),
            const SizedBox(height: 16),
          ],
          
          if (fields.contains('vehicle_make')) ...[
            Row(
              children: [
                Expanded(child: DsTextField(title: 'Marca (Ex: Yamaha)', onChanged: (val) => notifier.updateServiceVehicleFields(vehicleMake: val))),
                const SizedBox(width: 16),
                Expanded(child: DsTextField(title: 'Modelo (Ex: VX Cruiser)', onChanged: (val) => notifier.updateServiceVehicleFields(vehicleModel: val))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: DsTextField(title: 'Ano', keyboardType: TextInputType.number, onChanged: (val) => notifier.updateServiceVehicleFields(vehicleYear: int.tryParse(val) ?? 2020))),
                const SizedBox(width: 16),
                Expanded(child: DsTextField(title: 'Tamanho (pés)', keyboardType: TextInputType.number, onChanged: (val) => notifier.updateServiceVehicleFields(vehicleLengthFt: double.tryParse(val) ?? 0.0))),
              ],
            ),
            const SizedBox(height: 16),
            DsTextField(title: 'Potência do Motor (HP)', keyboardType: TextInputType.number, onChanged: (val) => notifier.updateServiceVehicleFields(engineHp: int.tryParse(val) ?? 0)),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Capitão / Piloto Incluso', style: TextStyle(fontWeight: FontWeight.bold)),
              value: state.hasCaptain,
              onChanged: (val) => notifier.updateServiceVehicleFields(hasCaptain: val),
              activeColor: _primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Exige Habilitação Náutica', style: TextStyle(fontWeight: FontWeight.bold)),
              value: state.requiresLicense,
              onChanged: (val) => notifier.updateServiceVehicleFields(requiresLicense: val),
              activeColor: _primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
          ],

          if (fields.contains('embark_location')) ...[
            DsTextField(
              title: 'Local de Embarque',
              onChanged: (val) => notifier.updateServiceVehicleFields(embarkLocation: val),
            ),
            const SizedBox(height: 16),
          ],

          if (fields.contains('size_length')) ...[
            Row(
              children: [
                Expanded(
                  child: DsTextField(
                    title: 'Comprimento (m)',
                    keyboardType: TextInputType.number,
                    onChanged: (val) => notifier.updateField(sizeLength: double.tryParse(val) ?? 0.0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DsTextField(
                    title: 'Largura (m)',
                    keyboardType: TextInputType.number,
                    onChanged: (val) => notifier.updateField(sizeWidth: double.tryParse(val) ?? 0.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          
          if (fields.contains('is_outdoor'))
            SwitchListTile(
              title: const Text('Espaço ao ar livre (Outdoor)', style: TextStyle(fontWeight: FontWeight.bold)),
              value: state.isOutdoor,
              onChanged: (val) => notifier.updateField(isOutdoor: val),
              activeColor: _primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
          if (fields.contains('has_restroom'))
            SwitchListTile(
              title: const Text('Possui Banheiro', style: TextStyle(fontWeight: FontWeight.bold)),
              value: state.hasRestroom,
              onChanged: (val) => notifier.updateField(hasRestroom: val),
              activeColor: _primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
          if (fields.contains('is_ada_friendly'))
            SwitchListTile(
              title: const Text('Acessibilidade (PCD)', style: TextStyle(fontWeight: FontWeight.bold)),
              value: state.isAdaFriendly,
              onChanged: (val) => notifier.updateField(isAdaFriendly: val),
              activeColor: _primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Widget _buildStep4Rules(CreateSpaceState state, CreateSpaceNotifier notifier, Map<String, dynamic> labels, WizardConfigModel? config) {
    final rules = (config?.steps['step_4_rules'] as List<dynamic>?)?.cast<String>() ?? [];
    if (rules.isEmpty) return const SizedBox(); // Not used
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Regras e Permissões', 'O que é permitido?'),
          
          if (rules.contains('allows_parties')) ...[
            _buildSelectableCard(title: 'Festas e Eventos', icon: Icons.celebration, isSelected: state.allowsParties, onTap: () => notifier.updateField(allowsParties: !state.allowsParties)),
            const SizedBox(height: 12),
          ],
          if (rules.contains('allows_smoking')) ...[
            _buildSelectableCard(title: 'Fumar', icon: Icons.smoking_rooms, isSelected: state.allowsSmoking, onTap: () => notifier.updateField(allowsSmoking: !state.allowsSmoking)),
            const SizedBox(height: 12),
          ],
          if (rules.contains('allows_pets')) ...[
            _buildSelectableCard(title: 'Animais de Estimação (Pets)', icon: Icons.pets, isSelected: state.allowsPets, onTap: () => notifier.updateField(allowsPets: !state.allowsPets)),
            const SizedBox(height: 12),
          ],
          if (rules.contains('allows_children')) ...[
            _buildSelectableCard(title: 'Crianças', icon: Icons.child_care, isSelected: state.allowsChildren, onTap: () => notifier.updateField(allowsChildren: !state.allowsChildren)),
            const SizedBox(height: 12),
          ],
          if (rules.contains('allows_alcohol')) ...[
            _buildSelectableCard(title: 'Bebida Alcoólica', icon: Icons.wine_bar, isSelected: state.allowsAlcohol, onTap: () => notifier.updateField(allowsAlcohol: !state.allowsAlcohol)),
            const SizedBox(height: 12),
          ],
          if (rules.contains('allows_loud_music')) ...[
            _buildSelectableCard(title: 'Som Alto', icon: Icons.volume_up, isSelected: state.allowsLoudMusic, onTap: () => notifier.updateField(allowsLoudMusic: !state.allowsLoudMusic)),
            const SizedBox(height: 12),
          ],
          if (rules.contains('allows_commercial')) ...[
            _buildSelectableCard(title: 'Uso Comercial (Fotos/Vídeos)', icon: Icons.camera_alt, isSelected: state.allowsCommercial, onTap: () => notifier.updateField(allowsCommercial: !state.allowsCommercial)),
          ],
        ],
      ),
    );
  }

  Widget _buildStep5Amenities(CreateSpaceState state, CreateSpaceNotifier notifier, Map<String, dynamic> labels, WizardConfigModel? config) {
    final amenities = config?.amenities ?? [];
    if (amenities.isEmpty) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Comodidades', 'Quais facilidades o seu espaço oferece?'),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: amenities.map((am) {
              final isSelected = state.amenities.contains(am['name']);
              return GestureDetector(
                onTap: () => notifier.toggleAmenity(am['name']),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: _borderWidth),
                  ),
                  child: Text(am['name'], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6Photos(CreateSpaceState state, CreateSpaceNotifier notifier, Map<String, dynamic> labels) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(labels['step_6_title'] ?? 'Mostre o melhor do seu anúncio', 'Adicione 5 ou mais fotos. A primeira será a capa.'),
          
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

  Widget _buildStep7Availability(CreateSpaceState state, CreateSpaceNotifier notifier, Map<String, dynamic> labels) {
    final days = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
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
                subtitle: isAvailable ? '${rule.startTime} - ${rule.endTime}' : 'Indisponível',
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
    final existingRule = currentRules.where((r) => r.dayOfWeek == dayOfWeek).firstOrNull;
    TimeOfDay start = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 22, minute: 0);
    
    if (existingRule != null) {
      try {
        start = TimeOfDay(hour: int.parse(existingRule.startTime.split(':')[0]), minute: int.parse(existingRule.startTime.split(':')[1]));
        end = TimeOfDay(hour: int.parse(existingRule.endTime.split(':')[0]), minute: int.parse(existingRule.endTime.split(':')[1]));
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final startStr = '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
            final endStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Definir Horário', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: start);
                          if (picked != null) setSheetState(() => start = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                          child: Text(startStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const Text('até', style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: end);
                          if (picked != null) setSheetState(() => end = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                          child: Text(endStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  DsButton(
                    label: 'Salvar Horário',
                    onPressed: () {
                      final newRules = List<AvailabilityRule>.from(currentRules);
                      newRules.removeWhere((r) => r.dayOfWeek == dayOfWeek);
                      newRules.add(AvailabilityRule(dayOfWeek: dayOfWeek, startTime: startStr, endTime: endStr));
                      notifier.setAvailabilityRules(newRules);
                      context.pop();
                    },
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        final newRules = List<AvailabilityRule>.from(currentRules);
                        newRules.removeWhere((r) => r.dayOfWeek == dayOfWeek);
                        notifier.setAvailabilityRules(newRules);
                        context.pop();
                      },
                      child: const Text('Marcar como Fechado', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildStep8Price(CreateSpaceState state, CreateSpaceNotifier notifier, Map<String, dynamic> labels, WizardConfigModel? config) {
    final modes = (config?.steps['pricing_modes'] as List<dynamic>?)?.cast<String>() ?? ['PER_HOUR', 'PER_DAY'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader('Defina seu preço'),
          
          DsTextField(
            title: labels['step_8_price_label'] ?? 'Valor (R\$)',
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateField(price: double.tryParse(val) ?? 50.0),
          ),
          const SizedBox(height: 16),
          Row(
            children: modes.map((mode) {
              String modeLabel = 'Por Hora';
              if (mode == 'PER_DAY') modeLabel = 'Diária';
              if (mode == 'FIXED') modeLabel = 'Fixo / Pacote';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildSelectableCard(
                    title: modeLabel, 
                    isSelected: state.pricingMode == mode, 
                    onTap: () => notifier.updateField(pricingMode: mode)
                  ),
                ),
              );
            }).toList(),
          ),
          
          const Divider(height: 48),
          const Text('Reservas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          SwitchListTile(
            title: const Text('Reserva Instantânea', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Aprova clientes automaticamente'),
            value: !state.requiresApproval,
            onChanged: (val) => notifier.updateField(requiresApproval: !val),
            activeColor: _primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

