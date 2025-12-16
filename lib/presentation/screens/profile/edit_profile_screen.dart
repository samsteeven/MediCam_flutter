import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/widgets/custom_text_field.dart';
import 'package:easypharma_flutter/core/utils/validators.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserData();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Attendre que le provider soit initialisé
    if (!authProvider.isInitialized) {
      await authProvider.initialize();
    }

    // Récupérer l'utilisateur actuel
    final user = authProvider.user;

    if (user != null) {
      setState(() {
        // Pré-remplir les champs avec les infos actuelles
        _firstNameController.text = user.firstName;
        _lastNameController.text = user.lastName;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _cityController.text = user.city;
        _isLoading = false;
      });
    } else {
      // Si pas d'utilisateur, essayer de le rafraîchir
      final refreshedUser = await authProvider.getCurrentUser();

      if (refreshedUser != null) {
        setState(() {
          _firstNameController.text = refreshedUser.firstName;
          _lastNameController.text = refreshedUser.lastName;
          _emailController.text = refreshedUser.email;
          _phoneController.text = refreshedUser.phone;
          _addressController.text = refreshedUser.address;
          _cityController.text = refreshedUser.city;
          _isLoading = false;
        });
      } else {
        // Pas d'utilisateur trouvé
        setState(() {
          _isLoading = false;
        });

        // Rediriger vers le profil si pas d'utilisateur
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Utiliser la méthode updateProfile du provider
      await authProvider.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address:
            _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
        city:
            _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
      );

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Retourner au profil
      Navigator.pop(context);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProfile,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // En-tête
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.person, size: 64, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        'Modifiez vos informations',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Seuls les champs obligatoires sont requis',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Informations personnelles
              const Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Prénom et nom',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 12),

              // Prénom et Nom sur la même ligne
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      label: 'Prénom *',
                      validator: Validators.validateName,
                      isRequired: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      label: 'Nom *',
                      validator: Validators.validateName,
                      isRequired: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Email (lecture seule)
              const Text(
                'Email',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                enabled: false, // Email non modifiable
                fillColor: Colors.grey[100],
              ),
              const SizedBox(height: 4),
              const Text(
                'L\'email ne peut pas être modifié',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),

              const SizedBox(height: 16),

              // Téléphone
              const Text(
                'Téléphone',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              CustomTextField(
                controller: _phoneController,
                label: 'Téléphone *',
                keyboardType: TextInputType.phone,
                validator: Validators.validatePhone,
                isRequired: true,
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Adresse
              const Text(
                'Adresse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ces informations sont facultatives',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),

              const SizedBox(height: 16),

              // Adresse
              CustomTextField(
                controller: _addressController,
                label: 'Adresse',
                hintText: 'Ex: 123 Rue de la Pharmacie',
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Ville
              CustomTextField(
                controller: _cityController,
                label: 'Ville',
                hintText: 'Ex: Paris',
              ),

              const SizedBox(height: 32),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(color: Colors.blue.shade400),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Information sur les champs obligatoires
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '* Champs obligatoires',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
