import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/features/home/presentation/screens/home_screen.dart';
import 'package:quintou_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:quintou_app/features/hosting/presentation/screens/host_dashboard_screen.dart';
import 'package:quintou_app/features/explore/presentation/screens/explore_screen.dart';
import 'package:quintou_app/features/explore/presentation/screens/search_screen.dart';

class IsHostModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void setMode(bool mode) => state = mode;
}

final isHostModeProvider = NotifierProvider<IsHostModeNotifier, bool>(() {
  return IsHostModeNotifier();
});

class GuestTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int index) => state = index;
}

final guestTabIndexProvider = NotifierProvider<GuestTabIndexNotifier, int>(() {
  return GuestTabIndexNotifier();
});

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _hostTabIndex = 0;

  // Telas do modo HÓSPEDE
  final List<Widget> _guestScreens = const [
    HomeScreen(),
    SearchScreen(),
    _PlaceholderScreen(title: 'Chat', icon: Icons.chat_bubble_outline),
    _PlaceholderScreen(title: 'Favoritos', icon: Icons.favorite),
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

    final guestTabIndex = ref.watch(guestTabIndexProvider);
    final currentIndex = effectiveHostMode ? _hostTabIndex : guestTabIndex;
    final screens = effectiveHostMode ? _hostScreens : _guestScreens;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: effectiveHostMode
            ? _buildHostNavBar(currentIndex)
            : _buildGuestNavBar(currentIndex),
      ),
    );
  }

  Widget _buildGuestNavBar(int currentIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => ref.read(guestTabIndexProvider.notifier).setIndex(index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.wb_sunny_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorar'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    );
  }

  Widget _buildHostNavBar(int currentIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
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
