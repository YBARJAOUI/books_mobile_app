import 'book.dart';

class OrderItem {
  final int? id;
  final Book book;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    this.id,
    required this.book,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Create Book from the flattened book data in the OrderItemDTO
    final book = Book(
      title: json['bookTitle'] ?? '',
      auteur: json['bookAuthor'] ?? '',
      description: json['bookDescription'],
      prix: (json['unitPrice'] ?? 0.0).toDouble(),
      imageBase64: json['bookImageBase64'],
      available: json['bookAvailable'] ?? true,
      categorie: json['bookCategory'] ?? 'Non-Fiction',
    );

    return OrderItem(
      id: json['id'],
      book: book,
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookTitle': book.title,
      'bookAuthor': book.auteur,
      'bookCategory': book.categorie,
      'bookDescription': book.description,
      'bookImageBase64': book.imageBase64,
      'bookAvailable': book.available,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }

  OrderItem copyWith({
    int? id,
    Book? book,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) {
    return OrderItem(
      id: id ?? this.id,
      book: book ?? this.book,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  // Helper method to calculate total price
  static double calculateTotalPrice(double unitPrice, int quantity) {
    return unitPrice * quantity;
  }
}