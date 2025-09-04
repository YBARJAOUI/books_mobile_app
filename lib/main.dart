import 'package:bookstore_backoffice/widgets/connectiontest.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/router_config.dart';

void main() {
  runApp(const BookstoreBackofficeApp());
}

// Provider لإدارة الحالة العامة للتطبيق
class AppStateProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _currentUser = 'Admin';
  String _selectedNavLocation = '/dashboard';
  bool _showConnectionTest = false; // New property

  bool get isLoading => _isLoading;
  String get currentUser => _currentUser;
  String get selectedNavLocation => _selectedNavLocation;
  bool get showConnectionTest => _showConnectionTest;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setCurrentUser(String user) {
    _currentUser = user;
    notifyListeners();
  }

  void setSelectedNavLocation(String location) {
    _selectedNavLocation = location;
    notifyListeners();
  }

  void toggleConnectionTest() {
    _showConnectionTest = !_showConnectionTest;
    notifyListeners();
  }
}

class BookstoreBackofficeApp extends StatelessWidget {
  const BookstoreBackofficeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppStateProvider())],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp.router(
            title: 'إدارة المكتبة',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 2,
                centerTitle: true,
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(8),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              // Show connection test overlay if enabled
              return Stack(
                children: [
                  child ?? const SizedBox.shrink(),
                  if (appState.showConnectionTest)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: Material(
                          elevation: 8,
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: [
                                const ConnectionTestWidget(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: appState.toggleConnectionTest,
                                    child: const Text(
                                      'إغلاق اختبار الاتصال',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
