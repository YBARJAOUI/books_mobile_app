import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static const String endpoint = '/orders';

  static Future<List<Order>> getAllOrders() async {
    final response = await ApiService.get(endpoint);
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Order.fromJson(json)).toList();
  }

  static Future<Order> getOrderById(int id) async {
    final response = await ApiService.get('$endpoint/$id');
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Order.fromJson(data);
  }

  static Future<Order> createOrder(Order order) async {
    final response = await ApiService.post(endpoint, order.toJson());
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Order.fromJson(data);
  }

  static Future<Order> updateOrder(Order order) async {
    final response = await ApiService.put('$endpoint/${order.id}', order.toJson());
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Order.fromJson(data);
  }

  static Future<void> deleteOrder(int id) async {
    await ApiService.delete('$endpoint/$id');
  }

  static Future<Order> updateOrderStatus(int orderId, OrderStatus status) async {
    final response = await ApiService.put(
      '$endpoint/$orderId/status',
      {'status': status.name},
    );
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Order.fromJson(data);
  }

  static Future<Order> updatePaymentStatus(int orderId, PaymentStatus paymentStatus) async {
    final response = await ApiService.put(
      '$endpoint/$orderId/payment-status',
      {'paymentStatus': paymentStatus.name},
    );
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Order.fromJson(data);
  }

  static Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    final response = await ApiService.get('$endpoint/status/${status.name}');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Order.fromJson(json)).toList();
  }

  static Future<List<Order>> getOrdersByCustomer(int customerId) async {
    final response = await ApiService.get('$endpoint/customer/$customerId');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Order.fromJson(json)).toList();
  }

  static Future<List<Order>> getOrdersByDateRange(DateTime startDate, DateTime endDate) async {
    final start = startDate.toIso8601String().split('T')[0];
    final end = endDate.toIso8601String().split('T')[0];
    final response = await ApiService.get('$endpoint/date-range?start=$start&end=$end');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Order.fromJson(json)).toList();
  }
}