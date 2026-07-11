import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quintou_app/core/widgets/ds_button.dart';
import 'package:quintou_app/core/widgets/ds_text_field.dart';
import 'package:quintou_app/features/spaces/presentation/providers/create_space_provider.dart';

class CreateSpaceScreen extends ConsumerStatefulWidget {
  const CreateSpaceScreen({super.key});

  @override
  ConsumerState<CreateSpaceScreen> createState() => _CreateSpaceScreenState();
}

class _CreateSpaceScreenState extends ConsumerState<CreateSpaceScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 7;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '50');
  final _guestsCtrl = TextEditingController(text: '10');
  
  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _submit();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      context.pop();
    }
  }

  Future<void> _submit() async {
    final success = await ref.read(createSpaceProvider.notifier).submit();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Espaço publicado com sucesso!')));
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: _prevPage),
        title: Text('Passo ${_currentPage + 1} de $_totalPages', style: const TextStyle(color: Colors.black, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / _totalPages,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00AEEF)),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                children: [
                  _buildStep1(state, notifier), // O que
                  _buildStep2(state, notifier), // Onde
                  _buildStep3(state, notifier), // Detalhes
                  _buildStep4(state, notifier), // Comodidades
                  _buildStep5(state, notifier), // Regras
                  _buildStep6(state, notifier), // Preço
                  _buildStep7(state, notifier), // Imagens
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: DsButton(
                text: _currentPage == _totalPages - 1 ? 'Publicar Espaço' : 'Próximo',
                isLoading: state.isLoading,
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('O que você está anunciando?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: state.listingType,
            decoration: InputDecoration(labelText: 'Tipo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: const [
              DropdownMenuItem(value: 'SPACE', child: Text('Espaço Físico')),
              DropdownMenuItem(value: 'EQUIPMENT', child: Text('Equipamento')),
            ],
            onChanged: (val) => notifier.updateField(listingType: val),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.category,
            decoration: InputDecoration(labelText: 'Categoria', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: const [
              DropdownMenuItem(value: 'PISCINA', child: Text('Piscina')),
              DropdownMenuItem(value: 'CHURRASQUEIRA', child: Text('Churrasqueira')),
              DropdownMenuItem(value: 'QUADRA', child: Text('Quadra Esportiva')),
              DropdownMenuItem(value: 'SALAO_FESTAS', child: Text('Salão de Festas')),
            ],
            onChanged: (val) => notifier.updateField(category: val),
          ),
          const SizedBox(height: 16),
          DsTextField(
            label: 'Título do anúncio',
            controller: _titleCtrl,
            onChanged: (val) => notifier.updateField(title: val),
          ),
          const SizedBox(height: 16),
          DsTextField(
            label: 'Descrição',
            controller: _descCtrl,
            maxLines: 4,
            onChanged: (val) => notifier.updateField(description: val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Onde fica o espaço?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: DsTextField(
                  label: 'CEP',
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
          DsTextField(
            label: 'Rua / Avenida',
            controller: _addressCtrl,
            onChanged: (val) => notifier.updateField(addressLine: val),
          ),
          const SizedBox(height: 16),
          DsTextField(
            label: 'Bairro',
            controller: _neighborhoodCtrl,
            onChanged: (val) => notifier.updateField(neighborhood: val),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DsTextField(
                  label: 'Cidade',
                  controller: _cityCtrl,
                  onChanged: (val) => notifier.updateField(city: val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DsTextField(
                  label: 'Estado',
                  controller: _stateCtrl,
                  onChanged: (val) => notifier.updateField(state: val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detalhes e Estrutura', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          DsTextField(
            label: 'Número Máximo de Pessoas',
            controller: _guestsCtrl,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateField(maxGuests: int.tryParse(val) ?? 10),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Espaço ao ar livre (Outdoor)'),
            value: state.isOutdoor,
            onChanged: (val) => notifier.updateField(isOutdoor: val),
            activeColor: const Color(0xFF00AEEF),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Possui Banheiro'),
            value: state.hasRestroom,
            onChanged: (val) => notifier.updateField(hasRestroom: val),
            activeColor: const Color(0xFF00AEEF),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Acessibilidade (PCD)'),
            value: state.isAdaFriendly,
            onChanged: (val) => notifier.updateField(isAdaFriendly: val),
            activeColor: const Color(0xFF00AEEF),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.privacyLevel,
            decoration: InputDecoration(labelText: 'Nível de Privacidade', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: const [
              DropdownMenuItem(value: 'Standard', child: Text('Padrão (Visualizável)')),
              DropdownMenuItem(value: 'Secluded', child: Text('Isolado (100% Privado)')),
            ],
            onChanged: (val) => notifier.updateField(privacyLevel: val),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DsTextField(
                  label: 'Comprimento (m)',
                  controller: _lengthCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => notifier.updateField(sizeLength: double.tryParse(val) ?? 0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DsTextField(
                  label: 'Largura (m)',
                  controller: _widthCtrl,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => notifier.updateField(sizeWidth: double.tryParse(val) ?? 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(CreateSpaceState state, CreateSpaceNotifier notifier) {
    final availableAmenities = [
      'Wi-Fi', 'Som', 'TV', 'Ar Condicionado', 'Churrasqueira', 'Forno de Pizza', 'Espaço Gourmet',
      'Ducha', 'Cadeiras', 'Espreguiçadeiras', 'Guarda-sol', 'Rede de Descanso',
      'Piscina Infantil', 'Cascata', 'Sauna', 'Tobogã', 'Trampolim',
      'Estacionamento', 'Playground', 'Campo de Futebol', 'Quadra de Areia'
    ];
    
    final availableTags = [
      'Festa', 'Churrasco com Amigos', 'Reunião Familiar', 'Ensaio Fotográfico', 
      'Gravação de Vídeo', 'Corporativo', 'Day Use'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Comodidades & Diferenciais', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          SwitchListTile(
            title: const Text('Piscina Aquecida'),
            value: state.hasHeatedPool,
            onChanged: (val) => notifier.updateField(hasHeatedPool: val),
            activeColor: const Color(0xFF00AEEF),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Hidromassagem / Jacuzzi'),
            value: state.hasHotTub,
            onChanged: (val) => notifier.updateField(hasHotTub: val),
            activeColor: const Color(0xFF00AEEF),
            contentPadding: EdgeInsets.zero,
          ),
          
          const SizedBox(height: 24),
          const Text('O que tem no espaço?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableAmenities.map((am) {
              final isSelected = state.amenities.contains(am);
              return FilterChip(
                label: Text(am),
                selected: isSelected,
                selectedColor: const Color(0xFF00AEEF).withOpacity(0.2),
                checkmarkColor: const Color(0xFF00AEEF),
                onSelected: (_) => notifier.toggleAmenity(am),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          const Text('Ideal para...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableTags.map((tg) {
              final isSelected = state.tags.contains(tg);
              return FilterChip(
                label: Text(tg),
                selected: isSelected,
                selectedColor: const Color(0xFF00AEEF).withOpacity(0.2),
                checkmarkColor: const Color(0xFF00AEEF),
                onSelected: (_) => notifier.toggleTag(tg),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Regras da Casa', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('O que os convidados podem fazer?', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          SwitchListTile(title: const Text('Festas e Eventos'), value: state.allowsParties, onChanged: (val) => notifier.updateField(allowsParties: val), activeColor: const Color(0xFF00AEEF), contentPadding: EdgeInsets.zero),
          SwitchListTile(title: const Text('Fumar'), value: state.allowsSmoking, onChanged: (val) => notifier.updateField(allowsSmoking: val), activeColor: const Color(0xFF00AEEF), contentPadding: EdgeInsets.zero),
          SwitchListTile(title: const Text('Animais de Estimação (Pets)'), value: state.allowsPets, onChanged: (val) => notifier.updateField(allowsPets: val), activeColor: const Color(0xFF00AEEF), contentPadding: EdgeInsets.zero),
          SwitchListTile(title: const Text('Crianças'), value: state.allowsChildren, onChanged: (val) => notifier.updateField(allowsChildren: val), activeColor: const Color(0xFF00AEEF), contentPadding: EdgeInsets.zero),
          SwitchListTile(title: const Text('Bebida Alcoólica'), value: state.allowsAlcohol, onChanged: (val) => notifier.updateField(allowsAlcohol: val), activeColor: const Color(0xFF00AEEF), contentPadding: EdgeInsets.zero),
          SwitchListTile(title: const Text('Som Alto'), value: state.allowsLoudMusic, onChanged: (val) => notifier.updateField(allowsLoudMusic: val), activeColor: const Color(0xFF00AEEF), contentPadding: EdgeInsets.zero),
          SwitchListTile(title: const Text('Uso Comercial (Fotos/Vídeos)'), value: state.allowsCommercial, onChanged: (val) => notifier.updateField(allowsCommercial: val), activeColor: const Color(0xFF00AEEF), contentPadding: EdgeInsets.zero),
        ],
      ),
    );
  }

  Widget _buildStep6(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preço e Reservas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          DsTextField(
            label: 'Preço Base (R\$)',
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateField(price: double.tryParse(val) ?? 50.0),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.pricingMode,
            decoration: InputDecoration(labelText: 'Cobrar por', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: const [
              DropdownMenuItem(value: 'PER_HOUR', child: Text('Por Hora')),
              DropdownMenuItem(value: 'PER_DAY', child: Text('Por Dia')),
            ],
            onChanged: (val) => notifier.updateField(pricingMode: val),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: state.cancellationPolicy,
            decoration: InputDecoration(labelText: 'Política de Cancelamento', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: const [
              DropdownMenuItem(value: 'FLEXIVEL', child: Text('Flexível (Até 24h)')),
              DropdownMenuItem(value: 'MODERADO', child: Text('Moderado (Até 5 dias)')),
              DropdownMenuItem(value: 'RIGOROSO', child: Text('Rigoroso (Até 14 dias)')),
            ],
            onChanged: (val) => notifier.updateField(cancellationPolicy: val),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Reserva Instantânea'),
            subtitle: const Text('Convidados não precisam de aprovação'),
            value: !state.requiresApproval,
            onChanged: (val) => notifier.updateField(requiresApproval: !val),
            activeColor: const Color(0xFF00AEEF),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildStep7(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fotos do Espaço', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('A primeira foto será a capa do anúncio.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          
          ElevatedButton.icon(
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Escolher da Galeria'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blueAccent,
              elevation: 0,
              side: const BorderSide(color: Colors.blueAccent),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final List<XFile> images = await picker.pickMultiImage();
              if (images.isNotEmpty) {
                notifier.addImages(images);
              }
            },
          ),
          
          const SizedBox(height: 16),
          
          if (state.images.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final file = state.images[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(file.path), fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => notifier.removeImage(index),
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    if (index == 0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: const Text('CAPA', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      )
                  ],
                );
              },
            )
        ],
      ),
    );
  }
}
