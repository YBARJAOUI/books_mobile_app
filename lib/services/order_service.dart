import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static const String endpoint = '/orders';

  static Future<List<Order>> getAllOrders() async {
    try {
      // Use the mobile-friendly endpoint that returns a direct list
      final response = await ApiService.get('$endpoint/all');
      final List<dynamic> data = ApiService.handleListResponse(response);

      print('Parsed ${data.length} orders from API');
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error in getAllOrders: $e');
      rethrow;
    }
  }

  static Future<Order> getOrderById(int id) async {
    try {
      final response = await ApiService.get('$endpoint/$id');
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Order.fromJson(data);
    } catch (e) {
      print('Error in getOrderById: $e');
      rethrow;
    }
  }

  static Future<Order> createOrder(Order order) async {
    try {
      final response = await ApiService.post(endpoint, order.toJson());
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Order.fromJson(data);
    } catch (e) {
      print('Error in createOrder: $e');
      rethrow;
    }
  }

  static Future<Order> updateOrder(Order order) async {
    try {
      final response = await ApiService.put(
        '$endpoint/${order.id}',
        order.toJson(),
      );
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Order.fromJson(data);
    } catch (e) {
      print('Error in updateOrder: $e');
      rethrow;
    }
  }

  static Future<void> deleteOrder(int id) async {
    try {
      await ApiService.delete('$endpoint/$id');
    } catch (e) {
      print('Error in deleteOrder: $e');
      rethrow;
    }
  }

  static Future<Order> updateOrderStatus(
    int orderId,
    OrderStatus status,
  ) async {
    try {
      final response = await ApiService.put('$endpoint/$orderId/status', {
        'status': status.name,
      });
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Order.fromJson(data);
    } catch (e) {
      print('Error in updateOrderStatus: $e');
      rethrow;
    }
  }

  static Future<Order> updatePaymentStatus(
    int orderId,
    PaymentStatus paymentStatus,
  ) async {
    try {
      final response = await ApiService.put(
        '$endpoint/$orderId/payment-status',
        {'paymentStatus': paymentStatus.name},
      );
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Order.fromJson(data);
    } catch (e) {
      print('Error in updatePaymentStatus: $e');
      rethrow;
    }
  }

  static Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      final response = await ApiService.get('$endpoint/status/${status.name}');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error in getOrdersByStatus: $e');
      rethrow;
    }
  }

  static Future<List<Order>> getOrdersByCustomer(int customerId) async {
    try {
      final response = await ApiService.get('$endpoint/customer/$customerId');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error in getOrdersByCustomer: $e');
      rethrow;
    }
  }

  static Future<List<Order>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final start = startDate.toIso8601String().split('T')[0];
      final end = endDate.toIso8601String().split('T')[0];
      final response = await ApiService.get(
        '$endpoint/date-range?start=$start&end=$end',
      );
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error in getOrdersByDateRange: $e');
      rethrow;
    }
  }
}
