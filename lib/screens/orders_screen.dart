import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../utils/responsive_layout.dart';
import '../widgets/responsive_widgets.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> orders = [];
  bool isLoading = false;
  OrderStatus? selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });

    try {
      final loadedOrders =
          selectedStatus != null
              ? await OrderService.getOrdersByStatus(selectedStatus!)
              : await OrderService.getAllOrders();
      setState(() {
        orders = loadedOrders;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des commandes: $e'),
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    try {
      await OrderService.updateOrderStatus(order.id!, newStatus);
      _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statut de la commande mis à jour')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipped:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          ResponsiveLayout.isMobile(context)
              ? AppBar(
                title: const Text('Gestion des Commandes'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: _loadOrders,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              )
              : null,
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(child: _buildOrdersContent()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
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
          _buildStatusStats(),
          SizedBox(height: ResponsiveSpacing.md),
          _buildStatusFilter(),
        ],
      ),
    );
  }

  Widget _buildStatusStats() {
    if (orders.isEmpty && !isLoading) return const SizedBox.shrink();

    final stats = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      stats[status] = orders.where((o) => o.status == status).length;
    }

    return ResponsiveLayout(
      mobile: _buildMobileStats(stats),
      tablet: _buildDesktopStats(stats),
      desktop: _buildDesktopStats(stats),
    );
  }

  Widget _buildMobileStats(Map<OrderStatus, int> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'En attente',
                stats[OrderStatus.pending].toString(),
                Colors.orange,
              ),
            ),
            SizedBox(width: ResponsiveSpacing.sm),
            Expanded(
              child: _buildStatCard(
                'Confirmées',
                stats[OrderStatus.confirmed].toString(),
                Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Expédiées',
                stats[OrderStatus.shipped].toString(),
                Colors.purple,
              ),
            ),
            SizedBox(width: ResponsiveSpacing.sm),
            Expanded(
              child: _buildStatCard(
                'Livrées',
                stats[OrderStatus.delivered].toString(),
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopStats(Map<OrderStatus, int> stats) {
    return Row(
      children:
          OrderStatus.values.take(4).map((status) {
            final statusName = _getStatusDisplayName(status);
            final color = _getStatusColor(status);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: ResponsiveSpacing.sm),
                child: _buildStatCard(
                  statusName,
                  stats[status].toString(),
                  color,
                ),
              ),
            );
          }).toList(),
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
              fontSize: ResponsiveLayout.isMobile(context) ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<OrderStatus?>(
            value: selectedStatus,
            decoration: InputDecoration(
              labelText: 'Filtrer par statut',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              const DropdownMenuItem<OrderStatus?>(
                value: null,
                child: Text('Tous les statuts'),
              ),
              ...OrderStatus.values.map((status) {
                return DropdownMenuItem<OrderStatus?>(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(_getStatusDisplayName(status)),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
              _loadOrders();
            },
          ),
        ),
        if (!ResponsiveLayout.isMobile(context)) ...[
          SizedBox(width: ResponsiveSpacing.md),
          Text(
            '${orders.length} commande(s)',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildOrdersContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des commandes...'),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commande trouvée',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            if (selectedStatus != null) ...[
              const SizedBox(height: 8),
              Text(
                'Essayez de changer le filtre de statut',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      );
    }

    return ResponsiveLayout(
      mobile: _buildMobileOrdersList(),
      tablet: _buildDesktopOrdersList(),
      desktop: _buildDesktopOrdersList(),
    );
  }

  Widget _buildMobileOrdersList() {
    return ListView.builder(
      padding: ResponsiveSpacing.getAllPadding(context),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildMobileOrderCard(order);
      },
    );
  }

  Widget _buildDesktopOrdersList() {
    return ListView.builder(
      padding: ResponsiveSpacing.getAllPadding(context),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildDesktopOrderCard(order);
      },
    );
  }

  Widget _buildMobileOrderCard(Order order) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveSpacing.sm),
      child: ExpansionTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getStatusColor(order.status),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          'Commande #${order.orderNumber}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order.customer != null)
              Text('Client: ${order.customer!.fullName}'),
            Text('Total: ${order.totalAmount.toStringAsFixed(2)} €'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.statusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        order.paymentStatus == PaymentStatus.completed
                            ? Colors.green
                            : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.paymentStatusDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (order.createdAt != null)
              Text(
                'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        children: [_buildOrderDetails(order)],
      ),
    );
  }

  Widget _buildDesktopOrderCard(Order order) {
    return ResponsiveCard(
      margin: EdgeInsets.only(bottom: ResponsiveSpacing.md),
      child: ExpansionTile(
        leading: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: _getStatusColor(order.status),
            shape: BoxShape.circle,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Commande #${order.orderNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                order.customer?.fullName ?? 'Client inconnu',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            Expanded(
              child: Text(
                '${order.totalAmount.toStringAsFixed(2)} €',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                order.statusDisplayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    order.paymentStatus == PaymentStatus.completed
                        ? Colors.green
                        : Colors.orange,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                order.paymentStatusDisplayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        subtitle:
            order.createdAt != null
                ? Text(
                  'Créée le ${DateFormat('dd/MM/yyyy à HH:mm').format(order.createdAt!)}',
                  style: TextStyle(color: Colors.grey[600]),
                )
                : null,
        children: [_buildOrderDetails(order)],
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Padding(
      padding: ResponsiveSpacing.getAllPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.orderItems.isNotEmpty) ...[
            ResponsiveSection(
              title: 'Articles (${order.orderItems.length})',
              icon: Icons.shopping_bag,
              child: Column(
                children:
                    order.orderItems.map((item) {
                      return Container(
                        margin: EdgeInsets.only(bottom: ResponsiveSpacing.xs),
                        padding: EdgeInsets.all(ResponsiveSpacing.sm),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.book?.title ?? 'Livre inconnu',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (item.book?.author != null)
                                    Text(
                                      'par ${item.book!.author}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text('${item.quantity}x'),
                            SizedBox(width: ResponsiveSpacing.sm),
                            Text(
                              '${item.subtotal.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: ResponsiveSpacing.md),
          ],
          Row(
            children: [
              if (order.shippingAddress != null) ...[
                Expanded(
                  child: ResponsiveSection(
                    title: 'Adresse de livraison',
                    icon: Icons.location_on,
                    child: Text(order.shippingAddress!),
                  ),
                ),
                SizedBox(width: ResponsiveSpacing.md),
              ],
              if (order.notes != null) ...[
                Expanded(
                  child: ResponsiveSection(
                    title: 'Notes',
                    icon: Icons.note,
                    child: Text(order.notes!),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: ResponsiveSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Changer le statut:',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
              ),
              DropdownButton<OrderStatus>(
                value: order.status,
                items:
                    OrderStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getStatusColor(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(_getStatusDisplayName(status)),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (newStatus) {
                  if (newStatus != null && newStatus != order.status) {
                    _updateOrderStatus(order, newStatus);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
