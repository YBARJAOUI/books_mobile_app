class Customer {
  final int? id;
  final String nom;
  final String phoneNumber;
  final String address;
  final String city;
  final bool blacklisted;

  Customer({
    this.id,
    required this.nom,
    required this.phoneNumber,
    required this.address,
    required this.city,
    this.blacklisted = false,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      nom: json['nom'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      blacklisted: json['blacklisted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'blacklisted': blacklisted,
    };
  }

  Customer copyWith({
    int? id,
    String? nom,
    String? phoneNumber,
    String? address,
    String? city,
    bool? blacklisted,
  }) {
    return Customer(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      blacklisted: blacklisted ?? this.blacklisted,
    );
  }

  // Helper getters for compatibility
  String get fullName => nom;
  bool get isActive => !blacklisted;
  DateTime? get createdAt => null; // Not available in backend
}
