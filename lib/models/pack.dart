class Pack {
  final int? id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isActive;
  final bool isFeatured;
  final int stockQuantity;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pack({
    this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isActive = true,
    this.isFeatured = false,
    this.stockQuantity = 0,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Pack.fromJson(Map<String, dynamic> json) {
    return Pack(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      stockQuantity: json['stockQuantity'] ?? 0,
      category: json['category'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'stockQuantity': stockQuantity,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Pack copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isActive,
    bool? isFeatured,
    int? stockQuantity,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pack(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}