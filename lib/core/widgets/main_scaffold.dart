import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/admin_login_page.dart';
import '../../features/exams/presentation/pages/favorites_page.dart';
import '../../features/exams/presentation/pages/search_page.dart';
import '../theme/app_colors.dart';

/// Scaffold principal de la app con Bottom Navigation Bar.
///
/// Contiene las 3 secciones principales:
/// - Buscar ETS (público)
/// - Favoritos (público, persistentes)
/// - Admin (login y panel administrativo)
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  // Las 3 pantallas. Se mantienen vivas para preservar el estado.
  final List<Widget> _pages = [
    const SearchPage(),
    const FavoritesPage(),
    const AdminLoginPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: AppColors.guindaIpn),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star, color: AppColors.guindaIpn),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon:
                Icon(Icons.admin_panel_settings, color: AppColors.guindaIpn),
            label: 'Admin',
          ),
        ],
      ),
    );
  }
}
