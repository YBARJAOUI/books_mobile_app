import '../models/book.dart';
import 'api_service.dart';

class BookService {
  static const String endpoint = '/books';

  static Future<List<Book>> getAllBooks() async {
    try {
      final response = await ApiService.get(endpoint);
      final List<dynamic> data = ApiService.handleListResponse(response);

      print('Parsed ${data.length} books from API');
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error in getAllBooks: $e');
      rethrow;
    }
  }

  static Future<Book> getBookByTitle(String title) async {
    try {
      final response = await ApiService.get('$endpoint/$title');
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Book.fromJson(data);
    } catch (e) {
      print('Error in getBookByTitle: $e');
      rethrow;
    }
  }

  static Future<Book> createBook(Book book) async {
    try {
      final response = await ApiService.post(endpoint, book.toJson());
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Book.fromJson(data);
    } catch (e) {
      print('Error in createBook: $e');
      rethrow;
    }
  }

  static Future<Book> updateBook(Book book) async {
    try {
      final response = await ApiService.put(
        '$endpoint/${book.title}',
        book.toJson(),
      );
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Book.fromJson(data);
    } catch (e) {
      print('Error in updateBook: $e');
      rethrow;
    }
  }

  static Future<void> deleteBook(String title) async {
    try {
      await ApiService.delete('$endpoint/$title');
    } catch (e) {
      print('Error in deleteBook: $e');
      rethrow;
    }
  }

  static Future<List<Book>> searchByTitle(String title) async {
    try {
      final response = await ApiService.get('$endpoint/search/byTitle?title=$title');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error in searchByTitle: $e');
      rethrow;
    }
  }

  static Future<List<Book>> searchByAuteur(String auteur) async {
    try {
      final response = await ApiService.get('$endpoint/search/byAuteur?auteur=$auteur');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error in searchByAuteur: $e');
      rethrow;
    }
  }

  static Future<List<Book>> searchByCategorie(String categorie) async {
    try {
      final response = await ApiService.get('$endpoint/search/byCategorie?categorie=$categorie');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error in searchByCategorie: $e');
      rethrow;
    }
  }

  static Future<List<Book>> searchByPrix(double prix) async {
    try {
      final response = await ApiService.get('$endpoint/search/byPrix?prix=$prix');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error in searchByPrix: $e');
      rethrow;
    }
  }
}
