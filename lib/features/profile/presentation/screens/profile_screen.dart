import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/core/shell/app_shell.dart';
import 'package:quintou_app/core/providers/providers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (user != null)
            TextButton(
              onPressed: () {
                // Edit profile logic
              },
              child: const Text('Editar perfil', style: TextStyle(color: Color(0xFFB7F65E), fontSize: 16)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                      child: user.avatarUrl == null ? const Icon(Icons.person, size: 40) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Olá, ${user.fullName.split(" ").first}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: const Text(
                  'Perfil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB7F65E),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.push('/login'),
                  child: const Text('Entrar ou Cadastrar', style: TextStyle(color: Color(0xFF171E0E), fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            const SizedBox(height: 24),
            
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Configurações da Conta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            _buildMenuItem('Perfil'),
            _buildMenuItem('Conta'),
            _buildMenuItem('Métodos de pagamento'),
            _buildMenuItem('Notificações', badgeText: 'REVISAR'),
            _buildMenuItem('Verificação de hóspede'),
            _buildMenuItem(
              'Favoritos', 
              onTap: () {
                // Navega para a aba de favoritos (índice 3)
                ref.read(guestTabIndexProvider.notifier).setIndex(3);
                // Retorna para a tela principal (fecha o perfil, caso o perfil não seja parte do shell principal, 
                // mas na verdade o perfil é a aba índice 4, então só de mudar o índice o shell atualiza).
              }
            ),
            
            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
            
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Legal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            
            _buildMenuItem('Termos de Uso', onTap: () => context.push('/legal', extra: 0)),
            _buildMenuItem('Política de Privacidade', onTap: () => context.push('/legal', extra: 1)),
            _buildMenuItem('Termos do Proprietário', onTap: () => context.push('/legal', extra: 2)),
            _buildMenuItem('Termos do Hóspede', onTap: () => context.push('/legal', extra: 3)),
            _buildMenuItem('Política de Cancelamento', onTap: () => context.push('/legal', extra: 4)),
            
            if (user != null && user.isHost) ...[
              const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: const Text('Mudar para Proprietário', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                trailing: Switch(
                  value: ref.watch(isHostModeProvider),
                  activeColor: const Color(0xFFB7F65E),
                  onChanged: (value) {
                    ref.read(isHostModeProvider.notifier).setMode(value);
                  },
                ),
              ),
              _buildMenuItem(
                'Configurar Recebimentos',
                badgeText: user.stripeOnboardingComplete ? 'OK' : 'PENDENTE',
                onTap: () async {
                  try {
                    final dio = ref.read(apiClientProvider).dio;
                    final res = await dio.post('/payments/onboarding');
                    final url = res.data['url'];
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    }
                  } on DioException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.response?.data?['detail']?.toString() ?? 'Erro ao conectar com Stripe')),
                    );
                  }
                },
              ),
            ],
            
            if (user != null) ...[
              const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: const Text('Sair', style: TextStyle(fontSize: 16, color: Colors.red)),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                },
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, {String? badgeText, VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          title: Text(title, style: const TextStyle(fontSize: 16, color: Colors.black87)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB7F65E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(badgeText, style: const TextStyle(color: Color(0xFF171E0E), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
          onTap: onTap ?? () {},
        ),
        const Divider(thickness: 1, color: Color(0xFFF5F5F5), height: 1, indent: 24, endIndent: 24),
      ],
    );
  }
}
