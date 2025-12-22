import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    // Wait a moment for smooth transition
    await Future.delayed(const Duration(milliseconds: 2500));

    // Navigate based on authentication status
    if (!mounted) return;

    print('=== SPLASH SCREEN DEBUG ===');
    print('User: ${authProvider.user?.email ?? "null"}');
    print('isAuthenticated: ${authProvider.isAuthenticated}');
    print('homeRoute: ${authProvider.homeRoute}');

    if (authProvider.isAuthenticated) {
      // Rediriger vers l'écran d'accueil basé sur le rôle
      final homeRoute = authProvider.homeRoute ?? '/patient-home';
      print('Navigation vers: $homeRoute');
      // Reset tabs before entering home
      if (mounted) context.read<NavigationProvider>().reset();
      Navigator.pushReplacementNamed(context, homeRoute);
    } else {
      print('Navigation vers: /login');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon with soft shadow
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_services,
                  size: 60,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(height: 40),

              // App Name
              Text(
                'EasyPharma',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Tagline
              Text(
                'Votre pharmacie en ligne',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blue.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),

              // Loading indicator
              SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color: Colors.blue.shade400,
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(height: 24),

              // Loading text
              Text(
                'Chargement...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),

              // Version info
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade300,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
