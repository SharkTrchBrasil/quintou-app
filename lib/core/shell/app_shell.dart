import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quintou_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:quintou_app/features/home/presentation/screens/home_screen.dart';
import 'package:quintou_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:quintou_app/features/hosting/presentation/screens/host_dashboard_screen.dart';
import 'package:quintou_app/features/explore/presentation/screens/explore_screen.dart';
import 'package:quintou_app/features/explore/presentation/screens/search_screen.dart';
import 'package:quintou_app/features/chat/presentation/screens/conversations_screen.dart';
import 'package:quintou_app/features/chat/presentation/providers/chat_provider.dart';
import 'package:quintou_app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:quintou_app/features/bookings/presentation/screens/guest_bookings_screen.dart';
import 'package:quintou_app/features/hosting/presentation/screens/host_bookings_screen.dart';
import 'package:quintou_app/features/hosting/presentation/screens/host_listings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quintou_app/core/providers/notification_provider.dart';
import 'package:quintou_app/core/widgets/terms_consent_bottom_sheet.dart';

class IsHostModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
    _persist(state);
  }

  void setMode(bool mode) {
    state = mode;
    _persist(mode);
  }

  Future<void> _persist(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_host_mode', value);
  }
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

class HostTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setIndex(int index) => state = index;
}

final hostTabIndexProvider = NotifierProvider<HostTabIndexNotifier, int>(() {
  return HostTabIndexNotifier();
});

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // Telas do modo HÓSPEDE
  final List<Widget> _guestScreens = [
    HomeScreen(),
    SearchScreen(),
    GuestBookingsScreen(),
    ConversationsScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  // Telas do modo ANFITRIÃO
  final List<Widget> _hostScreens = [
    HostDashboardScreen(),
    HostBookingsScreen(),
    HostListingsScreen(),
    ConversationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TermsConsentBottomSheet.show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isHostMode = ref.watch(isHostModeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Se o usuário não é host, forçar modo guest
    final canBeHost = user?.isHost ?? false;
    final effectiveHostMode = isHostMode && canBeHost;

    final guestTabIndex = ref.watch(guestTabIndexProvider);
    final hostTabIndex = ref.watch(hostTabIndexProvider);
    final currentIndex = effectiveHostMode ? hostTabIndex : guestTabIndex;
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
    // Watch unread count
    final unreadAsync = ref.watch(unreadCountProvider);
    final unreadCount = unreadAsync.value ?? 0;
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => ref.read(guestTabIndexProvider.notifier).setIndex(index),
      selectedItemColor: const Color(0xFF6A1B9A), // Roxo do Quintou
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Início',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          activeIcon: Icon(Icons.search_rounded, size: 28),
          label: 'Buscar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month_rounded),
          label: 'Agendamentos',
        ),
        BottomNavigationBarItem(
          icon: unreadCount > 0
              ? Badge(
                  label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                  backgroundColor: const Color(0xFFB7F65E),
                  textColor: Colors.black,
                  child: const Icon(Icons.chat_bubble_outline_rounded),
                )
              : const Icon(Icons.chat_bubble_outline_rounded),
          activeIcon: unreadCount > 0
              ? Badge(
                  label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                  backgroundColor: const Color(0xFFB7F65E),
                  textColor: Colors.black,
                  child: const Icon(Icons.chat_bubble_rounded),
                )
              : const Icon(Icons.chat_bubble_rounded),
          label: 'Mensagens',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border_rounded),
          activeIcon: Icon(Icons.favorite_rounded),
          label: 'Favoritos',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }

  Widget _buildHostNavBar(int currentIndex) {
    final unreadAsync = ref.watch(unreadNotificationsCountProvider);
    final unreadCount = unreadAsync.value ?? 0;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) => ref.read(hostTabIndexProvider.notifier).setIndex(index),
      selectedItemColor: const Color(0xFF6A1B9A), // Roxo do Quintou
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'Painel',
        ),
         const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: 'Agendamentos',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.view_list_outlined),
          activeIcon: Icon(Icons.view_list_rounded),
          label: 'Anúncios',
        ),
        BottomNavigationBarItem(
          icon: unreadCount > 0
              ? Badge(
                  label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                  backgroundColor: const Color(0xFFB7F65E),
                  textColor: Colors.black,
                  child: const Icon(Icons.chat_bubble_outline_rounded),
                )
              : const Icon(Icons.chat_bubble_outline_rounded),
          activeIcon: unreadCount > 0
              ? Badge(
                  label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                  backgroundColor: const Color(0xFFB7F65E),
                  textColor: Colors.black,
                  child: const Icon(Icons.chat_bubble_rounded),
                )
              : const Icon(Icons.chat_bubble_rounded),
          label: 'Mensagens',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
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

