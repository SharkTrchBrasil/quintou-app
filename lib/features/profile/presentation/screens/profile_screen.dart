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
              child: const Text('Edit profile', style: TextStyle(color: Color(0xFFB7F65E), fontSize: 16)),
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
                  'Hey, ${user.fullName.split(" ").first}!',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: const Text(
                  'Profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                  child: const Text('Log In or Sign Up', style: TextStyle(color: Color(0xFF171E0E), fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Promo Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB7F65E), Color(0xFF90D91E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pool, color: Color(0xFFB7F65E)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Get the 2026 Summer pass!', style: TextStyle(color: Color(0xFF171E0E), fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Enjoy \$0 in service fees, earn free bookings, and get priority support.', style: TextStyle(color: Color(0xFF171E0E), fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF171E0E)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
            
            // Refer a friend
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: const Text('Gift \$10, Earn \$10!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              subtitle: const Text('Earn up to \$1,000 in credits sharing Quintou!', style: TextStyle(fontSize: 14, color: Colors.grey)),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {},
            ),
            
            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
            
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Account Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            
            _buildMenuItem('Profile'),
            _buildMenuItem('Account'),
            _buildMenuItem('Payment methods'),
            _buildMenuItem('Notifications', badgeText: 'REVIEW'),
            _buildMenuItem('Guest verification'),
            _buildMenuItem('Favorites'),
            
            if (user != null && user.isHost) ...[
              const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: const Text('Switch to Hosting', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                title: const Text('Log out', style: TextStyle(fontSize: 16, color: Colors.red)),
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
