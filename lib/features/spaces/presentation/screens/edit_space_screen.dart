import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:quintou_app/core/widgets/ds_button.dart';
import 'package:quintou_app/core/widgets/ds_text_field.dart';

class EditSpaceScreen extends ConsumerStatefulWidget {
  final Space space;

  const EditSpaceScreen({super.key, required this.space});

  @override
  ConsumerState<EditSpaceScreen> createState() => _EditSpaceScreenState();
}

class _EditSpaceScreenState extends ConsumerState<EditSpaceScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _deliveryFeeCtrl;
  late TextEditingController _deliveryRadiusCtrl;
  late TextEditingController _deliveryDescCtrl;

  late bool _deliveryAvailable;
  late List<String> _amenities;

  bool _isLoading = false;

  final _primaryColor = const Color(0xFF00AEEF);
  final _borderColor = Colors.grey.shade300;
  final _borderWidth = 0.5;

  final List<String> _availableAmenities = [
    'Wi-Fi', 'Som', 'TV', 'Ar Condicionado', 'Churrasqueira',
    'Forno de Pizza', 'Ducha', 'Cadeiras', 'Guarda-sol', 'Estacionamento'
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.space.title);
    _descCtrl = TextEditingController(text: widget.space.description);
    _priceCtrl = TextEditingController(text: widget.space.price.toString());
    _deliveryFeeCtrl = TextEditingController(text: widget.space.deliveryFee.toString());
    _deliveryRadiusCtrl = TextEditingController(text: widget.space.deliveryRadiusKm.toString());
    _deliveryDescCtrl = TextEditingController(text: ''); // Assuming no delivery description in the model currently, but we can set it empty

    _deliveryAvailable = widget.space.deliveryAvailable;
    _amenities = List.from(widget.space.amenities);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _deliveryFeeCtrl.dispose();
    _deliveryRadiusCtrl.dispose();
    _deliveryDescCtrl.dispose();
    super.dispose();
  }

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_amenities.contains(amenity)) {
        _amenities.remove(amenity);
      } else {
        _amenities.add(amenity);
      }
    });
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    final data = {
      'title': _titleCtrl.text,
      'description': _descCtrl.text,
      'price': double.tryParse(_priceCtrl.text) ?? widget.space.price,
      'price_per_hour': double.tryParse(_priceCtrl.text) ?? widget.space.price,
      'delivery_available': _deliveryAvailable,
      'delivery_fee': double.tryParse(_deliveryFeeCtrl.text) ?? 0.0,
      'delivery_radius_km': int.tryParse(_deliveryRadiusCtrl.text) ?? 10,
      'delivery_description': _deliveryDescCtrl.text,
      'amenities': _amenities,
    };

    try {
      final repo = ref.read(spaceRepositoryProvider);
      await repo.updateSpace(widget.space.id, data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Space updated successfully!')));
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update space: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Listing', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Basic Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DsTextField(
              title: 'Title',
              controller: _titleCtrl,
            ),
            const SizedBox(height: 16),
            DsTextField(
              title: 'Description',
              controller: _descCtrl,
            ),
            const SizedBox(height: 16),
            DsTextField(
              title: 'Price (\$)',
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
            ),
            
            if (widget.space.listingType == 'EQUIPMENT') ...[
              const Divider(height: 48),
              const Text('Delivery Options', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SwitchListTile(
                title: const Text('Offer Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
                value: _deliveryAvailable,
                onChanged: (val) => setState(() => _deliveryAvailable = val),
                activeColor: _primaryColor,
                contentPadding: EdgeInsets.zero,
              ),
              if (_deliveryAvailable) ...[
                const SizedBox(height: 16),
                DsTextField(
                  title: 'Delivery Fee (\$)',
                  controller: _deliveryFeeCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DsTextField(
                  title: 'Delivery Radius (Km)',
                  controller: _deliveryRadiusCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DsTextField(
                  title: 'Delivery Description',
                  controller: _deliveryDescCtrl,
                ),
              ],
            ],

            const Divider(height: 48),
            const Text('Amenities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableAmenities.map((am) {
                final isSelected = _amenities.contains(am);
                return GestureDetector(
                  onTap: () => _toggleAmenity(am),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: DsButton(
            label: 'Save Changes',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ),
      ),
    );
  }
}
