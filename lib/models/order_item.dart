import 'book.dart';

class OrderItem {
  final int? id;
  final int? orderId;
  final Book? book;
  final int? bookId;
  final int quantity;
  final double price;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderItem({
    this.id,
    this.orderId,
    this.book,
    this.bookId,
    required this.quantity,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['orderId'],
      book: json['book'] != null ? Book.fromJson(json['book']) : null,
      bookId: json['bookId'],
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'bookId': bookId,
      'quantity': quantity,
      'price': price,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  double get subtotal => price * quantity;

  OrderItem copyWith({
    int? id,
    int? orderId,
    Book? book,
    int? bookId,
    int? quantity,
    double? price,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      book: book ?? this.book,
      bookId: bookId ?? this.bookId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}