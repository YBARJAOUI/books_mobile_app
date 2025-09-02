import 'package:bookstore_backoffice/screens/dashbord.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/books_screen.dart';
import '../screens/customers_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/packs_screen.dart';
import '../screens/daily_offers_screen.dart';
import '../screens/book_form_screen.dart';
import '../screens/customer_form_screen.dart';
import '../screens/pack_form_screen.dart';
import '../screens/daily_offer_form_screen.dart';
import '../models/book.dart';
import '../models/customer.dart';
import '../models/pack.dart';
import '../models/daily_offer.dart';

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
          GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/packs',
            name: 'packs',
            builder: (context, state) => const PacksScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'pack-new',
                builder: (context, state) => const PackFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'pack-edit',
                builder: (context, state) {
                  final packJson = state.extra as Map<String, dynamic>?;
                  final pack =
                      packJson != null ? Pack.fromJson(packJson) : null;
                  return PackFormScreen(pack: pack);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/daily-offers',
            name: 'daily-offers',
            builder: (context, state) => const DailyOffersScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'daily-offer-new',
                builder: (context, state) => const DailyOfferFormScreen(),
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'daily-offer-edit',
                builder: (context, state) {
                  final offerJson = state.extra as Map<String, dynamic>?;
                  final offer =
                      offerJson != null ? DailyOffer.fromJson(offerJson) : null;
                  return DailyOfferFormScreen(offer: offer);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
