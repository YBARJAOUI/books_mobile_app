import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/book_service.dart';
import '../services/customer_service.dart';
import '../services/offer_service.dart';
import '../services/order_service.dart';

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
      // Load real data from services
      final books = await BookService.getAllBooks();
      final customers = await CustomerService.getAllCustomers();
      final offers = await OfferService.getAllOffers();
      final orders = await OrderService.getAllOrders();

      setState(() {
        _statistics = {
          'totalBooks': books.length,
          'totalCustomers': customers.length,
          'totalOffers': offers.length,
          'totalOrders': orders.length,
          'availableBooks': books.where((book) => book.available).length,
          'activeCustomers':
              customers.where((customer) => customer.isActive).length,
          'availableOffers': offers.where((offer) => offer.available).length,
          'pendingOrders':
              orders
                  .where((order) => order.statusInArabic == 'في الانتظار')
                  .length,
          'deliveredOrders':
              orders
                  .where((order) => order.statusInArabic == 'تم التسليم')
                  .length,
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
          'totalOffers': 0,
          'totalOrders': 0,
          'availableBooks': 0,
          'activeCustomers': 0,
          'availableOffers': 0,
          'pendingOrders': 0,
          'deliveredOrders': 0,
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
                          color: Colors.orange.withOpacity(0.1),
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
                                    'تحذير الاتصال',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'خطأ في تحميل البيانات: $_errorMessage',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Welcome Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.dashboard,
                                color: Colors.white,
                                size: screenWidth * 0.08,
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مرحباً بك في نظام إدارة المكتبة',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.045,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: screenWidth * 0.01),
                                    Text(
                                      'إدارة شاملة للكتب والعروض والطلبات والعملاء',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: screenWidth * 0.035,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),
                    _buildStatsSection(context, screenWidth),

                    SizedBox(height: screenHeight * 0.03),
                    _buildQuickActionsSection(context, screenWidth),
                  ],
                ),
              ),
    );
  }

  Widget _buildStatsSection(BuildContext context, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإحصائيات العامة',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: screenWidth * 0.03,
          mainAxisSpacing: screenWidth * 0.03,
          children: [
            _buildStatCard(
              'إجمالي الكتب',
              _statistics['totalBooks']?.toString() ?? '0',
              Icons.book,
              Colors.blue,
              screenWidth,
              () => context.go('/books'),
            ),
            _buildStatCard(
              'العروض الخاصة',
              _statistics['totalOffers']?.toString() ?? '0',
              Icons.local_offer,
              Colors.orange,
              screenWidth,
              () => context.go('/offers'),
            ),
            _buildStatCard(
              'إجمالي الطلبات',
              _statistics['totalOrders']?.toString() ?? '0',
              Icons.shopping_cart,
              Colors.indigo,
              screenWidth,
              () => context.go('/orders'),
            ),
            _buildStatCard(
              'إجمالي العملاء',
              _statistics['totalCustomers']?.toString() ?? '0',
              Icons.people,
              Colors.green,
              screenWidth,
              () => context.go('/customers'),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Secondary stats
        Text(
          'تفاصيل الإحصائيات',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: screenWidth * 0.03,
          mainAxisSpacing: screenWidth * 0.03,
          children: [
            _buildSmallStatCard(
              'طلبات معلقة',
              _statistics['pendingOrders']?.toString() ?? '0',
              Icons.schedule,
              Colors.orange,
            ),
            _buildSmallStatCard(
              'طلبات مسلمة',
              _statistics['deliveredOrders']?.toString() ?? '0',
              Icons.check_circle,
              Colors.green,
            ),
            _buildSmallStatCard(
              'كتب متوفرة',
              _statistics['availableBooks']?.toString() ?? '0',
              Icons.check,
              Colors.teal,
            ),
            _buildSmallStatCard(
              'عملاء نشطين',
              _statistics['activeCustomers']?.toString() ?? '0',
              Icons.person_outline,
              Colors.purple,
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

  Widget _buildSmallStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإجراءات السريعة',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: screenWidth * 0.03,
          mainAxisSpacing: screenWidth * 0.03,
          children: [
            _buildActionCard(
              'إضافة كتاب جديد',
              Icons.add_circle,
              Colors.blue,
              screenWidth,
              () => context.go('/books/new'),
            ),
            _buildActionCard(
              'إضافة عرض خاص',
              Icons.local_offer_outlined,
              Colors.orange,
              screenWidth,
              () => context.go('/offers/new'),
            ),
            _buildActionCard(
              'إنشاء طلب جديد',
              Icons.shopping_cart_outlined,
              Colors.indigo,
              screenWidth,
              () => context.go('/orders/new'),
            ),
            _buildActionCard(
              'إضافة عميل جديد',
              Icons.person_add,
              Colors.green,
              screenWidth,
              () => context.go('/customers/new'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String label,
    IconData icon,
    Color color,
    double screenWidth,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: screenWidth * 0.1,
                height: screenWidth * 0.1,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(icon, size: screenWidth * 0.06, color: color),
              ),
              SizedBox(height: screenWidth * 0.02),
              Text(
                label,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
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
