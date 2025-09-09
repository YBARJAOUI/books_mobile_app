class Book {
  final String title;
  final String auteur;
  final String? description;
  final double prix;
  final String? imageBase64;
  final bool available;
  final String categorie;

  Book({
    required this.title,
    required this.auteur,
    this.description,
    required this.prix,
    this.imageBase64,
    this.available = true,
    required this.categorie,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      auteur: json['auteur'] ?? '',
      description: json['description'],
      prix: (json['prix'] ?? 0).toDouble(),
      imageBase64: json['imageBase64'],
      available: json['available'] ?? true,
      categorie: json['categorie'] ?? 'Non-Fiction',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'auteur': auteur,
      'description': description,
      'prix': prix,
      'imageBase64': imageBase64,
      'available': available,
      'categorie': categorie,
    };
  }

  Book copyWith({
    String? title,
    String? auteur,
    String? description,
    double? prix,
    String? imageBase64,
    bool? available,
    String? categorie,
  }) {
    return Book(
      title: title ?? this.title,
      auteur: auteur ?? this.auteur,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      imageBase64: imageBase64 ?? this.imageBase64,
      available: available ?? this.available,
      categorie: categorie ?? this.categorie,
    );
  }

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
