import 'package:brasil_fields/brasil_fields.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/core/widgets/ds_text_field.dart';
import 'package:quintou_app/core/widgets/ds_button.dart';
import 'package:dio/dio.dart';
import 'package:quintou_app/core/providers/providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _currentStep = 1;
  bool _isLookingUpCpf = false;
  bool _cpfLookedUp = false;
  String? _cpfError;
  bool _isHost = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _lookupCpf(String cpfFormatted) async {
    final cpfClean = cpfFormatted.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cpfClean.length != 11) {
      setState(() {
        _cpfLookedUp = false;
        _cpfError = null;
        _nameController.text = '';
      });
      return;
    }

    if (!CPFValidator.isValid(cpfClean)) {
      setState(() {
        _cpfError = 'CPF inválido';
        _cpfLookedUp = false;
        _nameController.text = '';
      });
      return;
    }

    setState(() {
      _isLookingUpCpf = true;
      _cpfError = null;
    });

    try {
      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.post(
        '/auth/lookup-cpf',
        data: {'cpf': cpfClean},
      );
      
      if (!mounted) return;
      
      final data = response.data;
      if (data['is_valid'] == true) {
        setState(() {
          _cpfLookedUp = true;
          _cpfError = null;
          _nameController.text = data['real_name'] ?? 'Usuário Visitante';
        });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _currentStep = 2);
        });
      } else {
        setState(() {
          _cpfError = data['error_message'] ?? 'CPF inválido';
          _cpfLookedUp = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cpfError = 'Erro de conexão. Verifique sua internet.';
          _cpfLookedUp = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLookingUpCpf = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'E-mail é obrigatório';
    if (!EmailValidator.validate(value)) return 'E-mail inválido';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Telefone é obrigatório';
    try {
      final phone = PhoneNumber.parse(value, destinationCountry: IsoCode.BR);
      if (!phone.isValid(type: PhoneNumberType.mobile)) return 'Número de celular inválido';
      return null;
    } catch (e) {
      return 'Número inválido';
    }
  }

  String? _validateCPF(String? value) {
    if (value == null || value.isEmpty) return 'CPF é obrigatório';
    final cleanCPF = value.replaceAll(RegExp(r'[^\d]'), '');
    if (!CPFValidator.isValid(cleanCPF)) return 'CPF inválido';
    if (!_cpfLookedUp) return _cpfError ?? 'Aguarde a validação do CPF';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String phoneToSend = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      
      final success = await ref.read(authProvider.notifier).register(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        cpf: _cpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
        phone: phoneToSend,
        isHost: _isHost,
      );

      if (success && mounted) {
        context.go('/');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (_currentStep == 2) {
              setState(() => _currentStep = 1);
            } else if (_currentStep == 3) {
              setState(() => _currentStep = 2);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (authState.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        color: Colors.red.shade100,
                        child: Text(
                          authState.error!,
                          style: TextStyle(color: Colors.red.shade900),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                    if (_currentStep == 1) ...[
                      const Text('Qual o seu CPF?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 8),
                      Text('Precisamos dele para criar sua conta de forma segura.', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                      const SizedBox(height: 32),
                      
                      DsTextField(
                        controller: _cpfController,
                        title: 'CPF',
                        hint: '000.000.000-00',
                        keyboardType: TextInputType.number,
                        formatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, CpfInputFormatter()],
                        enabled: !_cpfLookedUp,
                        onChanged: (val) => _lookupCpf(val),
                        validator: _validateCPF,
                        suffixIcon: _isLookingUpCpf
                            ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB7F65E)))
                            : _cpfLookedUp ? const Icon(Icons.check_circle, color: Colors.green, size: 22) : null,
                      ),
                      if (_cpfError != null) ...[
                        const SizedBox(height: 6),
                        Text(_cpfError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                      if (_cpfLookedUp && _nameController.text.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.verified, color: Colors.green, size: 16),
                            const SizedBox(width: 4),
                            Expanded(child: Text('CPF validado na Receita Federal', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w500))),
                          ],
                        ),
                      ],
                      const SizedBox(height: 40),
                      DsButton(
                        label: 'Continuar',
                        onPressed: _cpfLookedUp ? () => setState(() => _currentStep = 2) : null,
                        isLoading: _isLookingUpCpf,
                        isDisabled: !_cpfLookedUp || _isLookingUpCpf,
                      ),
                    ] else if (_currentStep == 2) ...[
                      Text('Seja bem vindo(a),\n${_nameController.text.split(' ').first}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 8),
                      const Text('Agora só faltam seus dados de contato e senha.', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 32),
                      
                      DsTextField(
                        controller: _emailController,
                        title: 'E-mail',
                        hint: 'Digite seu e-mail',
                        keyboardType: TextInputType.emailAddress,
                        formatters: <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]'))],
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      DsTextField(
                        controller: _phoneController,
                        title: 'Celular',
                        hint: '(11) 99999-9999',
                        keyboardType: TextInputType.phone,
                        formatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()],
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 20),
                      DsTextField(
                        controller: _passwordController,
                        title: 'Senha',
                        hint: 'Mínimo 8 caracteres',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 40),
                      DsButton(
                        label: 'Continuar',
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _currentStep = 3);
                          }
                        },
                      ),
                    ] else if (_currentStep == 3) ...[
                      const Text('Último passo!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 8),
                      const Text('O que você deseja fazer no Quintou?', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isHost = false),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: !_isHost ? const Color(0xFFB7F65E).withOpacity(0.1) : Colors.white,
                                border: Border.all(
                                  color: !_isHost ? const Color(0xFFB7F65E) : Colors.grey.shade300,
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Quero alugar espaços', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        SizedBox(height: 4),
                                        Text('Encontre locais incríveis para relaxar ou celebrar.', style: TextStyle(color: Colors.black54)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => setState(() => _isHost = true),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _isHost ? const Color(0xFFB7F65E).withOpacity(0.1) : Colors.white,
                                border: Border.all(
                                  color: _isHost ? const Color(0xFFB7F65E) : Colors.grey.shade300,
                                  width: 0.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Quero anunciar meu espaço', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        SizedBox(height: 4),
                                        Text('Ganhe dinheiro alugando sua piscina, quadra ou salão.', style: TextStyle(color: Colors.black54)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      DsButton(
                        label: 'Criar Conta',
                        onPressed: authState.isLoading || _isLoading ? null : _handleRegister,
                        isLoading: authState.isLoading || _isLoading,
                        isDisabled: authState.isLoading || _isLoading,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
