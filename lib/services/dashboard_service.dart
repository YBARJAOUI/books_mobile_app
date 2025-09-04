import '../services/api_service.dart';

class DashboardService {
  static const String endpoint = '/statistics';

  static Future<Map<String, dynamic>> getDashboardStatistics() async {
    final response = await ApiService.get('$endpoint/dashboard');
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return data;
  }

  static Future<int> getTotalBooksCount() async {
    final response = await ApiService.get('$endpoint/books/count');
    final data = ApiService.handleResponse(response);
    return data as int? ?? 0;
  }

  static Future<int> getTotalCustomersCount() async {
    final response = await ApiService.get('$endpoint/customers/count');
    final data = ApiService.handleResponse(response);
    return data as int? ?? 0;
  }

  static Future<int> getTotalOrdersCount() async {
    final response = await ApiService.get('$endpoint/orders/count');
    final data = ApiService.handleResponse(response);
    return data as int? ?? 0;
  }

  static Future<int> getTotalPacksCount() async {
    final response = await ApiService.get('$endpoint/packs/count');
    final data = ApiService.handleResponse(response);
    return data as int? ?? 0;
  }

  static Future<int> getTotalOffersCount() async {
    final response = await ApiService.get('$endpoint/offers/count');
    final data = ApiService.handleResponse(response);
    return data as int? ?? 0;
  }

  static Future<double> getTotalRevenue() async {
    final response = await ApiService.get('$endpoint/revenue/total');
    final data = ApiService.handleResponse(response);
    return (data as num?)?.toDouble() ?? 0.0;
  }

  static Future<int> getActiveBooksCount() async {
    final response = await ApiService.get('$endpoint/books/active/count');
    final data = ApiService.handleResponse(response);
    return data as int? ?? 0;
  }

  static Future<int> getActiveCustomersCount() async {
    final response = await ApiService.get('$endpoint/customers/active/count');
    final data = ApiService.handleResponse(response);
    return data as int? ?? 0;
  }

  static Future<int> getPendingOrdersCount() async {
    final response = await ApiService.get('$endpoint/orders/pending/count');
    final data = ApiService.handleResponse(response);
    return data as int? ?? 0;
  }

  static Future<int> getActiveOffersCount() async {
    final response = await ApiService.get('$endpoint/offers/active/count');
    final data = ApiService.handleResponse(response);
    return data as int? ?? 0;
  }
}
