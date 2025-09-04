import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.50.198:8080/api';
  static const int timeoutSeconds = 30;

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<http.Response> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('Making GET request to: $uri');

      final response = await http
          .get(uri, headers: headers)
          .timeout(
            const Duration(seconds: timeoutSeconds),
            onTimeout: () {
              throw Exception(
                'Délai d\'attente dépassé. Vérifiez votre connexion.',
              );
            },
          );

      _logRequest('GET', endpoint, response.statusCode);
      return response;
    } on SocketException catch (e) {
      print('SocketException: $e');
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl\n'
        'Détails: ${e.message}',
      );
    } on http.ClientException catch (e) {
      print('ClientException: $e');
      throw Exception('Erreur de connexion réseau: ${e.message}');
    } catch (e) {
      print('Generic Exception: $e');
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('Making POST request to: $uri');

      final response = await http
          .post(uri, headers: headers, body: jsonEncode(data))
          .timeout(
            const Duration(seconds: timeoutSeconds),
            onTimeout: () {
              throw Exception(
                'Délai d\'attente dépassé. Vérifiez votre connexion.',
              );
            },
          );

      _logRequest('POST', endpoint, response.statusCode);
      return response;
    } on SocketException catch (e) {
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl\n'
        'Détails: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('Making PUT request to: $uri');

      final response = await http
          .put(uri, headers: headers, body: jsonEncode(data))
          .timeout(
            const Duration(seconds: timeoutSeconds),
            onTimeout: () {
              throw Exception(
                'Délai d\'attente dépassé. Vérifiez votre connexion.',
              );
            },
          );

      _logRequest('PUT', endpoint, response.statusCode);
      return response;
    } on SocketException catch (e) {
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl\n'
        'Détails: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      print('Making DELETE request to: $uri');

      final response = await http
          .delete(uri, headers: headers)
          .timeout(
            const Duration(seconds: timeoutSeconds),
            onTimeout: () {
              throw Exception(
                'Délai d\'attente dépassé. Vérifiez votre connexion.',
              );
            },
          );

      _logRequest('DELETE', endpoint, response.statusCode);
      return response;
    } on SocketException catch (e) {
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl\n'
        'Détails: ${e.message}',
      );
    } on http.ClientException catch (e) {
      throw Exception('Erreur de connexion réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Map<String, dynamic> handleResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          } else if (decoded is List) {
            return {'data': decoded};
          } else {
            return {'value': decoded};
          }
        } catch (e) {
          print('JSON decode error: $e');
          throw Exception('Réponse du serveur invalide: ${response.body}');
        }
      }
      return {};
    } else {
      String errorMessage = 'Erreur ${response.statusCode}';

      try {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          } else {
            errorMessage = response.body;
          }
        }
      } catch (e) {
        errorMessage = _getStatusMessage(response.statusCode);
      }

      throw Exception(errorMessage);
    }
  }

  // FIXED: Better handling for paginated and list responses
  static List<dynamic> handleListResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    print(
      'Response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);

          // Handle different response formats
          if (decoded is List) {
            // Direct list response
            return decoded;
          } else if (decoded is Map<String, dynamic>) {
            // Check for paginated response (Spring Boot Page format)
            if (decoded.containsKey('content') && decoded['content'] is List) {
              print(
                'Found paginated response with ${decoded['content'].length} items',
              );
              return decoded['content'] as List;
            }
            // Check for data wrapper
            else if (decoded.containsKey('data') && decoded['data'] is List) {
              return decoded['data'] as List;
            }
            // Single item response - wrap in list
            else {
              return [decoded];
            }
          } else {
            // Single primitive value - wrap in list
            return [decoded];
          }
        } catch (e) {
          print('JSON decode error: $e');
          throw Exception('Réponse du serveur invalide: ${response.body}');
        }
      }
      return [];
    } else {
      String errorMessage = 'Erreur ${response.statusCode}';

      try {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          } else {
            errorMessage = response.body;
          }
        }
      } catch (e) {
        errorMessage = _getStatusMessage(response.statusCode);
      }

      throw Exception(errorMessage);
    }
  }

  static String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Requête invalide (400)';
      case 401:
        return 'Non autorisé (401)';
      case 403:
        return 'Accès interdit (403)';
      case 404:
        return 'Ressource non trouvée (404)';
      case 405:
        return 'Méthode non autorisée (405)';
      case 409:
        return 'Conflit de données (409)';
      case 422:
        return 'Données invalides (422)';
      case 500:
        return 'Erreur interne du serveur (500)';
      case 502:
        return 'Passerelle défaillante (502)';
      case 503:
        return 'Service indisponible (503)';
      case 504:
        return 'Délai d\'attente de la passerelle (504)';
      default:
        return 'Erreur HTTP ($statusCode)';
    }
  }

  static void _logRequest(String method, String endpoint, int statusCode) {
    print('[$method] $baseUrl$endpoint -> $statusCode');
  }

  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: $baseUrl/health');
      final response = await get(
        '/health',
      ).timeout(const Duration(seconds: 10));
      print('Connection test result: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }

  static Future<String> checkServerStatus() async {
    try {
      final isConnected = await testConnection();
      return isConnected ? 'Serveur accessible' : 'Serveur inaccessible';
    } catch (e) {
      return 'Serveur inaccessible: $e';
    }
  }
}
