import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/presentation/providers/notification_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Initialiser le auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();

    // Attendre un moment pour une transition fluide
    await Future.delayed(const Duration(milliseconds: 2500));

    // Naviguer en fonction du statut d'authentification
    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      // Initialize notifications for authenticated users (await fetch)
      await context.read<NotificationProvider>().initialize();

      // Rediriger vers l'écran d'accueil basé sur le rôle
      final homeRoute = authProvider.homeRoute ?? '/patient-home';
      // Réinitialiser les onglets avant d'entrer dans l'accueil
      if (mounted) context.read<NavigationProvider>().reset();
      Navigator.pushReplacementNamed(context, homeRoute);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Container(
        decoration: BoxDecoration(color: Colors.grey.shade50),
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
                      color: Colors.blue.shade700.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    "assets/images/app_icon.png",
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // App Name
              Text(
                'EasyPharma',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700, // Tertiary Blue for Brand
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),

              // Tagline
              Text(
                'Votre pharmacie en ligne',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600, // Secondary/Grey
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 80),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.blue.shade700,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),

              // Loading text
              Text(
                'Chargement...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),

              // Version info
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
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
