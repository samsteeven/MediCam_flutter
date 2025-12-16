import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/data/models/user_model.dart';
import 'package:easypharma_flutter/presentation/widgets/custom_text_field.dart';
import 'package:easypharma_flutter/core/utils/validators.dart';

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
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  UserRole _selectedRole = UserRole.PATIENT;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

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
        role: _selectedRole,
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        city:
            _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
      );

      // Navigate to home based on role
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final homeRoute = authProvider.homeRoute;
      if (homeRoute != null) {
        Navigator.pushReplacementNamed(context, homeRoute);
      } else {
        // Fallback to patient home
        Navigator.pushReplacementNamed(context, '/patient-home');
      }
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Créer un compte',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Veuillez remplir les informations ci-dessous',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Role Selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Je suis', style: Theme.of(context).textTheme.bodyLarge),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<UserRole>(
                        value: _selectedRole,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: UserRole.PATIENT,
                            child: const Text('Patient'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.PHARMACIST,
                            child: const Text('Pharmacien'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.DELIVERY,
                            child: const Text('Livreur'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Name fields
              Column(
                children: [
                  CustomTextField(
                    controller: _lastNameController,
                    label: 'Nom',
                    validator:
                        (value) =>
                            Validators.validateName(value, fieldName: 'nom'),
                    isRequired: true,
                  ),

                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: _firstNameController,
                    label: 'Prénom',
                    validator:
                        (value) =>
                            Validators.validateName(value, fieldName: 'prénom'),
                    isRequired: true,
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Email
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                isRequired: true,
              ),
              const SizedBox(height: 15),

              // Phone
              CustomTextField(
                controller: _phoneController,
                label: 'Téléphone',
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: Validators.validatePhone,
                isRequired: true,
              ),
              const SizedBox(height: 15),

              // Address
              CustomTextField(
                controller: _addressController,
                label: 'Adresse',
                validator: Validators.validateAddress,
              ),
              const SizedBox(height: 15),

              // City
              CustomTextField(
                controller: _cityController,
                label: 'Ville',
                validator: Validators.validateCity,
              ),
              const SizedBox(height: 15),

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
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                isRequired: true,
              ),
              const SizedBox(height: 15),

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
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                isRequired: true,
              ),
              const SizedBox(height: 15),

              // Register Button
              ElevatedButton(
                onPressed: authProvider.isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    authProvider.isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.lightBlue,
                          ),
                        )
                        : const Text(
                          'S\'inscrire',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
              const SizedBox(height: 15),

              // Login link
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Vous avez déjà un compte ? ',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
