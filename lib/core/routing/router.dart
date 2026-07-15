import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/features/explore/presentation/screens/detailed_search_screen.dart';
import 'package:quintou_app/features/home/presentation/screens/home_screen.dart';
import 'package:quintou_app/features/auth/presentation/screens/login_screen.dart';
import 'package:quintou_app/features/auth/presentation/screens/register_screen.dart';
import 'package:quintou_app/features/spaces/presentation/screens/space_details_screen.dart';
import 'package:quintou_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:quintou_app/features/bookings/presentation/screens/booking_setup_screen.dart';
import 'package:quintou_app/features/spaces/presentation/screens/create_space_screen.dart';
import 'package:quintou_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:quintou_app/features/chat/data/models/conversation_model.dart';
import 'package:quintou_app/core/shell/app_shell.dart';
import 'package:quintou_app/core/models/space_model.dart';
import 'package:quintou_app/features/profile/presentation/screens/legal_screen.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/core/services/secure_storage_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:quintou_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:quintou_app/features/profile/presentation/screens/notifications_screen.dart';

// Global reference to ProviderContainer for auth checks
late ProviderContainer _container;

void setProviderContainer(ProviderContainer container) {
  _container = container;
}

final goRouter = GoRouter(
  initialLocation: '/',
  observers: [BotToastNavigatorObserver()],
  redirect: (context, state) async {
    // Check onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    
    if (!hasSeenOnboarding && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }

    // Check if user is authenticated
    final hasTokens = await SecureStorageService.hasTokens();
    final authState = _container.read(authProvider);
    final isLoggedIn = hasTokens && authState.user != null;
    
    final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
    final isProtectedRoute = _isProtectedRoute(state.matchedLocation);
    
    // If not logged in and trying to access protected route, redirect to login
    if (!isLoggedIn && isProtectedRoute) {
      return '/login';
    }
    
    // If logged in and trying to access auth routes, redirect to home
    if (isLoggedIn && isAuthRoute) {
      return '/';
    }
    
    return null; // No redirect needed
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const AppShell(),
    ),
    GoRoute(
      path: '/detailed-search',
      builder: (context, state) => const DetailedSearchScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/space-details',
      builder: (context, state) {
        final space = state.extra as Space;
        return SpaceDetailsScreen(space: space);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/legal',
      builder: (context, state) {
        final initialTab = state.extra as int? ?? 0;
        return LegalScreen(initialTab: initialTab);
      },
    ),
    GoRoute(
      path: '/booking-setup',
      builder: (context, state) {
        final space = state.extra as Space;
        return BookingSetupScreen(space: space);
      },
    ),
    GoRoute(
      path: '/create-space',
      builder: (context, state) => const CreateSpaceScreen(),
    ),
    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final conv = state.extra as Conversation;
        return ChatScreen(conversation: conv);
      },
    ),
    // Stripe Onboarding Return Deep Links
    GoRoute(
      path: '/stripe/success',
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          BotToast.showText(text: 'Conta Stripe configurada com sucesso!');
          context.go('/profile');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ),
    GoRoute(
      path: '/stripe/refresh',
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          BotToast.showText(text: 'Sessão Stripe expirou. Tente novamente.');
          context.go('/profile');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    // 404 Not Found route
    GoRoute(
      path: '/404',
      builder: (context, state) => const NotFoundScreen(),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundScreen(),
);

bool _isProtectedRoute(String path) {
  const protectedPaths = [
    '/profile',
    '/booking-setup',
    '/create-space', 
    '/chat',
  ];
  
  return protectedPaths.any((protectedPath) => path.startsWith(protectedPath));
}

// Simple 404 screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Ops! Página não encontrada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'A página que você está procurando não existe.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

