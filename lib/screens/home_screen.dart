import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';

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
      label: 'لوحة التحكم',
      route: '/dashboard',
    ),
    NavigationItem(
      icon: Icons.book_outlined,
      selectedIcon: Icons.book,
      label: 'الكتب',
      route: '/books',
    ),
    NavigationItem(
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      label: 'العملاء',
      route: '/customers',
    ),
  ];

  int get _selectedIndex {
    final currentRoute = GoRouterState.of(context).uri.path;
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
    return Scaffold(
      drawer: _buildDrawer(context),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onDestinationSelected,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        items:
            _navigationItems.map((item) {
              return BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.selectedIcon),
                label: item.label,
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.store, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'إدارة المكتبة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'نظام إدارة المكتبة',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = _selectedIndex == index;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  child: ListTile(
                    leading: Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey[600],
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[800],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      _onDestinationSelected(index);
                      Navigator.of(context).pop(); // إغلاق القائمة الجانبية
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return ListTile(
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
                title: Text(appState.currentUser),
                subtitle: const Text('المدير'),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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
