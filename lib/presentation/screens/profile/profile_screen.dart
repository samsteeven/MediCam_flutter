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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Mon Profil',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue.shade700),
            onPressed: _loadUserData,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.blue.shade700),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar avec initiales
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade700,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade300.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.firstName.isNotEmpty
                      ? user.firstName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Nom complet
          Center(
            child: Column(
              children: [
                Text(
                  user.fullName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Informations personnelles
          _buildInfoCard(
            title: 'Informations personnelles',
            children: [
              _buildInfoItem(
                icon: Icons.email_outlined,
                label: 'Email',
                value: user.email,
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                icon: Icons.phone_outlined,
                label: 'Téléphone',
                value: user.phone.isNotEmpty ? user.phone : 'Non renseigné',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Adresse
          _buildInfoCard(
            title: 'Adresse',
            children: [
              _buildInfoItem(
                icon: Icons.location_on_outlined,
                label: 'Adresse',
                value:
                    user.address.isNotEmpty ? user.address : 'Non renseignée',
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                icon: Icons.location_city_outlined,
                label: 'Ville',
                value: user.city.isNotEmpty ? user.city : 'Non renseignée',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Statuts
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statut du compte',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatusRow(
                  icon: Icons.verified_user_outlined,
                  label: 'Vérification',
                  isActive: user.isVerified,
                  status: user.isVerified ? 'Vérifié' : 'Non vérifié',
                ),
                const SizedBox(height: 12),
                _buildStatusRow(
                  icon: Icons.check_circle_outline,
                  label: 'Activité',
                  isActive: user.isActive,
                  status: user.isActive ? 'Actif' : 'Inactif',
                ),
                const SizedBox(height: 12),
                _buildStatusRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Membre depuis',
                  isActive: true,
                  status:
                      '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Bouton de déconnexion
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
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
              child: const Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required bool isActive,
    required String status,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isActive ? Colors.green.shade600 : Colors.grey.shade400,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isActive ? Colors.green.shade600 : Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green.shade600 : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
