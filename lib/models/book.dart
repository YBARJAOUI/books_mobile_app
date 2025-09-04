class Book {
  final int? id;
  final String title;
  final String author;
  final String? description;
  final double price;
  final String? image;
  final bool isAvailable;
  final String language;
  final String category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Book({
    this.id,
    required this.title,
    required this.author,
    this.description,
    required this.price,
    this.image,
    this.isAvailable = true,
    required this.language,
    required this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      image: json['image'] ?? json['imageBase64'],
      isAvailable: json['isAvailable'] ?? true,
      language: json['language'] ?? 'francais',
      // FIXED: Ensure category is never null and handle common variations
      category: _normalizeCategory(json['category'] ?? 'Non-Fiction'),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // FIXED: Normalize category names to prevent dropdown issues
  static String _normalizeCategory(String category) {
    if (category.isEmpty) return 'Non-Fiction';

    // Handle common variations and normalize names
    switch (category.toLowerCase().trim()) {
      case 'science-fiction':
      case 'sci-fi':
      case 'sciencefiction':
        return 'Science-Fiction';
      case 'non-fiction':
      case 'nonfiction':
      case 'non fiction':
        return 'Non-Fiction';
      case 'fiction':
        return 'Fiction';
      case 'science':
        return 'Science';
      case 'histoire':
      case 'history':
        return 'Histoire';
      case 'philosophie':
      case 'philosophy':
        return 'Philosophie';
      case 'art':
        return 'Art';
      case 'cuisine':
      case 'cooking':
        return 'Cuisine';
      case 'technologie':
      case 'technology':
      case 'tech':
        return 'Technologie';
      case 'santé':
      case 'sante':
      case 'health':
        return 'Santé';
      case 'jeunesse':
      case 'youth':
      case 'children':
        return 'Jeunesse';
      case 'romance':
        return 'Romance';
      case 'thriller':
        return 'Thriller';
      case 'fantasy':
      case 'fantaisie':
        return 'Fantasy';
      default:
        // Capitalize first letter and return as is for unknown categories
        return category.isNotEmpty
            ? category[0].toUpperCase() + category.substring(1).toLowerCase()
            : 'Non-Fiction';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'price': price,
      'image': image,
      'isAvailable': isAvailable,
      'language': language,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? description,
    double? price,
    String? image,
    bool? isAvailable,
    String? language,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      isAvailable: isAvailable ?? this.isAvailable,
      language: language ?? this.language,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to get available categories
  static List<String> getAvailableCategories() {
    return [
      'Tous',
      'Fiction',
      'Non-Fiction',
      'Science-Fiction',
      'Science',
      'Histoire',
      'Philosophie',
      'Art',
      'Cuisine',
      'Technologie',
      'Santé',
      'Jeunesse',
      'Romance',
      'Thriller',
      'Fantasy',
    ];
  }
}
