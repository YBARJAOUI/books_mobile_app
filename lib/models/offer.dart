class Offer {
  final String title;
  final String? description;
  final bool available;
  final double prix;
  final String? imageBase64;

  Offer({
    required this.title,
    this.description,
    this.available = true,
    required this.prix,
    this.imageBase64,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      title: json['title'] ?? '',
      description: json['description'],
      available: json['available'] ?? true,
      prix: (json['prix'] ?? 0).toDouble(),
      imageBase64: json['imageBase64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'available': available,
      'prix': prix,
      'imageBase64': imageBase64,
    };
  }

  Offer copyWith({
    String? title,
    String? description,
    bool? available,
    double? prix,
    String? imageBase64,
  }) {
    return Offer(
      title: title ?? this.title,
      description: description ?? this.description,
      available: available ?? this.available,
      prix: prix ?? this.prix,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }
}
