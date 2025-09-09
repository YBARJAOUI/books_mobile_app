import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/customer.dart';
import '../services/order_service.dart';
import '../services/customer_service.dart';

class OrderFormScreen extends StatefulWidget {
  final Order? order;

  const OrderFormScreen({super.key, this.order});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedStatus = 'في الانتظار';
  Customer? _selectedCustomer;
  List<Customer> _customers = [];
  bool _isLoading = false;
  bool _isLoadingCustomers = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    if (widget.order != null) {
      _selectedStatus = widget.order!.statusInArabic;
      _selectedCustomer = widget.order!.client;
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await CustomerService.getAllCustomers();
      setState(() {
        _customers = customers.where((c) => c.isActive).toList();
        _isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCustomers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحميل العملاء: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار عميل'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final englishStatus = Order.getStatusInEnglish(_selectedStatus);
      final order = Order(
        id: widget.order?.id,
        status: englishStatus,
        client: _selectedCustomer,
        createdAt: widget.order?.createdAt ?? DateTime.now(),
      );

      if (widget.order == null) {
        await OrderService.createOrder(order);
      } else {
        await OrderService.updateOrder(order);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.order == null
                  ? 'تم إنشاء الطلب بنجاح'
                  : 'تم تعديل الطلب بنجاح',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'طلب جديد' : 'تعديل الطلب'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _isLoading ? null : _saveOrder,
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.save, color: Colors.white),
              label: Text(
                _isLoading ? 'جاري الحفظ...' : 'حفظ',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoadingCustomers
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('تحميل بيانات العملاء...'),
                  ],
                ),
              )
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.shopping_cart,
                              size: 32,
                              color: Colors.indigo,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.order == null
                                        ? 'إنشاء طلب جديد'
                                        : 'تعديل الطلب',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'املأ معلومات الطلب',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Customer Selection
                      Text(
                        'اختيار العميل',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      if (_customers.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.orange,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'لا يوجد عملاء نشطين',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'يجب إضافة عملاء أولاً لإنشاء طلبات',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      else
                        DropdownButtonFormField<Customer>(
                          value: _selectedCustomer,
                          decoration: const InputDecoration(
                            labelText: 'اختر العميل *',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          items:
                              _customers.map((customer) {
                                return DropdownMenuItem(
                                  value: customer,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customer.nom,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        customer.phoneNumber,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (customer) {
                            setState(() {
                              _selectedCustomer = customer;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'الرجاء اختيار عميل';
                            }
                            return null;
                          },
                        ),

                      const SizedBox(height: 24),

                      // Customer Info Display
                      if (_selectedCustomer != null) ...[
                        Text(
                          'معلومات العميل المختار',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Text(
                                      _selectedCustomer!.nom[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedCustomer!.nom,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'هاتف: ${_selectedCustomer!.phoneNumber}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text('العنوان: ${_selectedCustomer!.address}'),
                              Text('المدينة: ${_selectedCustomer!.city}'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],

                      // Order Status
                      Text(
                        'حالة الطلب',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'حالة الطلب *',
                          prefixIcon: Icon(Icons.info),
                          border: OutlineInputBorder(),
                        ),
                        items:
                            Order.getAvailableStatuses().map((status) {
                              final color = Order.getStatusColor(status);
                              final icon = Order.getStatusIcon(status);
                              return DropdownMenuItem(
                                value: status,
                                child: Row(
                                  children: [
                                    Icon(icon, color: color, size: 20),
                                    const SizedBox(width: 8),
                                    Text(status),
                                  ],
                                ),
                              );
                            }).toList(),
                        onChanged: (status) {
                          setState(() {
                            _selectedStatus = status!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء اختيار حالة الطلب';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Status Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Order.getStatusColor(
                            _selectedStatus,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Order.getStatusColor(
                              _selectedStatus,
                            ).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Order.getStatusIcon(_selectedStatus),
                              color: Order.getStatusColor(_selectedStatus),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الحالة المختارة: $_selectedStatus',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Order.getStatusColor(
                                        _selectedStatus,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _getStatusDescription(_selectedStatus),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Order.getStatusColor(
                                        _selectedStatus,
                                      ).withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        Navigator.of(context).pop();
                                      },
                              child: const Text('إلغاء'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _isLoading || _customers.isEmpty
                                      ? null
                                      : _saveOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                              child:
                                  _isLoading
                                      ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text('جاري الحفظ...'),
                                        ],
                                      )
                                      : Text(
                                        widget.order == null
                                            ? 'إنشاء الطلب'
                                            : 'تعديل الطلب',
                                      ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'في الانتظار':
        return 'الطلب في انتظار المراجعة والموافقة';
      case 'قيد المعالجة':
        return 'جاري تجهيز الطلب والعمل على إنجازه';
      case 'جاهز للتسليم':
        return 'الطلب جاهز ويمكن تسليمه للعميل';
      case 'تم التسليم':
        return 'تم تسليم الطلب بنجاح للعميل';
      case 'ملغي':
        return 'تم إلغاء الطلب ولن يتم إنجازه';
      default:
        return '';
    }
  }
}
