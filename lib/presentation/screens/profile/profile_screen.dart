import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/data/models/user_model.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variables pour suivre l'état
  bool _isLoading = true;
  User? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // METHODE 1: Récupérer depuis AuthProvider (RECOMMANDÉ)
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Si l'utilisateur est déjà dans le provider, l'utiliser
      if (authProvider.user != null) {
        setState(() {
          _user = authProvider.user;
          _isLoading = false;
          _error = null;
        });
        return;
      }

      // METHODE 2: Si pas dans le provider, essayer de rafraîchir
      final refreshedUser = await authProvider.getCurrentUser();

      if (refreshedUser != null) {
        setState(() {
          _user = refreshedUser;
          _isLoading = false;
          _error = null;
        });
      } else {
        // Pas d'utilisateur trouvé
        setState(() {
          _error = ' Aucun utilisateur connecté ';
          _isLoading = false;
        });
      }
    } catch (e) {
      print(' Error loading user data : $e ');
      setState(() {
        _error = ' Erreur de chargement : ${e.toString()} ';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final bool? shouldRefresh =
                  await Navigator.pushNamed(context, '/edit-profile') as bool?;

              if (shouldRefresh == true) {
                _loadUserData();
              }
            },
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Erreur de chargement', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Données utilisateur introuvable',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return _buildProfileContent(_user!);
  }

  Widget _buildProfileContent(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo de profil
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: const Icon(Icons.person, size: 60, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),

          // Informations personnelles
          _buildInfoCard(
            title: 'Informations personnelles',
            children: [
              _buildInfoItem(
                icon: Icons.person,
                label: 'Nom complet',
                value: user.fullName,
              ),
              _buildInfoItem(
                icon: Icons.email,
                label: 'Email',
                value: user.email,
              ),
              _buildInfoItem(
                icon: Icons.phone,
                label: 'Téléphone',
                value: user.phone.isNotEmpty ? user.phone : 'Non renseigné',
              ),
              _buildInfoItem(
                icon: Icons.person_pin_circle,
                label: 'Rôle',
                value: user.role.toString().split('.').last,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Adresse
          _buildInfoCard(
            title: 'Adresse',
            children: [
              _buildInfoItem(
                icon: Icons.location_on,
                label: 'Adresse',
                value:
                    user.address.isNotEmpty ? user.address : 'Non renseignée',
              ),
              _buildInfoItem(
                icon: Icons.location_city,
                label: 'Ville',
                value: user.city.isNotEmpty ? user.city : 'Non renseignée',
              ),
              if (user.latitude != null && user.longitude != null)
                _buildInfoItem(
                  icon: Icons.map,
                  label: 'Coordonnées',
                  value:
                      '${user.latitude!.toStringAsFixed(4)}, ${user.longitude!.toStringAsFixed(4)}',
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Statut
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statut',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.verified, color: Colors.green),
                    title: const Text('Vérification'),
                    trailing:
                        user.isVerified
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                            : const Icon(Icons.cancel, color: Colors.red),
                    subtitle: Text(
                      user.isVerified ? 'Compte vérifié' : 'Compte non vérifié',
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.power_settings_new,
                      color: Colors.blue,
                    ),
                    title: const Text('Activité'),
                    trailing:
                        user.isActive
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                            : const Icon(Icons.cancel, color: Colors.red),
                    subtitle: Text(
                      user.isActive ? 'Compte actif' : 'Compte désactivé',
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                    ),
                    title: const Text('Membre depuis'),
                    subtitle: Text(
                      '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bouton de déconnexion
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await authProvider.logout();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: const Text('Se déconnecter'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
