import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../services/order_service.dart';

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
      final loadedOrders = selectedStatus != null
          ? await OrderService.getOrdersByStatus(selectedStatus!)
          : await OrderService.getAllOrders();
      setState(() {
        orders = loadedOrders;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des commandes: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Commandes'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<OrderStatus?>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filtrer par statut',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<OrderStatus?>(
                        value: null,
                        child: Text('Tous les statuts'),
                      ),
                      ...OrderStatus.values.map((status) {
                        return DropdownMenuItem<OrderStatus?>(
                          value: status,
                          child: Text(_getStatusDisplayName(status)),
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
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : orders.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune commande trouvée',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
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
                                  Text('Statut: ${order.statusDisplayName}'),
                                  Text('Paiement: ${order.paymentStatusDisplayName}'),
                                  if (order.createdAt != null)
                                    Text(
                                      'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!)}',
                                    ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (order.orderItems.isNotEmpty) ...[
                                        const Text(
                                          'Articles:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...order.orderItems.map((item) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.book?.title ?? 'Livre inconnu',
                                                  ),
                                                ),
                                                Text('${item.quantity}x'),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${item.subtotal.toStringAsFixed(2)} €',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                        const Divider(),
                                      ],
                                      if (order.shippingAddress != null) ...[
                                        const Text(
                                          'Adresse de livraison:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(order.shippingAddress!),
                                        const SizedBox(height: 8),
                                      ],
                                      if (order.notes != null) ...[
                                        const Text(
                                          'Notes:',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(order.notes!),
                                        const SizedBox(height: 8),
                                      ],
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          DropdownButton<OrderStatus>(
                                            value: order.status,
                                            items: OrderStatus.values.map((status) {
                                              return DropdownMenuItem(
                                                value: status,
                                                child: Text(_getStatusDisplayName(status)),
                                              );
                                            }).toList(),
                                            onChanged: (newStatus) {
                                              if (newStatus != null) {
                                                _updateOrderStatus(order, newStatus);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
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
}