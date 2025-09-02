import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/responsive_layout.dart';

class HomeScreen extends StatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Tableau de bord',
      route: '/dashboard',
    ),
    NavigationItem(
      icon: Icons.book_outlined,
      selectedIcon: Icons.book,
      label: 'Livres',
      route: '/books',
    ),
    NavigationItem(
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      label: 'Clients',
      route: '/customers',
    ),
    NavigationItem(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: 'Commandes',
      route: '/orders',
    ),
    NavigationItem(
      icon: Icons.inventory_outlined,
      selectedIcon: Icons.inventory,
      label: 'Packs',
      route: '/packs',
    ),
    NavigationItem(
      icon: Icons.local_offer_outlined,
      selectedIcon: Icons.local_offer,
      label: 'Offres du jour',
      route: '/daily-offers',
    ),
  ];

  int get _selectedIndex {
    final currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    for (int i = 0; i < _navigationItems.length; i++) {
      if (currentRoute.startsWith(_navigationItems[i].route)) {
        return i;
      }
    }
    return 0;
  }

  void _onDestinationSelected(int index) {
    final route = _navigationItems[index].route;
    context.go(route);
    context.read<AppStateProvider>().setSelectedNavLocation(route);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations:
            _navigationItems.map((item) {
              return NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: _truncateLabel(item.label, 10),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            extended: false,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            destinations:
                _navigationItems.map((item) {
                  return NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.label),
                  );
                }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            extended: true,
            minExtendedWidth: 240,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.store,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Backoffice',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer<AppStateProvider>(
                    builder: (context, appState, child) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              appState.currentUser[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            appState.currentUser,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: const Text('Administrateur'),
                          trailing: PopupMenuButton(
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    child: ListTile(
                                      leading: Icon(Icons.person),
                                      title: Text('Profil'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    child: ListTile(
                                      leading: Icon(Icons.settings),
                                      title: Text('Paramètres'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    child: ListTile(
                                      leading: Icon(Icons.logout),
                                      title: Text('Déconnexion'),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            destinations:
                _navigationItems.map((item) {
                  return NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Icon(item.selectedIcon),
                    label: Text(item.label),
                  );
                }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [_buildTopBar(), Expanded(child: widget.child)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _getPageTitle(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          // Barre de recherche rapide (optionnel)
          Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Recherche rapide...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    final currentRoute =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final item = _navigationItems.firstWhere(
      (item) => currentRoute.startsWith(item.route),
      orElse: () => _navigationItems.first,
    );
    return item.label;
  }

  String _truncateLabel(String label, int maxLength) {
    return label.length > maxLength
        ? '${label.substring(0, maxLength)}...'
        : label;
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
