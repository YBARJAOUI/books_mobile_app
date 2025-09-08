import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../utils/responsive_layout.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  bool isLoading = false;
  String searchQuery = '';
  bool showActiveOnly = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedCustomers = await CustomerService.getAllCustomers();
      if (mounted) {
        setState(() {
          customers = loadedCustomers;
          _applyFilters();
        });
      }
    } catch (e) {
      print('Error loading customers: $e');
      if (mounted) {
        setState(() {
          customers = [];
          _applyFilters();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل العملاء: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              textColor: Colors.white,
              onPressed: _loadCustomers,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    filteredCustomers =
        customers.where((customer) {
          final matchesSearch =
              searchQuery.isEmpty ||
              customer.firstName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              customer.lastName.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              customer.email.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              customer.phoneNumber.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );

          final matchesStatus = !showActiveOnly || customer.isActive;

          return matchesSearch && matchesStatus;
        }).toList();

    // ترتيب بالاسم
    filteredCustomers.sort(
      (a, b) => '${a.firstName} ${a.lastName}'.compareTo(
        '${b.firstName} ${b.lastName}',
      ),
    );
  }

  Future<void> _deleteCustomer(int id) async {
    final customer = customers.firstWhere((c) => c.id == id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: Text(
              'هل أنت متأكد من أنك تريد حذف العميل ${customer.fullName}؟\n\n'
              'هذه العملية غير قابلة للتراجع.',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'حذف',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await CustomerService.deleteCustomer(id);
        _loadCustomers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف العميل بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في الحذف: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showCustomerDetails(Customer customer) {
    if (ResponsiveLayout.isMobile(context)) {
      _showMobileCustomerDetails(customer);
    } else {
      _showDesktopCustomerDialog(customer);
    }
  }

  void _showMobileCustomerDetails(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (context, scrollController) => Column(
                  children: [
                    Container(
                      height: 4,
                      width: 40,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        child: _buildCustomerDetailsContent(customer),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDesktopCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: _buildCustomerDetailsContent(customer),
              ),
            ),
          ),
    );
  }

  Widget _buildCustomerDetailsContent(Customer customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: customer.isActive ? Colors.green : Colors.grey,
              child: Text(
                customer.firstName.isNotEmpty
                    ? customer.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: customer.isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      customer.isActive ? 'نشط' : 'غير نشط',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildDetailItem(Icons.email, 'Email', customer.email),
        _buildDetailItem(Icons.phone, 'هاتف', customer.phoneNumber),
        _buildDetailItem(Icons.location_on, 'عنوان', customer.address),
        if (customer.city != null)
          _buildDetailItem(Icons.location_city, 'مدينة', customer.city!),
        if (customer.postalCode != null)
          _buildDetailItem(
            Icons.local_post_office,
            'الرمز البريدي',
            customer.postalCode!,
          ),
        if (customer.country != null)
          _buildDetailItem(Icons.flag, 'بلد', customer.country!),
        if (customer.createdAt != null)
          _buildDetailItem(
            Icons.calendar_today,
            'تاريخ الإنشاء',
            '${customer.createdAt!.day}/${customer.createdAt!.month}/${customer.createdAt!.year}',
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  context.go(
                    '/customers/edit/${customer.id}',
                    extra: customer.toJson(),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('تعديل'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteCustomer(customer.id!);
                },
                icon: const Icon(Icons.delete),
                label: const Text('حذف'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCustomers = customers.where((c) => c.isActive).length;
    final inactiveCustomers = customers.length - activeCustomers;

    return Scaffold(
      appBar:
          ResponsiveLayout.isMobile(context)
              ? AppBar(
                title: const Text('إدارة العملاء'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: _loadCustomers,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'تحديث',
                  ),
                ],
              )
              : null,
      body: Column(
        children: [
          _buildHeaderSection(activeCustomers, inactiveCustomers),
          Expanded(child: _buildCustomersContent()),
        ],
      ),
      floatingActionButton:
          ResponsiveLayout.isMobile(context)
              ? FloatingActionButton(
                onPressed: () => context.go('/customers/new'),
                child: const Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildHeaderSection(int activeCustomers, int inactiveCustomers) {
    return Container(
      padding: ResponsiveSpacing.getAllPadding(context),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius:
            ResponsiveLayout.isMobile(context)
                ? null
                : const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
      ),
      child: Column(
        children: [
          ResponsiveLayout(
            mobile: _buildMobileStats(activeCustomers, inactiveCustomers),
            tablet: _buildDesktopStats(activeCustomers, inactiveCustomers),
            desktop: _buildDesktopStats(activeCustomers, inactiveCustomers),
          ),
          SizedBox(height: ResponsiveSpacing.md),
          ResponsiveLayout(
            mobile: _buildMobileFilters(),
            tablet: _buildDesktopFilters(),
            desktop: _buildDesktopFilters(),
          ),
          SizedBox(height: ResponsiveSpacing.sm),
          _buildStatsAndActions(),
        ],
      ),
    );
  }

  Widget _buildMobileStats(int activeCustomers, int inactiveCustomers) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'الإجمالي',
                customers.length.toString(),
                Colors.blue,
              ),
            ),
            SizedBox(width: ResponsiveSpacing.sm),
            Expanded(
              child: _buildStatCard(
                'النشطين',
                activeCustomers.toString(),
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'غير النشطين',
                inactiveCustomers.toString(),
                Colors.orange,
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopStats(int activeCustomers, int inactiveCustomers) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            customers.length.toString(),
            Colors.blue,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.sm),
        Expanded(
          child: _buildStatCard(
            'Actifs',
            activeCustomers.toString(),
            Colors.green,
          ),
        ),
        SizedBox(width: ResponsiveSpacing.sm),
        Expanded(
          child: _buildStatCard(
            'Inactifs',
            inactiveCustomers.toString(),
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveSpacing.sm,
        horizontal: ResponsiveSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveLayout.isMobile(context) ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'ابحث بالاسم أو البريد الإلكتروني أو الهاتف...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              _applyFilters();
            });
          },
        ),
        SizedBox(height: ResponsiveSpacing.sm),
        Row(
          children: [
            Expanded(
              child: FilterChip(
                label: const Text('النشطين فقط'),
                selected: showActiveOnly,
                onSelected: (selected) {
                  setState(() {
                    showActiveOnly = selected;
                    _applyFilters();
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: Colors.green.withValues(alpha: 0.2),
                checkmarkColor: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو البريد الإلكتروني أو الهاتف...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                _applyFilters();
              });
            },
          ),
        ),
        SizedBox(width: ResponsiveSpacing.md),
        FilterChip(
          label: const Text('Actifs uniquement'),
          selected: showActiveOnly,
          onSelected: (selected) {
            setState(() {
              showActiveOnly = selected;
              _applyFilters();
            });
          },
          backgroundColor: Colors.white,
          selectedColor: Colors.green.withValues(alpha: 0.2),
          checkmarkColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatsAndActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${filteredCustomers.length} عميل معروض',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        if (!ResponsiveLayout.isMobile(context))
          ElevatedButton.icon(
            onPressed: () => context.go('/customers/new'),
            icon: const Icon(Icons.add),
            label: const Text('عميل جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildCustomersContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('تحميل العملاء...'),
          ],
        ),
      );
    }

    if (filteredCustomers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty || showActiveOnly
                  ? 'لم يتم العثور على أي عميل بهذه المعايير'
                  : 'لا يوجد عملاء مسجلون',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            if (searchQuery.isEmpty && !showActiveOnly)
              ElevatedButton.icon(
                onPressed: () => context.go('/customers/new'),
                icon: const Icon(Icons.add),
                label: const Text('إنشاء أول عميل'),
              ),
          ],
        ),
      );
    }

    return ResponsiveLayout(
      mobile: _buildCustomersList(),
      tablet: _buildCustomersGrid(2),
      desktop: _buildCustomersGrid(ResponsiveLayout.getGridColumns(context)),
    );
  }

  Widget _buildCustomersList() {
    return ListView.builder(
      padding: ResponsiveSpacing.getAllPadding(context),
      itemCount: filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        return Card(
          margin: EdgeInsets.only(bottom: ResponsiveSpacing.sm),
          child: ListTile(
            contentPadding: EdgeInsets.all(ResponsiveSpacing.md),
            leading: CircleAvatar(
              backgroundColor: customer.isActive ? Colors.green : Colors.grey,
              child: Text(
                customer.firstName.isNotEmpty
                    ? customer.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              customer.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        customer.email,
                        style: TextStyle(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      customer.phoneNumber,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: customer.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    customer.isActive ? 'Actif' : 'Inactif',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('عرض التفاصيل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'حذف',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) async {
                switch (value) {
                  case 'view':
                    _showCustomerDetails(customer);
                    break;
                  case 'edit':
                    context.go(
                      '/customers/edit/${customer.id}',
                      extra: customer.toJson(),
                    );
                    break;
                  case 'delete':
                    _deleteCustomer(customer.id!);
                    break;
                }
              },
            ),
            onTap: () => _showCustomerDetails(customer),
          ),
        );
      },
    );
  }

  Widget _buildCustomersGrid(int columns) {
    return GridView.builder(
      padding: ResponsiveSpacing.getAllPadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 1.2,
        crossAxisSpacing: ResponsiveSpacing.md,
        mainAxisSpacing: ResponsiveSpacing.md,
      ),
      itemCount: filteredCustomers.length,
      itemBuilder: (context, index) {
        final customer = filteredCustomers[index];
        return Card(
          child: InkWell(
            onTap: () => _showCustomerDetails(customer),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(ResponsiveSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        customer.isActive ? Colors.green : Colors.grey,
                    child: Text(
                      customer.firstName.isNotEmpty
                          ? customer.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveSpacing.sm),
                  Text(
                    customer.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveSpacing.xs),
                  Text(
                    customer.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: ResponsiveSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: customer.isActive ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      customer.isActive ? 'نشط' : 'غير نشط',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed:
                            () => context.go(
                              '/customers/edit/${customer.id}',
                              extra: customer.toJson(),
                            ),
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        onPressed: () => _deleteCustomer(customer.id!),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 18,
                        ),
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
