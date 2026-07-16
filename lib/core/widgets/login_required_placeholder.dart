import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';

class LoginRequiredPlaceholder extends StatelessWidget {
  final String title;
  final String message;
  final String subMessage;
  final IconData icon;

  const LoginRequiredPlaceholder({
    super.key,
    required this.title,
    required this.message,
    required this.subMessage,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Icon with some "scribble" background inspiration
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: 64,
                    color: Colors.black87,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed: () {
                        ref.read(authProvider.notifier).clearError();
                        context.push('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF05A28), // Laranja vibrante igual a referência
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Entrar ou Inscrever-se',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                ),
              ),
              const SizedBox(height: 32), // bottom spacing
            ],
          ),
        ),
      ),
    );
  }
}
