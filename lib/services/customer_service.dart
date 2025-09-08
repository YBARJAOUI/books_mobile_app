import '../models/customer.dart';
import 'api_service.dart';

class CustomerService {
  static const String endpoint = '/customers';

  static Future<List<Customer>> getAllCustomers() async {
    try {
      final response = await ApiService.get(endpoint);
      final List<dynamic> data = ApiService.handleListResponse(response);
      
      return data.map((json) {
        try {
          return Customer.fromJson(json);
        } catch (e) {
          print('Error parsing customer: $json, error: $e');
          return null;
        }
      }).where((customer) => customer != null).cast<Customer>().toList();
    } catch (e) {
      print('Error in getAllCustomers: $e');
      rethrow;
    }
  }

  static Future<Customer> getCustomerById(int id) async {
    final response = await ApiService.get('$endpoint/$id');
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Customer.fromJson(data);
  }

  static Future<Customer> createCustomer(Customer customer) async {
    final response = await ApiService.post(endpoint, customer.toJson());
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Customer.fromJson(data);
  }

  static Future<Customer> updateCustomer(Customer customer) async {
    final response = await ApiService.put('$endpoint/${customer.id}', customer.toJson());
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Customer.fromJson(data);
  }

  static Future<void> deleteCustomer(int id) async {
    await ApiService.delete('$endpoint/$id');
  }

  static Future<List<Customer>> searchCustomers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return getAllCustomers();
      }
      
      final encodedQuery = Uri.encodeQueryComponent(query);
      final response = await ApiService.get('$endpoint/search?q=$encodedQuery');
      final List<dynamic> data = ApiService.handleListResponse(response);
      
      return data.map((json) {
        try {
          return Customer.fromJson(json);
        } catch (e) {
          print('Error parsing customer in search: $json, error: $e');
          return null;
        }
      }).where((customer) => customer != null).cast<Customer>().toList();
    } catch (e) {
      print('Error in searchCustomers: $e');
      rethrow;
    }
  }

  static Future<List<Customer>> getActiveCustomers() async {
    try {
      final response = await ApiService.get('$endpoint/active');
      final List<dynamic> data = ApiService.handleListResponse(response);
      
      return data.map((json) {
        try {
          return Customer.fromJson(json);
        } catch (e) {
          print('Error parsing active customer: $json, error: $e');
          return null;
        }
      }).where((customer) => customer != null).cast<Customer>().toList();
    } catch (e) {
      print('Error in getActiveCustomers: $e');
      rethrow;
    }
  }
}