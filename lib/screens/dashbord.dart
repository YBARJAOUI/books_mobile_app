import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.03),
            _buildStatsSection(context, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: screenWidth * 0.03,
          mainAxisSpacing: screenWidth * 0.03,
          children: [
            _buildStatCard(
              'Livres',
              '150',
              Icons.book,
              Colors.blue,
              screenWidth,
              () => context.go('/books'),
            ),
            _buildStatCard(
              'Clients',
              '85',
              Icons.people,
              Colors.green,
              screenWidth,
              () => context.go('/customers'),
            ),
            _buildStatCard(
              'Commandes',
              '23',
              Icons.shopping_cart,
              Colors.orange,
              screenWidth,
              () => context.go('/orders'),
            ),
            _buildStatCard(
              'Packs',
              '12',
              Icons.inventory,
              Colors.purple,
              screenWidth,
              () => context.go('/packs'),
            ),
            _buildStatCard(
              'Offres',
              '5',
              Icons.local_offer,
              Colors.red,
              screenWidth,
              () => context.go('/daily-offers'),
            ),
            _buildStatCard(
              'Revenus',
              '€2.4K',
              Icons.euro,
              Colors.teal,
              screenWidth,
              () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    double screenWidth,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: screenWidth * 0.12,
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(icon, size: screenWidth * 0.07, color: color),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.032,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
