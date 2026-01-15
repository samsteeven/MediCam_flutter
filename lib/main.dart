import 'package:easypharma_flutter/presentation/providers/delivery_provider.dart';
import 'package:easypharma_flutter/data/repositories/delivery_repository.dart';
import 'package:easypharma_flutter/presentation/screens/home/delivery_home_screen.dart';
import 'package:easypharma_flutter/presentation/providers/location_provider.dart';
import 'package:easypharma_flutter/presentation/screens/auth/forgot_password_screen.dart';
import 'package:easypharma_flutter/presentation/screens/auth/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:easypharma_flutter/core/services/deeplink_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easypharma_flutter/core/services/api_service.dart';
import 'package:easypharma_flutter/data/repositories/auth_repository.dart';
import 'package:easypharma_flutter/data/repositories/medication_repository.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/presentation/providers/medication_provider.dart';
import 'package:easypharma_flutter/presentation/providers/notification_provider.dart';
import 'package:easypharma_flutter/presentation/providers/cart_provider.dart';
import 'package:easypharma_flutter/data/repositories/prescription_repository.dart';
import 'package:easypharma_flutter/presentation/providers/prescription_provider.dart';
import 'package:easypharma_flutter/presentation/providers/orders_provider.dart';
import 'package:easypharma_flutter/data/repositories/review_repository.dart';
import 'package:easypharma_flutter/presentation/providers/review_provider.dart';
import 'package:easypharma_flutter/data/repositories/notification_repository.dart';
import 'package:easypharma_flutter/data/repositories/orders_repository.dart';
import 'package:easypharma_flutter/data/repositories/pharmacies_repository.dart';
import 'package:easypharma_flutter/presentation/providers/pharmacies_provider.dart';
// import 'package:easypharma_flutter/core/constants/app_constants.dart';

