import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.50.141:8080/api';
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
      print('SocketException in POST: $e');
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl\n'
        'Détails: ${e.message}',
      );
    } on http.ClientException catch (e) {
      print('ClientException in POST: $e');
      throw Exception('Erreur de connexion réseau: ${e.message}');
    } on FormatException catch (e) {
      print('FormatException in POST: $e');
      throw Exception('Erreur de format des données: ${e.message}');
    } catch (e) {
      print('Generic Exception in POST: $e');
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
      print('SocketException in PUT: $e');
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl\n'
        'Détails: ${e.message}',
      );
    } on http.ClientException catch (e) {
      print('ClientException in PUT: $e');
      throw Exception('Erreur de connexion réseau: ${e.message}');
    } on FormatException catch (e) {
      print('FormatException in PUT: $e');
      throw Exception('Erreur de format des données: ${e.message}');
    } catch (e) {
      print('Generic Exception in PUT: $e');
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
      print('SocketException in DELETE: $e');
      throw Exception(
        'Impossible de se connecter au serveur. Vérifiez que le serveur est démarré sur $baseUrl\n'
        'Détails: ${e.message}',
      );
    } on http.ClientException catch (e) {
      print('ClientException in DELETE: $e');
      throw Exception('Erreur de connexion réseau: ${e.message}');
    } on FormatException catch (e) {
      print('FormatException in DELETE: $e');
      throw Exception('Erreur de format: ${e.message}');
    } catch (e) {
      print('Generic Exception in DELETE: $e');
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
          print('Raw response body: ${response.body}');
          throw Exception('Réponse du serveur invalide - JSON malformé');
        }
      }
      return {};
    } else {
      String errorMessage = _getStatusMessage(response.statusCode);

      try {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            if (errorData.containsKey('message') && errorData['message'] != null) {
              errorMessage = errorData['message'].toString();
            } else if (errorData.containsKey('error') && errorData['error'] != null) {
              errorMessage = errorData['error'].toString();
            } else if (errorData.containsKey('details')) {
              errorMessage = errorData['details'].toString();
            }
          } else if (errorData is String) {
            errorMessage = errorData;
          }
        }
      } catch (e) {
        print('Error parsing error response: $e');
      }

      throw Exception(errorMessage);
    }
  }

  static List<dynamic> handleListResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    final bodyPreview = response.body.length > 500 
        ? '${response.body.substring(0, 500)}...' 
        : response.body;
    print('Response body preview: $bodyPreview');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is List) {
            print('Found direct list response with ${decoded.length} items');
            return decoded;
          } else if (decoded is Map<String, dynamic>) {
            // Spring Boot Page format
            if (decoded.containsKey('content') && decoded['content'] is List) {
              final content = decoded['content'] as List;
              print('Found paginated response with ${content.length} items');
              print('Total elements: ${decoded['totalElements'] ?? 'unknown'}');
              return content;
            }
            // Generic data wrapper
            else if (decoded.containsKey('data') && decoded['data'] is List) {
              final data = decoded['data'] as List;
              print('Found wrapped response with ${data.length} items');
              return data;
            }
            // Single item - wrap in list
            else {
              print('Single item response, wrapping in list');
              return [decoded];
            }
          } else {
            print('Primitive value response, wrapping in list');
            return [decoded];
          }
        } catch (e) {
          print('JSON decode error in handleListResponse: $e');
          print('Raw response body: ${response.body}');
          throw Exception('Réponse du serveur invalide - JSON malformé');
        }
      }
      print('Empty response body, returning empty list');
      return [];
    } else {
      String errorMessage = _getStatusMessage(response.statusCode);

      try {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            if (errorData.containsKey('message') && errorData['message'] != null) {
              errorMessage = errorData['message'].toString();
            } else if (errorData.containsKey('error') && errorData['error'] != null) {
              errorMessage = errorData['error'].toString();
            }
          }
        }
      } catch (e) {
        print('Error parsing list error response: $e');
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
      final response = await get('/health').timeout(const Duration(seconds: 10));
      print('Connection test result: ${response.statusCode}');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Health endpoint failed, trying alternative endpoints...');
      try {
        final response = await get('/customers').timeout(const Duration(seconds: 5));
        print('Customers endpoint test result: ${response.statusCode}');
        return response.statusCode >= 200 && response.statusCode < 500;
      } catch (e2) {
        print('Connection test completely failed: $e2');
        return false;
      }
    }
  }

  static Future<String> checkServerStatus() async {
    try {
      print('Checking server status...');
      final isConnected = await testConnection();
      return isConnected 
          ? 'Serveur accessible sur $baseUrl' 
          : 'Serveur inaccessible sur $baseUrl';
    } catch (e) {
      return 'Erreur de connexion: ${e.toString().replaceAll('Exception: ', '')}';
    }
  }

  static Future<Map<String, dynamic>> getConnectionInfo() async {
    final startTime = DateTime.now();
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));
      
      final endTime = DateTime.now();
      final latency = endTime.difference(startTime).inMilliseconds;
      
      return {
        'connected': response.statusCode >= 200 && response.statusCode < 300,
        'statusCode': response.statusCode,
        'latency': latency,
        'server': baseUrl,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      final endTime = DateTime.now();
      final latency = endTime.difference(startTime).inMilliseconds;
      
      return {
        'connected': false,
        'error': e.toString(),
        'latency': latency,
        'server': baseUrl,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
