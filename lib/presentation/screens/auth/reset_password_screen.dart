import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/widgets/custom_text_field.dart';
import 'package:easypharma_flutter/core/utils/validators.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? resetToken;

  const ResetPasswordScreen({super.key, this.resetToken});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _passwordReset = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplir le token s'il est fourni dans l'URL
    if (widget.resetToken != null) {
      _tokenController.text = widget.resetToken!;
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).resetPassword(
        token: _tokenController.text.trim(),
        newPassword: _newPasswordController.text,
      );

      // Succès
      setState(() {
        _passwordReset = true;
        _isLoading = false;
      });

      // Message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe réinitialisé avec succès !'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Rediriger vers le login après 2 secondes
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and welcome
                const SizedBox(height: 30),
                Icon(
                  _passwordReset ? Icons.check_circle : Icons.password,
                  size: 80,
                  color:
                      _passwordReset
                          ? Colors.green
                          : Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  _passwordReset
                      ? 'Mot de passe réinitialisé !'
                      : 'Créer un nouveau mot de passe',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  _passwordReset
                      ? 'Redirection vers la page de connexion...'
                      : 'Veuillez créer un nouveau mot de passe sécurisé',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Success message
                if (_passwordReset)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Votre mot de passe a été réinitialisé avec succès.',
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!_passwordReset) ...[
                  // Token field (hidden by default)
                  ExpansionTile(
                    title: const Text(
                      'Token de réinitialisation',
                      style: TextStyle(fontSize: 14),
                    ),
                    initiallyExpanded: false,
                    children: [
                      CustomTextField(
                        controller: _tokenController,
                        label: 'Token',
                        validator:
                            (value) => Validators.validateRequired(
                              value,
                              fieldName: 'token',
                            ),
                        isRequired: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // New password field
                  CustomTextField(
                    controller: _newPasswordController,
                    label: 'Nouveau mot de passe',
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
                  const SizedBox(height: 20),

                  // Confirm password field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    obscureText: !_isConfirmPasswordVisible,
                    validator:
                        (value) => Validators.validateConfirmPassword(
                          value,
                          _newPasswordController.text,
                        ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
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
                  const SizedBox(height: 20),

                  // Password rules
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Le mot de passe doit contenir :',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildPasswordRule('Au moins 8 caractères'),
                        _buildPasswordRule('Une majuscule et une minuscule'),
                        _buildPasswordRule('Un chiffre'),
                        _buildPasswordRule('Un caractère spécial'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Reset button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.lightBlue,
                              ),
                            )
                            : const Text(
                              'Réinitialiser le mot de passe',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Back to login
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Retourner à ',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('la connexion'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRule(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Wrap(
        children: [
          Icon(
            Icons.check_circle,
            size: 12,
            color: _validatePasswordRule(text) ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: _validatePasswordRule(text) ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  bool _validatePasswordRule(String rule) {
    final password = _newPasswordController.text;
    if (password.isEmpty) return false;

    switch (rule) {
      case 'Au moins 8 caractères':
        return password.length >= 8;
      case 'Une majuscule et une minuscule':
        return password.contains(RegExp(r'[A-Z]')) &&
            password.contains(RegExp(r'[a-z]'));
      case 'Un chiffre':
        return password.contains(RegExp(r'[0-9]'));
      case 'Un caractère spécial':
        return password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      default:
        return false;
    }
  }
}
