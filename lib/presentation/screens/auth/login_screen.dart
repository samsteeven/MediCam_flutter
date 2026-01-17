import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/presentation/providers/notification_provider.dart';
import 'package:easypharma_flutter/core/utils/permissions_requester.dart';
import 'package:easypharma_flutter/presentation/widgets/custom_text_field.dart';
import 'package:easypharma_flutter/core/utils/validators.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';
import 'package:easypharma_flutter/data/models/notification_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Initialize notifications after successful login and ensure welcome
      if (mounted) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final notifProvider = context.read<NotificationProvider>();
        await notifProvider.initialize(userId: auth.user?.id);

        final hasWelcome = notifProvider.notifications.any(
          (n) => n.type == 'WELCOME',
        );
        if (!hasWelcome) {
          notifProvider.addLocalNotification(
            NotificationDTO(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Bienvenue sur EasyPharma !',
              message:
                  'Ravi de vous revoir, ${auth.user?.firstName}. Nous sommes là pour faciliter vos achats de médicaments.',
              createdAt: DateTime.now(),
              isRead: false,
              type: 'WELCOME',
            ),
          );
        }
        // Request in-app permissions (notifications, location, camera, storage)
        try {
          await requestAllPermissions();
        } catch (_) {}
      }

      // Naviguer vers l'accueil en fonction du rôle
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final homeRoute = authProvider.homeRoute;
      // Réinitialiser les onglets de navigation en arrivant
      context.read<NavigationProvider>().reset();
      if (homeRoute != null) {
        Navigator.pushReplacementNamed(context, homeRoute);
      } else {
        // Repli vers l'accueil patient si aucune route définie
        Navigator.pushReplacementNamed(context, '/patient-home');
      }
    } catch (e) {
      if (!mounted) return;
      // Show error snackbar
      NotificationHelper.showError(context, 'Erreur: $e');
    }
  }

  void _goToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void _goToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Empêcher le retour au login si déjà connecté
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(
          context,
          authProvider.homeRoute ?? '/profile',
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    "assets/images/app_icon.png",
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenue sur EasyPharma',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Secondary Black
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Connectez-vous pour accéder à votre compte',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blue.shade700,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: Validators.validatePassword,
                    isRequired: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 16),

                  // forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _goToForgotPassword,
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _login,
                    child:
                        authProvider.isLoading
                            ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blue.shade700,
                              ),
                            )
                            : const Text(
                              'Se connecter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                  const SizedBox(height: 24),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vous n\'avez pas de compte ? ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: _goToRegister,
                        child: Text(
                          'S\'inscrire',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
