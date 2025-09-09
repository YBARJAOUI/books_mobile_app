import 'package:flutter/material.dart';

import 'customer.dart';
import 'order_item.dart';

class Order {
  final int? id;
  final String status;
  final Customer? client;
  final DateTime? createdAt;
  final List<OrderItem> orderItems;
  final double? totalAmount;

  Order({
    this.id, 
    required this.status, 
    this.client, 
    this.createdAt,
    this.orderItems = const [],
    this.totalAmount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['orderItems'] != null && json['orderItems'] is List) {
      items = (json['orderItems'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return Order(
      id: json['id'],
      status: json['status'] ?? '',
      client: json['client'] != null ? Customer.fromJson(json['client']) : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) 
          : null,
      orderItems: items,
      totalAmount: json['totalAmount']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'client': client?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }

  Order copyWith({
    int? id,
    String? status,
    Customer? client,
    DateTime? createdAt,
    List<OrderItem>? orderItems,
    double? totalAmount,
  }) {
    return Order(
      id: id ?? this.id,
      status: status ?? this.status,
      client: client ?? this.client,
      createdAt: createdAt ?? this.createdAt,
      orderItems: orderItems ?? this.orderItems,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  // Helper methods for status management
  static List<String> getAvailableStatuses() {
    return [
      'في الانتظار', // Pending
      'قيد المعالجة', // Processing
      'جاهز للتسليم', // Ready for delivery
      'تم التسليم', // Delivered
      'ملغي', // Cancelled
    ];
  }

  static String getStatusInEnglish(String arabicStatus) {
    switch (arabicStatus) {
      case 'في الانتظار':
        return 'PENDING';
      case 'قيد المعالجة':
        return 'PROCESSING';
      case 'جاهز للتسليم':
        return 'READY';
      case 'تم التسليم':
        return 'DELIVERED';
      case 'ملغي':
        return 'CANCELLED';
      default:
        return 'PENDING';
    }
  }

  static String getStatusInArabic(String englishStatus) {
    switch (englishStatus.toUpperCase()) {
      case 'PENDING':
        return 'في الانتظار';
      case 'PROCESSING':
        return 'قيد المعالجة';
      case 'READY':
        return 'جاهز للتسليم';
      case 'DELIVERED':
        return 'تم التسليم';
      case 'CANCELLED':
        return 'ملغي';
      default:
        return 'في الانتظار';
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'في الانتظار':
      case 'PENDING':
        return Colors.orange;
      case 'قيد المعالجة':
      case 'PROCESSING':
        return Colors.blue;
      case 'جاهز للتسليم':
      case 'READY':
        return Colors.purple;
      case 'تم التسليم':
      case 'DELIVERED':
        return Colors.green;
      case 'ملغي':
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'في الانتظار':
      case 'PENDING':
        return Icons.schedule;
      case 'قيد المعالجة':
      case 'PROCESSING':
        return Icons.settings;
      case 'جاهز للتسليم':
      case 'READY':
        return Icons.local_shipping;
      case 'تم التسليم':
      case 'DELIVERED':
        return Icons.check_circle;
      case 'ملغي':
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  // Getters for convenience
  String get statusInArabic => getStatusInArabic(status);
  Color get statusColor => getStatusColor(status);
  IconData get statusIcon => getStatusIcon(status);
  String get customerName => client?.nom ?? 'غير محدد';
  String get formattedDate =>
      createdAt != null
          ? '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}'
          : 'غير محدد';
  
  // New getters for order items
  int get totalItems => orderItems.fold(0, (sum, item) => sum + item.quantity);
  
  String get itemsSummary {
    if (orderItems.isEmpty) return 'Aucun livre';
    if (orderItems.length == 1) {
      return '${orderItems.first.book.title} (${orderItems.first.quantity})';
    }
    return '${orderItems.length} livres ($totalItems items)';
  }
  
  double get calculatedTotal => 
      totalAmount ?? orderItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  String get formattedTotal => '${calculatedTotal.toStringAsFixed(2)} MAD';
}
