import '../models/customer.dart';
import 'api_service.dart';

class CustomerService {
  static const String endpoint = '/customers';

  static Future<List<Customer>> getAllCustomers() async {
    final response = await ApiService.get(endpoint);
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Customer.fromJson(json)).toList();
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
    final response = await ApiService.get('$endpoint/search?q=$query');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Customer.fromJson(json)).toList();
  }

  static Future<List<Customer>> getActiveCustomers() async {
    final response = await ApiService.get('$endpoint/active');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Customer.fromJson(json)).toList();
  }
}