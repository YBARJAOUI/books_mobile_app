import '../models/offer.dart';
import 'api_service.dart';

class OfferService {
  static const String endpoint = '/offres';

  static Future<List<Offer>> getAllOffers() async {
    try {
      final response = await ApiService.get(endpoint);
      final List<dynamic> data = ApiService.handleListResponse(response);

      print('Parsed ${data.length} offers from API');
      return data.map((json) => Offer.fromJson(json)).toList();
    } catch (e) {
      print('Error in getAllOffers: $e');
      rethrow;
    }
  }

  static Future<Offer> getOfferByTitle(String title) async {
    try {
      final response = await ApiService.get('$endpoint/$title');
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Offer.fromJson(data);
    } catch (e) {
      print('Error in getOfferByTitle: $e');
      rethrow;
    }
  }

  static Future<Offer> createOffer(Offer offer) async {
    try {
      final response = await ApiService.post(endpoint, offer.toJson());
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Offer.fromJson(data);
    } catch (e) {
      print('Error in createOffer: $e');
      rethrow;
    }
  }

  static Future<Offer> updateOffer(Offer offer) async {
    try {
      final response = await ApiService.put(
        '$endpoint/${offer.title}',
        offer.toJson(),
      );
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Offer.fromJson(data);
    } catch (e) {
      print('Error in updateOffer: $e');
      rethrow;
    }
  }

  static Future<void> deleteOffer(String title) async {
    try {
      await ApiService.delete('$endpoint/$title');
    } catch (e) {
      print('Error in deleteOffer: $e');
      rethrow;
    }
  }

  static Future<List<Offer>> searchByTitle(String title) async {
    try {
      final response = await ApiService.get(
        '$endpoint/search/byTitle?title=$title',
      );
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Offer.fromJson(json)).toList();
    } catch (e) {
      print('Error in searchByTitle: $e');
      rethrow;
    }
  }

  static Future<List<Offer>> searchByPrix(double prix) async {
    try {
      final response = await ApiService.get(
        '$endpoint/search/byPrix?prix=$prix',
      );
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Offer.fromJson(json)).toList();
    } catch (e) {
      print('Error in searchByPrix: $e');
      rethrow;
    }
  }
}
