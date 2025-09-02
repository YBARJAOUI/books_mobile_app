class DailyOffer {
  final int? id;
  final String title;
  final String description;
  final double originalPrice;
  final double offerPrice;
  final int? discountPercentage;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int? bookId;
  final int? packId;
  final int? limitQuantity;
  final int soldQuantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DailyOffer({
    this.id,
    required this.title,
    required this.description,
    required this.originalPrice,
    required this.offerPrice,
    this.discountPercentage,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.bookId,
    this.packId,
    this.limitQuantity,
    this.soldQuantity = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory DailyOffer.fromJson(Map<String, dynamic> json) {
    return DailyOffer(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      offerPrice: (json['offerPrice'] ?? 0).toDouble(),
      discountPercentage: json['discountPercentage'],
      imageUrl: json['imageUrl'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? true,
      bookId: json['bookId'],
      packId: json['packId'],
      limitQuantity: json['limitQuantity'],
      soldQuantity: json['soldQuantity'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'originalPrice': originalPrice,
      'offerPrice': offerPrice,
      'discountPercentage': discountPercentage,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'bookId': bookId,
      'packId': packId,
      'limitQuantity': limitQuantity,
      'soldQuantity': soldQuantity,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  bool get isValidOffer {
    final now = DateTime.now();
    return isActive &&
        !now.isBefore(startDate) &&
        !now.isAfter(endDate) &&
        (limitQuantity == null || soldQuantity < limitQuantity!);
  }

  double get savings => originalPrice - offerPrice;

  int get calculatedDiscountPercentage {
    if (originalPrice > 0) {
      return ((originalPrice - offerPrice) / originalPrice * 100).round();
    }
    return 0;
  }

  DailyOffer copyWith({
    int? id,
    String? title,
    String? description,
    double? originalPrice,
    double? offerPrice,
    int? discountPercentage,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? bookId,
    int? packId,
    int? limitQuantity,
    int? soldQuantity,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyOffer(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      originalPrice: originalPrice ?? this.originalPrice,
      offerPrice: offerPrice ?? this.offerPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      bookId: bookId ?? this.bookId,
      packId: packId ?? this.packId,
      limitQuantity: limitQuantity ?? this.limitQuantity,
      soldQuantity: soldQuantity ?? this.soldQuantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}