import '../models/book.dart';
import 'api_service.dart';

class BookService {
  static const String endpoint = '/books';

  static Future<List<Book>> getAllBooks() async {
    final response = await ApiService.get(endpoint);
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Book.fromJson(json)).toList();
  }

  static Future<Book> getBookById(int id) async {
    final response = await ApiService.get('$endpoint/$id');
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Book.fromJson(data);
  }

  static Future<Book> createBook(Book book) async {
    final response = await ApiService.post(endpoint, book.toJson());
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Book.fromJson(data);
  }

  static Future<Book> updateBook(Book book) async {
    final response = await ApiService.put('$endpoint/${book.id}', book.toJson());
    final Map<String, dynamic> data = ApiService.handleResponse(response);
    return Book.fromJson(data);
  }

  static Future<void> deleteBook(int id) async {
    await ApiService.delete('$endpoint/$id');
  }

  static Future<List<Book>> searchBooks(String query) async {
    final response = await ApiService.get('$endpoint/search?q=$query');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Book.fromJson(json)).toList();
  }

  static Future<List<Book>> getBooksByCategory(String category) async {
    final response = await ApiService.get('$endpoint/category/$category');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Book.fromJson(json)).toList();
  }

  static Future<List<Book>> getAvailableBooks() async {
    final response = await ApiService.get('$endpoint/available');
    final List<dynamic> data = ApiService.handleListResponse(response);
    return data.map((json) => Book.fromJson(json)).toList();
  }
}