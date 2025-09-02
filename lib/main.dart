import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/router_config.dart';

void main() {
  runApp(const BookstoreBackofficeApp());
}

// Provider pour gérer l'état global de l'application
class AppStateProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _currentUser = 'Admin';
  String _selectedNavLocation = '/dashboard';

  bool get isLoading => _isLoading;
  String get currentUser => _currentUser;
  String get selectedNavLocation => _selectedNavLocation;

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
}

class BookstoreBackofficeApp extends StatelessWidget {
  const BookstoreBackofficeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppStateProvider())],
      child: MaterialApp.router(
        title: 'Bookstore Backoffice',
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
