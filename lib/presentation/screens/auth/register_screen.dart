import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/location_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/presentation/providers/notification_provider.dart';
import 'package:easypharma_flutter/core/utils/permissions_requester.dart';
import 'package:easypharma_flutter/data/models/user_model.dart';
import 'package:easypharma_flutter/presentation/widgets/custom_text_field.dart';
import 'package:easypharma_flutter/core/utils/validators.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';
import 'package:easypharma_flutter/data/models/notification_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController =
      TextEditingController(); // Keep phone controller as it's for all users

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Plus besoin de charger les pharmacies pour l'inscription patient
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: UserRole.PATIENT, // Forcé en tant que PATIENT
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        city:
            _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
      );

      // Naviguer vers l'accueil en fonction du rôle
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final homeRoute = authProvider.homeRoute;
      // Réinitialiser les onglets de navigation en arrivant
      context.read<NavigationProvider>().reset();
      // Ajouter une notification de bienvenue localement
      try {
        final notifProvider = Provider.of<NotificationProvider>(
          context,
          listen: false,
        );
        await notifProvider.initialize(userId: authProvider.user?.id);

        final welcome = NotificationDTO(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Bienvenue sur EasyPharma !',
          message:
              'Félicitations ${authProvider.user?.firstName}, votre compte a été créé avec succès.',
          createdAt: DateTime.now(),
          isRead: false,
          type: 'WELCOME',
        );
        notifProvider.addLocalNotification(welcome);
      } catch (e) {
        debugPrint('Error adding welcome notification: $e');
      }
      // Demander les permissions (notifications, localisation, camera, stockage)
      try {
        await requestAllPermissions();
      } catch (_) {}
      if (homeRoute != null) {
        Navigator.pushReplacementNamed(context, homeRoute);
      } else {
        // Repli vers l'accueil patient si aucune route définie
        Navigator.pushReplacementNamed(context, '/patient-home');
      }
    } catch (e) {
      // Show error snackbar
      NotificationHelper.showError(context, 'Erreur: $e');
    }
  }

  Future<void> _fillLocation() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    final data = await locationProvider.getAddressFromLocation();

    if (data != null) {
      setState(() {
        _addressController.text = data['address'] ?? '';
        _cityController.text = data['city'] ?? '';
      });
    } else if (locationProvider.error != null) {
      NotificationHelper.showError(context, locationProvider.error!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                  const SizedBox(height: 30),
                  Image.asset(
                    "assets/images/app_icon.png",
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Créer un compte',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rejoignez EasyPharma',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Name fields
                  CustomTextField(
                    controller: _lastNameController,
                    label: 'Nom',
                    validator:
                        (value) =>
                            Validators.validateName(value, fieldName: 'nom'),
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _firstNameController,
                    label: 'Prénom',
                    validator:
                        (value) =>
                            Validators.validateName(value, fieldName: 'prénom'),
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Téléphone',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.validatePhone,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Address
                  CustomTextField(
                    controller: _addressController,
                    label: 'Adresse',
                    validator: Validators.validateAddress,
                  ),
                  const SizedBox(height: 16),

                  // City
                  CustomTextField(
                    controller: _cityController,
                    label: 'Ville',
                    validator: Validators.validateCity,
                  ),
                  const SizedBox(height: 8),

                  // Bouton Localisation
                  OutlinedButton.icon(
                    onPressed: _fillLocation,
                    icon: const Icon(Icons.location_on, size: 18),
                    label: const Text('Utiliser ma position actuelle'),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    obscureText: !_isPasswordVisible,
                    validator: Validators.validatePassword,
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
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    obscureText: !_isConfirmPasswordVisible,
                    validator:
                        (value) => Validators.validateConfirmPassword(
                          value,
                          _passwordController.text,
                        ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blue.shade700,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    isRequired: true,
                  ),
                  const SizedBox(height: 32),

                  // Register Button
                  ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _register,
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
                              'S\'inscrire',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                  const SizedBox(height: 24),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vous avez déjà un compte ? ',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Se connecter',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
