import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/location_provider.dart';
import 'package:easypharma_flutter/presentation/widgets/custom_text_field.dart';
import 'package:easypharma_flutter/core/utils/validators.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';

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

      NotificationHelper.showSuccess(context, 'Profil mis à jour avec succès');

      // Retourner au profil
      Navigator.pop(context);
    } catch (e) {
      NotificationHelper.showError(context, 'Erreur: ${e.toString()}');
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        title: Text(
          'Modifier le profil',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.blue.shade700,
            ), // Action button can correspond to tertiary
            onPressed: _updateProfile,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade300,
                                Colors.blue.shade700,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Mettez à jour vos informations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black, // Secondary Black
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Les champs avec * sont obligatoires',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
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
                    color: Colors.black, // Secondary Black
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prénom et nom',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                    color: Colors.black, // Secondary Black
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
                  hintText: 'Ex: Douala',
                ),
                const SizedBox(height: 12),

                // Bouton Localisation
                OutlinedButton.icon(
                  onPressed: _fillLocation,
                  icon: const Icon(Icons.location_on, size: 18),
                  label: const Text('Utiliser ma position actuelle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    side: BorderSide(color: Colors.blue.shade700),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
                          side: BorderSide(color: Colors.blue.shade100),
                        ),
                        child: Text(
                          'Annuler',
                          style: TextStyle(color: Colors.blue.shade700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
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
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '* Champs obligatoires',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
