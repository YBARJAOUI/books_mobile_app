import '../models/daily_offer.dart';
import 'api_service.dart';

class DailyOfferService {
  static const String endpoint = '/daily-offers';

  static Future<List<DailyOffer>> getAllDailyOffers() async {
    final response = await ApiService.get(endpoint);
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => DailyOffer.fromJson(json)).toList();
  }

  static Future<DailyOffer> getDailyOfferById(int id) async {
    final response = await ApiService.get('$endpoint/$id');
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return DailyOffer.fromJson(data);
  }

  static Future<DailyOffer> createDailyOffer(DailyOffer offer) async {
    final response = await ApiService.post(endpoint, offer.toJson());
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return DailyOffer.fromJson(data);
  }

  static Future<DailyOffer> updateDailyOffer(DailyOffer offer) async {
    final response = await ApiService.put('$endpoint/${offer.id}', offer.toJson());
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return DailyOffer.fromJson(data);
  }

  static Future<void> deleteDailyOffer(int id) async {
    await ApiService.delete('$endpoint/$id');
  }

  static Future<List<DailyOffer>> getActiveOffers() async {
    final response = await ApiService.get('$endpoint/active');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => DailyOffer.fromJson(json)).toList();
  }

  static Future<List<DailyOffer>> getCurrentOffers() async {
    final response = await ApiService.get('$endpoint/current');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => DailyOffer.fromJson(json)).toList();
  }

  static Future<List<DailyOffer>> getOffersByDateRange(DateTime startDate, DateTime endDate) async {
    final start = startDate.toIso8601String().split('T')[0];
    final end = endDate.toIso8601String().split('T')[0];
    final response = await ApiService.get('$endpoint/date-range?start=$start&end=$end');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => DailyOffer.fromJson(json)).toList();
  }
}