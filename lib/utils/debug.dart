import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/book_service.dart';
import '../services/customer_service.dart';
import '../services/order_service.dart';
import '../services/pack_service.dart';
import '../services/daily_offer_service.dart';
import '../services/dashboard_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.insert(
        0,
        '${DateTime.now().toString().substring(11, 19)}: $message',
      );
      if (_logs.length > 50) {
        _logs = _logs.take(50).toList();
      }
    });
  }

  Future<void> _clearLogs() async {
    setState(() {
      _logs.clear();
    });
  }

  Future<void> _testEndpoint(
    String name,
    Future<dynamic> Function() test,
  ) async {
    _addLog('🔄 Testing $name...');
    try {
      final result = await test();
      if (result is List) {
        _addLog('✅ $name: ${result.length} items');
      } else {
        _addLog('✅ $name: Success');
      }
    } catch (e) {
      _addLog('❌ $name: $e');
    }
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
    });

    _addLog('🚀 Starting endpoint tests...');

    // Test connection
    await _testEndpoint('Connection', () async {
      return await ApiService.testConnection();
    });

    // Test statistics
    await _testEndpoint('Dashboard Stats', () async {
      return await DashboardService.getDashboardStatistics();
    });

    // Test books
    await _testEndpoint('Books', () async {
      return await BookService.getAllBooks();
    });

    // Test customers
    await _testEndpoint('Customers', () async {
      return await CustomerService.getAllCustomers();
    });

    // Test orders
    await _testEndpoint('Orders', () async {
      return await OrderService.getAllOrders();
    });

    // Test packs
    await _testEndpoint('Packs', () async {
      return await PackService.getAllPacks();
    });

    // Test daily offers
    await _testEndpoint('Daily Offers', () async {
      return await DailyOfferService.getAllDailyOffers();
    });

    _addLog('🎉 All tests completed!');

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testSpecificEndpoint(String endpoint) async {
    _addLog('🔍 Testing raw endpoint: $endpoint');
    try {
      final response = await ApiService.get(endpoint);
      _addLog('✅ Raw response status: ${response.statusCode}');

      // Try to parse as list
      final List<dynamic> data = ApiService.handleListResponse(response);
      _addLog('✅ Parsed as list: ${data.length} items');

      if (data.isNotEmpty) {
        _addLog('📋 First item keys: ${data[0].keys.toList()}');
      }
    } catch (e) {
      _addLog('❌ Raw endpoint error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug & Test'),
        actions: [
          IconButton(
            onPressed: _clearLogs,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _runAllTests,
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.play_arrow),
                        label: Text(
                          _isLoading ? 'Testing...' : 'Run All Tests',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Quick Tests:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _testSpecificEndpoint('/health'),
                      child: const Text('Health'),
                    ),
                    ElevatedButton(
                      onPressed: () => _testSpecificEndpoint('/books/all'),
                      child: const Text('Books'),
                    ),
                    ElevatedButton(
                      onPressed: () => _testSpecificEndpoint('/customers'),
                      child: const Text('Customers'),
                    ),
                    ElevatedButton(
                      onPressed: () => _testSpecificEndpoint('/orders/all'),
                      child: const Text('Orders'),
                    ),
                    ElevatedButton(
                      onPressed: () => _testSpecificEndpoint('/packs'),
                      child: const Text('Packs'),
                    ),
                    ElevatedButton(
                      onPressed: () => _testSpecificEndpoint('/daily-offers'),
                      child: const Text('Offers'),
                    ),
                    ElevatedButton(
                      onPressed:
                          () => _testSpecificEndpoint('/statistics/dashboard'),
                      child: const Text('Stats'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // Logs section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.terminal, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Logs (${_logs.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Server: ${ApiService.baseUrl}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child:
                        _logs.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bug_report_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No logs yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Run tests to see debug information',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                            : Container(
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: ListView.builder(
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  final log = _logs[index];
                                  Color textColor = Colors.white;
                                  if (log.contains('✅')) {
                                    textColor = Colors.green[300]!;
                                  } else if (log.contains('❌')) {
                                    textColor = Colors.red[300]!;
                                  } else if (log.contains('🔄') ||
                                      log.contains('🔍')) {
                                    textColor = Colors.blue[300]!;
                                  } else if (log.contains('🚀') ||
                                      log.contains('🎉')) {
                                    textColor = Colors.yellow[300]!;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      log,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: textColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
