import 'customer.dart';

class Order {
  final int? id;
  final String status;
  final Customer? client;

  Order({this.id, required this.status, this.client});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      status: json['status'] ?? '',
      client: json['client'] != null ? Customer.fromJson(json['client']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'status': status, 'client': client?.toJson()};
  }

  Order copyWith({int? id, String? status, Customer? client}) {
    return Order(
      id: id ?? this.id,
      status: status ?? this.status,
      client: client ?? this.client,
    );
  }
}
