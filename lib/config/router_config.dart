import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/books_screen.dart';
import '../screens/customers_screen.dart';
import '../screens/book_form_screen.dart';
import '../screens/customer_form_screen.dart';
import '../screens/dashbord.dart'; // Correction: dashbord au lieu de dashboard
import '../models/book.dart';
import '../models/customer.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return HomeScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/books',
            name: 'books',
            builder: (context, state) => const BooksScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'book-new',
                builder: (context, state) => const BookFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'book-edit',
                builder: (context, state) {
                  final bookJson = state.extra as Map<String, dynamic>?;
                  final book =
                      bookJson != null ? Book.fromJson(bookJson) : null;
                  return BookFormScreen(book: book);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/customers',
            name: 'customers',
            builder: (context, state) => const CustomersScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'customer-new',
                builder: (context, state) => const CustomerFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'customer-edit',
                builder: (context, state) {
                  final customerJson = state.extra as Map<String, dynamic>?;
                  final customer =
                      customerJson != null
                          ? Customer.fromJson(customerJson)
                          : null;
                  return CustomerFormScreen(customer: customer);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
