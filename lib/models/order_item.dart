// lib/models/order_item.dart
import 'book.dart';

class OrderItem {
  final int? id;
  final Book book;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? itemType; // "BOOK" ou "OFFER"

  OrderItem({
    this.id,
    required this.book,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.itemType,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Create Book from the flattened book data in the OrderItemDTO
    final book = Book(
      title: json['bookTitle'] ?? json['displayTitle'] ?? '',
      auteur: json['bookAuthor'] ?? json['displayAuthor'] ?? '',
      description: json['bookDescription'],
      prix: (json['unitPrice'] ?? 0.0).toDouble(),
      imageBase64: json['bookImageBase64'],
      available: json['bookAvailable'] ?? true,
      categorie:
          json['bookCategory'] ?? json['displayCategory'] ?? 'Non-Fiction',
    );

    return OrderItem(
      id: json['id'],
      book: book,
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      itemType: json['itemType'] ?? 'BOOK',
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
      'itemType': itemType,
    };
  }

  OrderItem copyWith({
    int? id,
    Book? book,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? itemType,
  }) {
    return OrderItem(
      id: id ?? this.id,
      book: book ?? this.book,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      itemType: itemType ?? this.itemType,
    );
  }

  // Helper methods
  bool get isBook => itemType == null || itemType == 'BOOK';
  bool get isOffer => itemType == 'OFFER';

  String get typeInArabic {
    switch (itemType) {
      case 'OFFER':
        return 'عرض خاص';
      case 'BOOK':
      default:
        return 'كتاب';
    }
  }

  String get formattedUnitPrice => '${unitPrice.toStringAsFixed(2)} د.م.';
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(2)} د.م.';

  String get displayTitle =>
      book.title.isNotEmpty ? book.title : 'عنصر غير محدد';

  String get displayAuthor {
    if (book.auteur.isEmpty) {
      return isOffer ? 'عرض خاص' : 'مؤلف غير محدد';
    }
    return book.auteur;
  }

  String get displayCategory {
    if (book.categorie.isEmpty) {
      return isOffer ? 'عرض' : 'غير مصنف';
    }
    return book.categorie;
  }

  String get quantityDescription {
    if (quantity == 1) {
      return isOffer ? 'عرض واحد' : 'كتاب واحد';
    }
    return '$quantity ${isOffer ? 'عروض' : 'كتب'}';
  }

  String get fullDescription {
    StringBuffer description = StringBuffer();
    description.write(displayTitle);

    if (displayAuthor != 'عرض خاص' && displayAuthor != 'مؤلف غير محدد') {
      description.write(' - $displayAuthor');
    }

    if (quantity > 1) {
      description.write(' (${quantityDescription})');
    }

    return description.toString();
  }

  // Helper method to calculate total price if needed
  static double calculateTotalPrice(double unitPrice, int quantity) {
    return unitPrice * quantity;
  }

  // Validation helpers
  bool get isValid =>
      book.title.isNotEmpty &&
      quantity > 0 &&
      unitPrice >= 0 &&
      totalPrice >= 0;

  // Price comparison helpers
  bool get hasDiscount => book.prix > unitPrice;
  double get discountAmount => hasDiscount ? book.prix - unitPrice : 0.0;
  double get discountPercentage =>
      hasDiscount ? ((book.prix - unitPrice) / book.prix * 100) : 0.0;

  String get discountDescription {
    if (!hasDiscount) return '';
    return 'خصم ${discountPercentage.toStringAsFixed(0)}% (وفر ${discountAmount.toStringAsFixed(2)} د.م.)';
  }
}
