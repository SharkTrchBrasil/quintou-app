import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/features/home/presentation/screens/home_screen.dart';
import 'package:quintou_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:quintou_app/features/hosting/presentation/screens/host_dashboard_screen.dart';

// Provider para controlar se o usuário está no modo anfitrião
final isHostModeProvider = StateProvider<bool>((ref) => false);

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _guestTabIndex = 2; // Home é o centro (Swimply style)
  int _hostTabIndex = 0;

  // Telas do modo HÓSPEDE
  final List<Widget> _guestScreens = const [
    _PlaceholderScreen(title: 'Explore', icon: Icons.search),
    _PlaceholderScreen(title: 'For You', icon: Icons.favorite),
    HomeScreen(),
    _PlaceholderScreen(title: 'Chat', icon: Icons.chat_bubble_outline),
    ProfileScreen(),
  ];

  // Telas do modo ANFITRIÃO
  final List<Widget> _hostScreens = const [
    HostDashboardScreen(),
    _PlaceholderScreen(title: 'Bookings', icon: Icons.calendar_today),
    _PlaceholderScreen(title: 'Listings', icon: Icons.home_work),
    _PlaceholderScreen(title: 'Inbox', icon: Icons.inbox),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isHostMode = ref.watch(isHostModeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Se o usuário não é host, forçar modo guest
    final canBeHost = user?.isHost ?? false;
    final effectiveHostMode = isHostMode && canBeHost;

    final currentIndex = effectiveHostMode ? _hostTabIndex : _guestTabIndex;
    final screens = effectiveHostMode ? _hostScreens : _guestScreens;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: effectiveHostMode
          ? _buildHostNavBar(currentIndex)
          : _buildGuestNavBar(currentIndex),
    );
  }

  Widget _buildGuestNavBar(int currentIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00AEEF),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) => setState(() => _guestTabIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'For You'),
        BottomNavigationBarItem(
          icon: Icon(Icons.wb_sunny_outlined),
          activeIcon: Icon(Icons.wb_sunny),
          label: 'Home',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }

  Widget _buildHostNavBar(int currentIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00AEEF),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) => setState(() => _hostTabIndex = index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Hosting'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'Listings'),
        BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}

// Placeholder para telas que ainda não foram implementadas
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 20, color: Colors.grey.shade400)),
            const SizedBox(height: 8),
            Text('Coming soon', style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }
}
