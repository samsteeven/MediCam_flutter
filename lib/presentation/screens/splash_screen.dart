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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade700,
              Colors.blue.shade500,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_services,
                  size: 60,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 30),

              // App Name
              const Text(
                'EasyPharma',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),

              // Tagline
              const Text(
                'Votre pharmacie en ligne',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 40),

              // Loading indicator
              Container(
                width: 50,
                height: 50,
                padding: const EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // Loading text
              const Text(
                'Chargement...',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 40),

              // Version info
              const Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
