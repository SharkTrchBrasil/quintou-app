import 'package:go_router/go_router.dart';
import 'package:quintou_app/features/home/presentation/screens/home_screen.dart';
import 'package:quintou_app/features/auth/presentation/screens/login_screen.dart';
import 'package:quintou_app/features/auth/presentation/screens/register_screen.dart';
import 'package:quintou_app/features/spaces/presentation/screens/space_details_screen.dart';
import 'package:quintou_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:quintou_app/features/bookings/presentation/screens/booking_setup_screen.dart';
import 'package:quintou_app/core/shell/app_shell.dart';
import 'package:quintou_app/core/models/space_model.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AppShell(),
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
      path: '/booking-setup',
      builder: (context, state) {
        final space = state.extra as Space;
        return BookingSetupScreen(space: space);
      },
    ),
  ],
);

