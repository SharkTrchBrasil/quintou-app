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
  final int _totalPages = 5;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _cepCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(text: '50');
  final _guestsCtrl = TextEditingController(text: '10');

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Espaço criado com sucesso!')));
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
                  _buildStep1(state, notifier),
                  _buildStep2(state, notifier),
                  _buildStep3(state, notifier),
                  _buildStep4(state, notifier),
                  _buildStep5(state, notifier),
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
          const Text('Detalhes e Capacidade', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          DsTextField(
            label: 'Número Máximo de Pessoas',
            controller: _guestsCtrl,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateField(maxGuests: int.tryParse(val) ?? 10),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('O espaço é ao ar livre (Outdoor)?'),
            value: state.isOutdoor,
            onChanged: (val) => notifier.updateField(isOutdoor: val),
            activeColor: const Color(0xFF00AEEF),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(CreateSpaceState state, CreateSpaceNotifier notifier) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preço e Regras', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          DsTextField(
            label: 'Preço por Hora (R\$)',
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            onChanged: (val) => notifier.updateField(price: double.tryParse(val) ?? 50.0),
          ),
          const SizedBox(height: 32),
          const Text('O que é permitido?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Festas e Eventos'),
            value: state.allowsParties,
            onChanged: (val) => notifier.updateField(allowsParties: val),
            activeColor: const Color(0xFF00AEEF),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Fumar'),
            value: state.allowsSmoking,
            onChanged: (val) => notifier.updateField(allowsSmoking: val),
            activeColor: const Color(0xFF00AEEF),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('Animais de Estimação (Pets)'),
            value: state.allowsPets,
            onChanged: (val) => notifier.updateField(allowsPets: val),
            activeColor: const Color(0xFF00AEEF),
            contentPadding: EdgeInsets.zero,
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
          const Text('Adicione fotos do seu espaço', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Mostre os melhores ângulos. A primeira foto será a capa do anúncio.', style: TextStyle(color: Colors.grey)),
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
