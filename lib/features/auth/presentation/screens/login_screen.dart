import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/core/widgets/ds_text_field.dart';
import 'package:quintou_app/core/widgets/ds_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() async {
    final success = await ref.read(authProvider.notifier).login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      // Se logou com sucesso, volta para onde estava ou para home
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bem-vindo de volta!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
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
            DsTextField(
              controller: _emailController,
              title: 'E-mail',
              hint: 'Digite seu e-mail',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DsTextField(
              controller: _passwordController,
              title: 'Senha',
              hint: 'Sua senha secreta',
              obscureText: true,
            ),
            const SizedBox(height: 32),
            DsButton(
              label: 'Entrar',
              onPressed: authState.isLoading ? null : _handleLogin,
              isLoading: authState.isLoading,
              isDisabled: authState.isLoading,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Não tem uma conta? ',
                  style: TextStyle(color: Colors.black54),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).clearError();
                    context.push('/register');
                  },
                  child: const Text(
                    'Cadastre-se',
                    style: TextStyle(color: Color(0xFFB7F65E), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
