import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../utils/responsive_layout.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          ResponsiveLayout.isMobile(context)
              ? AppBar(
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
              )
              : null,
      body: SingleChildScrollView(
        padding: ResponsiveSpacing.getAllPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(context),
            SizedBox(height: ResponsiveSpacing.xl),
            _buildStatsSection(context),
            SizedBox(height: ResponsiveSpacing.xl),
            _buildQuickActionsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(ResponsiveSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenue, ${appState.currentUser}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.sm),
              Text(
                'Gérez votre librairie facilement avec ce tableau de bord',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              if (!ResponsiveLayout.isMobile(context)) ...[
                SizedBox(height: ResponsiveSpacing.lg),
                Row(
                  children: [
                    _buildQuickStat('150', 'Livres', Icons.book),
                    SizedBox(width: ResponsiveSpacing.xl),
                    _buildQuickStat('85', 'Clients', Icons.people),
                    SizedBox(width: ResponsiveSpacing.xl),
                    _buildQuickStat('23', 'Commandes', Icons.shopping_cart),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final stats = [
      DashboardStat('Livres', '150', Icons.book, Colors.blue, '/books'),
      DashboardStat('Clients', '85', Icons.people, Colors.green, '/customers'),
      DashboardStat(
        'Commandes',
        '23',
        Icons.shopping_cart,
        Colors.orange,
        '/orders',
      ),
      DashboardStat('Packs', '12', Icons.inventory, Colors.purple, '/packs'),
      DashboardStat(
        'Offres',
        '5',
        Icons.local_offer,
        Colors.red,
        '/daily-offers',
      ),
      DashboardStat('Revenus', '€2,450', Icons.euro, Colors.teal, '/dashboard'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: ResponsiveSpacing.md),
        ResponsiveLayout(
          mobile: _buildStatsGrid(context, stats, 2),
          tablet: _buildStatsGrid(context, stats, 3),
          desktop: _buildStatsGrid(context, stats, 6),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    List<DashboardStat> stats,
    int columns,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 1.5,
        crossAxisSpacing: ResponsiveSpacing.md,
        mainAxisSpacing: ResponsiveSpacing.md,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(context, stat);
      },
    );
  }

  Widget _buildStatCard(BuildContext context, DashboardStat stat) {
    return Card(
      child: InkWell(
        onTap: () => context.go(stat.route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat.icon,
                size: ResponsiveLayout.isMobile(context) ? 32 : 40,
                color: stat.color,
              ),
              SizedBox(height: ResponsiveSpacing.sm),
              Text(
                stat.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: stat.color,
                ),
              ),
              Text(
                stat.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    final actions = [
      QuickAction(
        'Nouveau Livre',
        'Ajouter un livre au catalogue',
        Icons.add_circle_outline,
        Colors.blue,
        () => context.go('/books/new'),
      ),
      QuickAction(
        'Nouveau Client',
        'Enregistrer un nouveau client',
        Icons.person_add_outlined,
        Colors.green,
        () => context.go('/customers/new'),
      ),
      QuickAction(
        'Nouveau Pack',
        'Créer un nouveau pack',
        Icons.inventory_2_outlined,
        Colors.purple,
        () => context.go('/packs/new'),
      ),
      QuickAction(
        'Nouvelle Offre',
        'Créer une offre du jour',
        Icons.local_offer_outlined,
        Colors.red,
        () => context.go('/daily-offers/new'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: ResponsiveSpacing.md),
        ResponsiveLayout(
          mobile: _buildActionsColumn(context, actions),
          tablet: _buildActionsGrid(context, actions, 2),
          desktop: _buildActionsGrid(context, actions, 4),
        ),
      ],
    );
  }

  Widget _buildActionsColumn(BuildContext context, List<QuickAction> actions) {
    return Column(
      children:
          actions
              .map(
                (action) => Container(
                  margin: EdgeInsets.only(bottom: ResponsiveSpacing.md),
                  child: _buildActionCard(context, action),
                ),
              )
              .toList(),
    );
  }

  Widget _buildActionsGrid(
    BuildContext context,
    List<QuickAction> actions,
    int columns,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 1.2,
        crossAxisSpacing: ResponsiveSpacing.md,
        mainAxisSpacing: ResponsiveSpacing.md,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return _buildActionCard(context, actions[index]);
      },
    );
  }

  Widget _buildActionCard(BuildContext context, QuickAction action) {
    return Card(
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(ResponsiveSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveSpacing.md),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  size: ResponsiveLayout.isMobile(context) ? 28 : 32,
                  color: action.color,
                ),
              ),
              SizedBox(height: ResponsiveSpacing.md),
              Text(
                action.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveSpacing.xs),
              Text(
                action.description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String route;

  DashboardStat(this.label, this.value, this.icon, this.color, this.route);
}

class QuickAction {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction(this.title, this.description, this.icon, this.color, this.onTap);
}
