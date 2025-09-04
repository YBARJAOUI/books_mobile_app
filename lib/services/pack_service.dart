import '../models/pack.dart';
import 'api_service.dart';

class PackService {
  static const String endpoint = '/packs';

  static Future<List<Pack>> getAllPacks() async {
    try {
      // For packs, we can use the regular endpoint since it already returns a list
      final response = await ApiService.get(endpoint);
      final List<dynamic> data = ApiService.handleListResponse(response);

      print('Parsed ${data.length} packs from API');
      return data.map((json) => Pack.fromJson(json)).toList();
    } catch (e) {
      print('Error in getAllPacks: $e');
      rethrow;
    }
  }

  static Future<Pack> getPackById(int id) async {
    try {
      final response = await ApiService.get('$endpoint/$id');
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Pack.fromJson(data);
    } catch (e) {
      print('Error in getPackById: $e');
      rethrow;
    }
  }

  static Future<Pack> createPack(Pack pack) async {
    try {
      final response = await ApiService.post(endpoint, pack.toJson());
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Pack.fromJson(data);
    } catch (e) {
      print('Error in createPack: $e');
      rethrow;
    }
  }

  static Future<Pack> updatePack(Pack pack) async {
    try {
      final response = await ApiService.put(
        '$endpoint/${pack.id}',
        pack.toJson(),
      );
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Pack.fromJson(data);
    } catch (e) {
      print('Error in updatePack: $e');
      rethrow;
    }
  }

  static Future<void> deletePack(int id) async {
    try {
      await ApiService.delete('$endpoint/$id');
    } catch (e) {
      print('Error in deletePack: $e');
      rethrow;
    }
  }

  static Future<List<Pack>> getActivePacks() async {
    try {
      final response = await ApiService.get('$endpoint/active');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Pack.fromJson(json)).toList();
    } catch (e) {
      print('Error in getActivePacks: $e');
      rethrow;
    }
  }

  static Future<List<Pack>> getFeaturedPacks() async {
    try {
      final response = await ApiService.get('$endpoint/featured');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Pack.fromJson(json)).toList();
    } catch (e) {
      print('Error in getFeaturedPacks: $e');
      rethrow;
    }
  }

  static Future<List<Pack>> searchPacks(String query) async {
    try {
      final response = await ApiService.get('$endpoint/search?keyword=$query');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Pack.fromJson(json)).toList();
    } catch (e) {
      print('Error in searchPacks: $e');
      rethrow;
    }
  }
}
