import '../models/pack.dart';
import 'api_service.dart';

class PackService {
  static const String endpoint = '/packs';

  static Future<List<Pack>> getAllPacks() async {
    final response = await ApiService.get(endpoint);
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Pack.fromJson(json)).toList();
  }

  static Future<Pack> getPackById(int id) async {
    final response = await ApiService.get('$endpoint/$id');
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Pack.fromJson(data);
  }

  static Future<Pack> createPack(Pack pack) async {
    final response = await ApiService.post(endpoint, pack.toJson());
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Pack.fromJson(data);
  }

  static Future<Pack> updatePack(Pack pack) async {
    final response = await ApiService.put('$endpoint/${pack.id}', pack.toJson());
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Pack.fromJson(data);
  }

  static Future<void> deletePack(int id) async {
    await ApiService.delete('$endpoint/$id');
  }

  static Future<List<Pack>> getActivePacks() async {
    final response = await ApiService.get('$endpoint/active');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Pack.fromJson(json)).toList();
  }

  static Future<List<Pack>> getFeaturedPacks() async {
    final response = await ApiService.get('$endpoint/featured');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Pack.fromJson(json)).toList();
  }

  static Future<List<Pack>> searchPacks(String query) async {
    final response = await ApiService.get('$endpoint/search?q=$query');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Pack.fromJson(json)).toList();
  }
}