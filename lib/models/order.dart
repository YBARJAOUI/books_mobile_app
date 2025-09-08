import 'customer.dart';
import 'order_item.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }
enum PaymentStatus { pending, completed, failed, refunded }

class Order {
  final int? id;
  final String orderNumber;
  final Customer? customer;
  final int? customerId;
  final List<OrderItem> orderItems;
  final double totalAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final String? notes;
  final String? shippingAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;

  Order({
    this.id,
    required this.orderNumber,
    this.customer,
    this.customerId,
    this.orderItems = const [],
    required this.totalAmount,
    this.status = OrderStatus.pending,
    this.paymentStatus = PaymentStatus.pending,
    this.notes,
    this.shippingAddress,
    this.createdAt,
    this.updatedAt,
    this.shippedAt,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'] ?? '',
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      customerId: json['customerId'],
      orderItems: _parseOrderItems(json['orderItems']),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: _parseOrderStatus(json['status']),
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      notes: json['notes'],
      shippingAddress: json['shippingAddress'],
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      shippedAt: _parseDateTime(json['shippedAt']),
      deliveredAt: _parseDateTime(json['deliveredAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'notes': notes,
      'shippingAddress': shippingAddress,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'shippedAt': shippedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  String get statusDisplayName {
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

  String get paymentStatusDisplayName {
    switch (paymentStatus) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.completed:
        return 'Payée';
      case PaymentStatus.failed:
        return 'Échec';
      case PaymentStatus.refunded:
        return 'Remboursée';
    }
  }

  Order copyWith({
    int? id,
    String? orderNumber,
    Customer? customer,
    int? customerId,
    List<OrderItem>? orderItems,
    double? totalAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? notes,
    String? shippingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customer: customer ?? this.customer,
      customerId: customerId ?? this.customerId,
      orderItems: orderItems ?? this.orderItems,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  static OrderStatus _parseOrderStatus(dynamic status) {
    if (status == null) return OrderStatus.pending;
    
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        print('Unknown order status: $status, defaulting to pending');
        return OrderStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(dynamic paymentStatus) {
    if (paymentStatus == null) return PaymentStatus.pending;
    
    final statusStr = paymentStatus.toString().toLowerCase();
    switch (statusStr) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        print('Unknown payment status: $paymentStatus, defaulting to pending');
        return PaymentStatus.pending;
    }
  }

  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;
    
    try {
      if (dateTime is String && dateTime.isNotEmpty) {
        return DateTime.parse(dateTime);
      }
      return null;
    } catch (e) {
      print('Error parsing DateTime: $dateTime, error: $e');
      return null;
    }
  }

  static List<OrderItem> _parseOrderItems(dynamic orderItems) {
    if (orderItems == null) return [];
    
    try {
      if (orderItems is List) {
        return orderItems
            .map((item) {
              try {
                return OrderItem.fromJson(item);
              } catch (e) {
                print('Error parsing OrderItem: $item, error: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<OrderItem>()
            .toList();
      }
      return [];
    } catch (e) {
      print('Error parsing order items list: $orderItems, error: $e');
      return [];
    }
  }
}