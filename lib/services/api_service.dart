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
    } on SocketException {
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl',
      );
    } on http.ClientException {
      throw Exception('Erreur de connexion réseau');
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
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
    } on SocketException {
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl',
      );
    } on http.ClientException {
      throw Exception('Erreur de connexion réseau');
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
    } on SocketException {
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl',
      );
    } on http.ClientException {
      throw Exception('Erreur de connexion réseau');
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
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
    } on SocketException {
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl',
      );
    } on http.ClientException {
      throw Exception('Erreur de connexion réseau');
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Map<String, dynamic> handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw Exception('Réponse du serveur invalide: ${response.body}');
        }
      }
      return {};
    } else {
      String errorMessage = 'Erreur ${response.statusCode}';

      // Essayer de décoder le message d'erreur du serveur
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
        // Utiliser le code de statut si le JSON n'est pas valide
        errorMessage = _getStatusMessage(response.statusCode);
      }

      throw Exception(errorMessage);
    }
  }

  static List<dynamic> handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is List) {
            return decoded;
          } else if (decoded is Map && decoded.containsKey('data')) {
            return decoded['data'] as List? ?? [];
          } else {
            throw Exception(
              'Réponse du serveur n\'est pas une liste: ${response.body}',
            );
          }
        } catch (e) {
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
    // Debug log: [$method] $baseUrl$endpoint -> $statusCode
  }

  // Méthode pour tester la connexion
  static Future<bool> testConnection() async {
    try {
      final response = await get('/health').timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Méthode pour vérifier si le serveur est accessible
  static Future<String> checkServerStatus() async {
    try {
      await testConnection();
      return 'Serveur accessible';
    } catch (e) {
      return 'Serveur inaccessible: $e';
    }
  }
}
