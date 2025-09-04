import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ConnectionTestWidget extends StatefulWidget {
  const ConnectionTestWidget({super.key});

  @override
  State<ConnectionTestWidget> createState() => _ConnectionTestWidgetState();
}

class _ConnectionTestWidgetState extends State<ConnectionTestWidget> {
  bool _isConnected = false;
  bool _isTesting = false;
  String _statusMessage = 'Non testé';
  String _serverInfo = '';

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _statusMessage = 'Test en cours...';
    });

    try {
      // Test de base
      final isConnected = await ApiService.testConnection();

      String info = 'URL du serveur: ${ApiService.baseUrl}\n';

      if (isConnected) {
        try {
          // Essayer de récupérer les informations du serveur
          final response = await ApiService.get('/info');
          final data = ApiService.handleResponse(response);
          info += 'Nom: ${data['name'] ?? 'N/A'}\n';
          info += 'Version: ${data['version'] ?? 'N/A'}\n';
          info += 'Description: ${data['description'] ?? 'N/A'}';
        } catch (e) {
          info += 'Informations détaillées non disponibles';
        }
      } else {
        info += 'Impossible de se connecter au serveur.\n';
        info += 'Vérifiez que :\n';
        info += '• Le serveur backend est démarré\n';
        info += '• L\'adresse IP est correcte\n';
        info += '• Le port 8080 est ouvert\n';
        info += '• Votre appareil est sur le même réseau';
      }

      setState(() {
        _isConnected = isConnected;
        _statusMessage =
            isConnected ? 'Connexion réussie' : 'Connexion échouée';
        _serverInfo = info;
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _statusMessage = 'Erreur: $e';
        _serverInfo =
            'URL du serveur: ${ApiService.baseUrl}\n'
            'Erreur de connexion: $e';
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isTesting
                      ? Icons.sync
                      : _isConnected
                      ? Icons.check_circle
                      : Icons.error,
                  color:
                      _isTesting
                          ? Colors.blue
                          : _isConnected
                          ? Colors.green
                          : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'État de la connexion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!_isTesting)
                  IconButton(
                    onPressed: _testConnection,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Tester à nouveau',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: TextStyle(
                color:
                    _isTesting
                        ? Colors.blue
                        : _isConnected
                        ? Colors.green
                        : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_isTesting) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 16),
            const Text(
              'Informations du serveur:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _serverInfo.isEmpty
                    ? 'Aucune information disponible'
                    : _serverInfo,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            if (!_isConnected && !_isTesting) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Guide de dépannage',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Vérifiez que le serveur Spring Boot est démarré\n'
                      '2. Ouvrez http://localhost:8080/api/health dans un navigateur\n'
                      '3. Si ça marche, changez l\'IP dans ApiService\n'
                      '4. Utilisez `ipconfig` (Windows) ou `ifconfig` (Mac/Linux) pour trouver votre IP\n'
                      '5. Assurez-vous que votre téléphone et PC sont sur le même réseau WiFi',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
