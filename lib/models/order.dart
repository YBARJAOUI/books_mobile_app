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
      orderItems: json['orderItems'] != null 
          ? (json['orderItems'] as List).map((item) => OrderItem.fromJson(item)).toList()
          : [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      notes: json['notes'],
      shippingAddress: json['shippingAddress'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      shippedAt: json['shippedAt'] != null ? DateTime.parse(json['shippedAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
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
}