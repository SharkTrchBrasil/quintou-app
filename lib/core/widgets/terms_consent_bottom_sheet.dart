import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class TermsConsentBottomSheet extends StatefulWidget {
  const TermsConsentBottomSheet({super.key});

  /// Metodo estatico para mostrar o BottomSheet
  static Future<void> show(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasAccepted = prefs.getBool('has_accepted_terms_v1') ?? false;

    if (!hasAccepted && context.mounted) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (context) => const TermsConsentBottomSheet(),
      );
    }
  }

  @override
  State<TermsConsentBottomSheet> createState() => _TermsConsentBottomSheetState();
}

class _TermsConsentBottomSheetState extends State<TermsConsentBottomSheet> {
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _acceptHostTerms = false;
  bool _acceptGuestTerms = false;
  bool _acceptCancellation = false;
  
  bool _showError = false;

  Future<void> _saveAndClose() async {
    if (!_acceptTerms || !_acceptPrivacy || !_acceptHostTerms || !_acceptGuestTerms || !_acceptCancellation) {
      setState(() {
        _showError = true;
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_accepted_terms_v1', true);
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _acceptAllAndClose() async {
    setState(() {
      _acceptTerms = true;
      _acceptPrivacy = true;
      _acceptHostTerms = true;
      _acceptGuestTerms = true;
      _acceptCancellation = true;
      _showError = false;
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_accepted_terms_v1', true);
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos a altura máxima para não ocupar a tela inteira se não precisar
    final maxHeight = MediaQuery.of(context).size.height * 0.9;
    final primaryColor = const Color(0xFF6A1B9A); // Roxo principal
    final orangeColor = Colors.deepOrange; // Botão igual a referência

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Tracinho no topo (drag handle)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: primaryColor),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Consentimento de Termos',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    'Precisamos da sua permissão para os termos essenciais de uso da plataforma Quintou. Ao aceitar, você concorda com as nossas regras para poder acessar o app:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 24),

                  if (_showError)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Você precisa aceitar todos os termos e políticas para usar o app.',
                              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  _buildSwitchTile(
                    title: 'Termos de Uso',
                    description: 'Concordo com as regras e condições de uso do aplicativo e serviços Quintou.',
                    value: _acceptTerms,
                    onChanged: (val) => setState(() {
                      _acceptTerms = val;
                      _showError = false;
                    }),
                    onTapLink: () => context.push('/legal', extra: 0),
                  ),
                  
                  _buildSwitchTile(
                    title: 'Política de Privacidade',
                    description: 'Autorizo o tratamento dos meus dados pessoais em conformidade com as leis vigentes.',
                    value: _acceptPrivacy,
                    onChanged: (val) => setState(() {
                      _acceptPrivacy = val;
                      _showError = false;
                    }),
                    onTapLink: () => context.push('/legal', extra: 1),
                  ),

                  _buildSwitchTile(
                    title: 'Termos do Proprietário',
                    description: 'Concordo com as responsabilidades e direitos ao hospedar em minha propriedade.',
                    value: _acceptHostTerms,
                    onChanged: (val) => setState(() {
                      _acceptHostTerms = val;
                      _showError = false;
                    }),
                    onTapLink: () => context.push('/legal', extra: 2),
                  ),

                  _buildSwitchTile(
                    title: 'Termos do Hóspede',
                    description: 'Estou ciente das regras de conduta e comportamento esperado como hóspede.',
                    value: _acceptGuestTerms,
                    onChanged: (val) => setState(() {
                      _acceptGuestTerms = val;
                      _showError = false;
                    }),
                    onTapLink: () => context.push('/legal', extra: 3),
                  ),

                  _buildSwitchTile(
                    title: 'Política de Cancelamento',
                    description: 'Compreendo as condições de reembolso e penalidades para cancelamentos.',
                    value: _acceptCancellation,
                    onChanged: (val) => setState(() {
                      _acceptCancellation = val;
                      _showError = false;
                    }),
                    onTapLink: () => context.push('/legal', extra: 4),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Rodapé fixo com os botões
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _saveAndClose,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _acceptAllAndClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orangeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Aceito todos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    required VoidCallback onTapLink,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: (_showError && !value) ? Colors.red.shade700 : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onTapLink,
                      child: const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6A1B9A),
          ),
        ],
      ),
    );
  }
}
