class Book {
  final int? id;
  final String isbn;
  final String title;
  final String author;
  final String? description;
  final double price;
  final String? imageBase64;
  final bool isAvailable;
  final int stock;
  final String language;
  final String category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Book({
    this.id,
    required this.isbn,
    required this.title,
    required this.author,
    this.description,
    required this.price,
    this.imageBase64,
    this.isAvailable = true,
    this.stock = 0,
    required this.language,
    required this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      isbn: json['isbn'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      imageBase64: json['imageBase64'],
      isAvailable: json['isAvailable'] ?? true,
      stock: json['stock'] ?? 0,
      language: json['language'] ?? '',
      category: json['category'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isbn': isbn,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'imageBase64': imageBase64,
      'isAvailable': isAvailable,
      'stock': stock,
      'language': language,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Book copyWith({
    int? id,
    String? isbn,
    String? title,
    String? author,
    String? description,
    double? price,
    String? imageBase64,
    bool? isAvailable,
    int? stock,
    String? language,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      price: price ?? this.price,
      imageBase64: imageBase64 ?? this.imageBase64,
      isAvailable: isAvailable ?? this.isAvailable,
      stock: stock ?? this.stock,
      language: language ?? this.language,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}