// Import des écrans...
import 'package:easypharma_flutter/presentation/screens/splash_screen.dart';
import 'package:easypharma_flutter/presentation/screens/auth/login_screen.dart';
import 'package:easypharma_flutter/presentation/screens/auth/register_screen.dart';
import 'package:easypharma_flutter/presentation/screens/profile/profile_screen.dart';
import 'package:easypharma_flutter/presentation/screens/profile/edit_profile_screen.dart';
import 'package:easypharma_flutter/presentation/screens/profile/notification_center_screen.dart';
import 'package:easypharma_flutter/presentation/screens/home/patient_home_screen.dart';
import 'package:easypharma_flutter/presentation/screens/orders/orders_screen.dart';
import 'package:easypharma_flutter/presentation/screens/orders/order_details_screen.dart';
import 'package:easypharma_flutter/presentation/screens/cart/cart_screen.dart';
import 'package:easypharma_flutter/presentation/screens/checkout/checkout_screen.dart';
import 'package:easypharma_flutter/presentation/screens/pharmacy/pharmacy_details_screen.dart';
import 'package:easypharma_flutter/presentation/screens/medication/medication_details_screen.dart';
import 'package:easypharma_flutter/presentation/screens/payments/payments_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  final apiService = ApiService();
  await apiService.ensureDioReady();
  final authRepository = AuthRepository(apiService.dio, apiService);
  final pharmaciesRepository = PharmaciesRepository(apiService.dio);

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: sharedPreferences),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<PharmaciesRepository>.value(value: pharmaciesRepository),
        ChangeNotifierProvider<LocationProvider>(
          create: (context) => LocationProvider(),
        ),
        ChangeNotifierProvider<DeliveryProvider>(
          create:
              (context) => DeliveryProvider(
                DeliveryRepository(context.read<ApiService>().dio),
              ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create:
              (context) => AuthProvider(
                apiService: apiService,
                authRepository: authRepository,
                prefs: sharedPreferences,
              ),
          lazy: false,
        ),
        ChangeNotifierProvider<NavigationProvider>(
          create: (context) => NavigationProvider(),
        ),
        ChangeNotifierProvider<MedicationProvider>(
          create:
              (context) => MedicationProvider(
                MedicationRepository(context.read<ApiService>().dio),
              ),
        ),
        ChangeNotifierProvider<NotificationProvider>(
          create:
              (context) => NotificationProvider(
                NotificationRepository(context.read<ApiService>().dio),
                context.read<SharedPreferences>(),
              ),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (context) => CartProvider(),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          create:
              (context) => OrdersProvider(
                OrdersRepository(context.read<ApiService>().dio),
                pharmaciesRepository: context.read<PharmaciesRepository>(),
              ),
        ),
        ChangeNotifierProvider<PrescriptionProvider>(
          create:
              (context) => PrescriptionProvider(
                PrescriptionRepository(context.read<ApiService>().dio),
              ),
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create:
              (context) => ReviewProvider(
                ReviewRepository(context.read<ApiService>().dio),
              ),
        ),
        ChangeNotifierProvider<PharmaciesProvider>(
          create:
              (context) =>
                  PharmaciesProvider(context.read<PharmaciesRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );

  // Initialiser la gestion des deep links via MainActivity channels
  try {
    // Get initial link and navigate if present
    DeeplinkService.getInitialLink().then((link) {
      if (link != null) {
        _handleIncomingLink(link);
      }
    });

    // Listen to link stream while app is running
    DeeplinkService.linkStream.listen((link) {
      if (link != null) {
        _handleIncomingLink(link);
      }
    });
  } catch (_) {}
}

// Navigator key kept for programmatic navigation if needed
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// ScaffoldMessenger key to show SnackBars from top-level handlers
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyPharma',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: _buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => _buildAuthScreen(context, const LoginScreen()),
        '/register':
            (context) => _buildAuthScreen(context, const RegisterScreen()),
        '/profile':
            (context) => _buildProtectedScreen(context, const ProfileScreen()),
        '/edit-profile':
            (context) =>
                _buildProtectedScreen(context, const EditProfileScreen()),
        '/patient-home':
            (context) =>
                _buildProtectedScreen(context, const PatientHomeScreen()),
        '/delivery-home':
            (context) =>
                _buildProtectedScreen(context, const DeliveryHomeScreen()),
        '/orders':
            (context) => _buildProtectedScreen(context, const OrdersScreen()),
        '/orders/details':
            (context) =>
                _buildProtectedScreen(context, const OrderDetailsScreen()),
        '/cart':
            (context) => _buildProtectedScreen(context, const CartScreen()),
        '/checkout':
            (context) => _buildProtectedScreen(context, const CheckoutScreen()),
        '/pharmacy':
            (context) =>
                _buildProtectedScreen(context, const PharmacyDetailsScreen()),
        '/medication':
            (context) =>
                _buildProtectedScreen(context, const MedicationDetailsScreen()),
        '/payments':
            (context) => _buildProtectedScreen(context, const PaymentsScreen()),
        '/notifications':
            (context) => _buildProtectedScreen(
              context,
              const NotificationCenterScreen(),
            ),
        '/forgot-password':
            (context) =>
                _buildAuthScreen(context, const ForgotPasswordScreen()),
        '/reset-password': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final token = args is String ? args : null;
          return _buildAuthScreen(
            context,
            ResetPasswordScreen(resetToken: token),
          );
        },
      },
    );
  }

  // Protection: empêcher de naviguer aux écrans d'auth si déjà connecté
  Widget _buildAuthScreen(BuildContext context, Widget screen) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          // Si déjà connecté, rediriger vers l'accueil
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Rediriger vers l'écran d'accueil basé sur le rôle (par défaut fourni par AuthProvider)
            final route = authProvider.homeRoute ?? '/patient-home';
            Navigator.pushReplacementNamed(context, route);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return screen;
      },
    );
  }

  // Protection: rediriger vers login si non connecté (pour les écrans protégés)
  Widget _buildProtectedScreen(BuildContext context, Widget screen) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated && authProvider.isInitialized) {
          // Si non connecté et initialisé, rediriger vers login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return screen;
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue.shade700,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        accentColor: Colors.blueAccent,
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade50,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue.shade700),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.blue.shade700,
          letterSpacing: 0.3,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.blue.shade700,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue.shade700,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      fontFamily: 'Roboto',
    );
  }
}

void _handleIncomingLink(String link) {
  try {
    final uri = Uri.parse(link);
    String? token = uri.queryParameters['token'];
    if (token == null && uri.pathSegments.isNotEmpty) {
      token = uri.pathSegments.last;
    }

    // Debug helper: show the test token on screen for quick verification
    if (token != null && token == 'SUCCES_TEST_FINAL') {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Deep link token reçu: $token')),
      );
    }

    if (token != null && navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed('/reset-password', arguments: token);
    }
  } catch (_) {}
}
