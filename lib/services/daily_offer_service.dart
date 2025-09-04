import '../models/daily_offer.dart';
import 'api_service.dart';

class DailyOfferService {
  static const String endpoint = '/daily-offers';

  static Future<List<DailyOffer>> getAllDailyOffers() async {
    try {
      // For daily offers, we can use the regular endpoint since it already returns a list
      final response = await ApiService.get(endpoint);
      final List<dynamic> data = ApiService.handleListResponse(response);

      print('Parsed ${data.length} daily offers from API');
      return data.map((json) => DailyOffer.fromJson(json)).toList();
    } catch (e) {
      print('Error in getAllDailyOffers: $e');
      rethrow;
    }
  }

  static Future<DailyOffer> getDailyOfferById(int id) async {
    try {
      final response = await ApiService.get('$endpoint/$id');
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return DailyOffer.fromJson(data);
    } catch (e) {
      print('Error in getDailyOfferById: $e');
      rethrow;
    }
  }

  static Future<DailyOffer> createDailyOffer(DailyOffer offer) async {
    try {
      final response = await ApiService.post(endpoint, offer.toJson());
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return DailyOffer.fromJson(data);
    } catch (e) {
      print('Error in createDailyOffer: $e');
      rethrow;
    }
  }

  static Future<DailyOffer> updateDailyOffer(DailyOffer offer) async {
    try {
      final response = await ApiService.put(
        '$endpoint/${offer.id}',
        offer.toJson(),
      );
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return DailyOffer.fromJson(data);
    } catch (e) {
      print('Error in updateDailyOffer: $e');
      rethrow;
    }
  }

  static Future<void> deleteDailyOffer(int id) async {
    try {
      await ApiService.delete('$endpoint/$id');
    } catch (e) {
      print('Error in deleteDailyOffer: $e');
      rethrow;
    }
  }

  static Future<List<DailyOffer>> getActiveOffers() async {
    try {
      final response = await ApiService.get('$endpoint/active');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => DailyOffer.fromJson(json)).toList();
    } catch (e) {
      print('Error in getActiveOffers: $e');
      rethrow;
    }
  }

  static Future<List<DailyOffer>> getCurrentOffers() async {
    try {
      final response = await ApiService.get('$endpoint/current');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => DailyOffer.fromJson(json)).toList();
    } catch (e) {
      print('Error in getCurrentOffers: $e');
      rethrow;
    }
  }

  static Future<List<DailyOffer>> getOffersByDateRange(
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
      return data.map((json) => DailyOffer.fromJson(json)).toList();
    } catch (e) {
      print('Error in getOffersByDateRange: $e');
      rethrow;
    }
  }
}
