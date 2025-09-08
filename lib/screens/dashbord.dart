import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _statistics = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simple static data since dashboard service is removed
      setState(() {
        _statistics = {
          'totalBooks': 0,
          'totalCustomers': 0,
          'totalOrders': 0,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _statistics = {
          'totalBooks': 0,
          'totalCustomers': 0,
          'totalOrders': 0,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('تحميل الإحصائيات...'),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الاتصال بالخادم',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'لا يمكن تحميل البيانات في الوقت الفعلي. استخدام البيانات الافتراضية.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

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
              'الكتب',
              _statistics['totalBooks']?.toString() ?? '0',
              Icons.book,
              Colors.blue,
              screenWidth,
              () => context.go('/books'),
            ),
            _buildStatCard(
              'العملاء',
              _statistics['totalCustomers']?.toString() ?? '0',
              Icons.people,
              Colors.green,
              screenWidth,
              () => context.go('/customers'),
            ),
            _buildStatCard(
              'الطلبات',
              _statistics['totalOrders']?.toString() ?? '0',
              Icons.shopping_cart,
              Colors.orange,
              screenWidth,
              () => context.go('/orders'),
            ),
            _buildStatCard(
              'الحزم',
              _statistics['totalPacks']?.toString() ?? '0',
              Icons.inventory,
              Colors.purple,
              screenWidth,
              () => context.go('/packs'),
            ),
            _buildStatCard(
              'العروض',
              _statistics['totalOffers']?.toString() ?? '0',
              Icons.local_offer,
              Colors.red,
              screenWidth,
              () => context.go('/daily-offers'),
            ),
            _buildStatCard(
              'الإيرادات',
              _formatRevenue(_statistics['totalRevenue']),
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

  String _formatRevenue(dynamic revenue) {
    if (revenue == null) return '€0';

    double amount = 0.0;
    if (revenue is num) {
      amount = revenue.toDouble();
    } else if (revenue is String) {
      amount = double.tryParse(revenue) ?? 0.0;
    }

    if (amount >= 1000000) {
      return '€${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '€${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '€${amount.toStringAsFixed(0)}';
    }
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
