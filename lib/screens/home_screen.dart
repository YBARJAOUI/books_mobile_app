import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'books_screen.dart';
import 'customers_screen.dart';
import 'orders_screen.dart';
import 'packs_screen.dart';
import 'daily_offers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const BooksScreen(),
    const CustomersScreen(),
    const OrdersScreen(),
    const PacksScreen(),
    const DailyOffersScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Tableau de bord',
    ),
    NavigationItem(
      icon: Icons.book_outlined,
      selectedIcon: Icons.book,
      label: 'Livres',
    ),
    NavigationItem(
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      label: 'Clients',
    ),
    NavigationItem(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: 'Commandes',
    ),
    NavigationItem(
      icon: Icons.inventory_outlined,
      selectedIcon: Icons.inventory,
      label: 'Packs',
    ),
    NavigationItem(
      icon: Icons.local_offer_outlined,
      selectedIcon: Icons.local_offer,
      label: 'Offres du jour',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.read<AppStateProvider>().setSelectedNavIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Navigation rail pour écrans larges
          if (constraints.maxWidth >= 800) {
            return Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  extended: constraints.maxWidth >= 1200,
                  minExtendedWidth: 200,
                  backgroundColor: Colors.grey[50],
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
                Expanded(child: _screens[_selectedIndex]),
              ],
            );
          }
          // Bottom navigation pour écrans petits
          else {
            return Scaffold(
              body: _screens[_selectedIndex],
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: Colors.grey,
                items:
                    _navigationItems.take(5).map((item) {
                      return BottomNavigationBarItem(
                        icon: Icon(item.icon),
                        activeIcon: Icon(item.selectedIcon),
                        label:
                            item.label.length > 10
                                ? item.label.substring(0, 10) + '...'
                                : item.label,
                      );
                    }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<AppStateProvider>(
            builder: (context, appState, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 8),
                    Text(appState.currentUser),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2;
            if (constraints.maxWidth >= 1200) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth >= 800) {
              crossAxisCount = 3;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue dans le back-office',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gérez votre librairie facilement',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildDashboardCard(
                      context,
                      'Livres',
                      Icons.book,
                      Colors.blue,
                      'Gérer le catalogue',
                      '150 livres',
                    ),
                    _buildDashboardCard(
                      context,
                      'Clients',
                      Icons.people,
                      Colors.green,
                      'Gérer les clients',
                      '85 clients',
                    ),
                    _buildDashboardCard(
                      context,
                      'Commandes',
                      Icons.shopping_cart,
                      Colors.orange,
                      'Gérer les commandes',
                      '23 commandes',
                    ),
                    _buildDashboardCard(
                      context,
                      'Packs',
                      Icons.inventory,
                      Colors.purple,
                      'Gérer les packs',
                      '12 packs',
                    ),
                    _buildDashboardCard(
                      context,
                      'Offres',
                      Icons.local_offer,
                      Colors.red,
                      'Offres spéciales',
                      '5 offres actives',
                    ),
                    _buildDashboardCard(
                      context,
                      'Statistiques',
                      Icons.analytics,
                      Colors.teal,
                      'Voir les stats',
                      'Rapports',
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    String stats,
  ) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigation vers la section appropriée
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigation vers $title'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 32, color: color),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      stats,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
