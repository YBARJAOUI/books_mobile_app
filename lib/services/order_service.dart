import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static const String endpoint = '/orders';

  static Future<List<Order>> getAllOrders() async {
    try {
      final response = await ApiService.get(endpoint);
      final List<dynamic> data = ApiService.handleListResponse(response);

      print('Parsed ${data.length} orders from API');
      return data
          .map((json) {
            try {
              return Order.fromJson(json);
            } catch (e) {
              print('Error parsing order: $json, error: $e');
              return null;
            }
          })
          .where((order) => order != null)
          .cast<Order>()
          .toList();
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

  // Additional methods for order management
  static Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final response = await ApiService.get('$endpoint/status/$status');
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

  static Future<Order> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final response = await ApiService.put('$endpoint/$orderId/status', {
        'status': newStatus,
      });
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Order.fromJson(data);
    } catch (e) {
      print('Error in updateOrderStatus: $e');
      rethrow;
    }
  }
}
