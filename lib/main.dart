import 'package:easypharma_flutter/presentation/providers/cart_provider.dart';
import 'package:easypharma_flutter/presentation/providers/location_provider.dart';
import 'package:easypharma_flutter/presentation/screens/auth/forgot_password_screen.dart';
import 'package:easypharma_flutter/presentation/screens/auth/reset_password_screen.dart';
import 'package:easypharma_flutter/presentation/screens/home/delivery_home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easypharma_flutter/core/services/api_service.dart';
import 'package:easypharma_flutter/data/repositories/auth_repository.dart';
import 'package:easypharma_flutter/data/repositories/medication_repository.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/presentation/providers/medication_provider.dart';
import 'package:easypharma_flutter/core/constants/app_constants.dart';
import 'package:easypharma_flutter/presentation/screens/home/medication_search_screen.dart';
import 'package:easypharma_flutter/presentation/providers/orders_provider.dart';
import 'package:easypharma_flutter/data/repositories/orders_repository.dart';
// Import des écrans...
import 'package:easypharma_flutter/presentation/screens/splash_screen.dart';
import 'package:easypharma_flutter/presentation/screens/auth/login_screen.dart';
import 'package:easypharma_flutter/presentation/screens/auth/register_screen.dart';
import 'package:easypharma_flutter/presentation/screens/profile/profile_screen.dart';
import 'package:easypharma_flutter/presentation/screens/profile/edit_profile_screen.dart';
import 'package:easypharma_flutter/presentation/screens/home/patient_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    _setupWebConfig();
  }

  final sharedPreferences = await SharedPreferences.getInstance();


  final apiService = ApiService();
  await apiService.ensureDioReady();
  final authRepository = AuthRepository(apiService.dio, apiService);

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: sharedPreferences),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthRepository>.value(value: authRepository),
        ChangeNotifierProvider<LocationProvider>(
        create: (context) => LocationProvider(), 
      ),
        ChangeNotifierProvider<CartProvider>(
          create: (context) => CartProvider(),
        ),
        ChangeNotifierProvider<OrdersProvider>(
          create:
              (context) => OrdersProvider(
            OrdersRepository(context.read<ApiService>().dio),
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
      ],
      child: const MyApp(),
    ),
  );
}

void _setupWebConfig() {
  print('Mode Web détecté - Configuration CORS active');
  debugDefaultTargetPlatformOverride = TargetPlatform.android;

  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) {
      if (message.contains('CORS') ||
          message.contains('Dio') ||
          message.contains('XMLHttpRequest')) {
        print('⚠️ [WEB] $message');
      } else {
        print(message);
      }
    }
  };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyPharma',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => _buildAuthScreen(context, const LoginScreen()),
        '/register':
            (context) => _buildAuthScreen(context, const RegisterScreen()),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/patient-home': (context) => const PatientHomeScreen(),
        '/delivery-home': (context) => const DeliveryHomeScreen(),
        '/medication-search': (context) => const MedicationSearchScreen(),
        '/forgot-password':
            (context) =>
                _buildAuthScreen(context, const ForgotPasswordScreen()),
        '/reset-password':
            (context) => _buildAuthScreen(context, const ResetPasswordScreen()),
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
            Navigator.pushReplacementNamed(
              context,
              authProvider.homeRoute ?? '/patient-home',
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
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blue.shade700,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      fontFamily: 'Roboto',
    );
  }
}
