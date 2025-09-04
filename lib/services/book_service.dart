import '../models/book.dart';
import 'api_service.dart';

class BookService {
  static const String endpoint = '/books';

  static Future<List<Book>> getAllBooks() async {
    try {
      // Use the mobile-friendly endpoint that returns a direct list
      final response = await ApiService.get('$endpoint/all');
      final List<dynamic> data = ApiService.handleListResponse(response);

      print('Parsed ${data.length} books from API');
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error in getAllBooks: $e');
      rethrow;
    }
  }

  static Future<Book> getBookById(int id) async {
    try {
      final response = await ApiService.get('$endpoint/$id');
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Book.fromJson(data);
    } catch (e) {
      print('Error in getBookById: $e');
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
        '$endpoint/${book.id}',
        book.toJson(),
      );
      final Map<String, dynamic> data = ApiService.handleResponse(response);
      return Book.fromJson(data);
    } catch (e) {
      print('Error in updateBook: $e');
      rethrow;
    }
  }

  static Future<void> deleteBook(int id) async {
    try {
      await ApiService.delete('$endpoint/$id');
    } catch (e) {
      print('Error in deleteBook: $e');
      rethrow;
    }
  }

  static Future<List<Book>> searchBooks(String query) async {
    try {
      final response = await ApiService.get('$endpoint/search?keyword=$query');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error in searchBooks: $e');
      rethrow;
    }
  }

  static Future<List<Book>> getBooksByCategory(String category) async {
    try {
      // For now, we'll filter on the client side since we don't have a category endpoint
      final allBooks = await getAllBooks();
      return allBooks.where((book) => book.category == category).toList();
    } catch (e) {
      print('Error in getBooksByCategory: $e');
      rethrow;
    }
  }

  static Future<List<Book>> getAvailableBooks() async {
    try {
      final response = await ApiService.get('$endpoint/available');
      final List<dynamic> data = ApiService.handleListResponse(response);
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      print('Error in getAvailableBooks: $e');
      rethrow;
    }
  }
}
