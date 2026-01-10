import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/data/models/user_model.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
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
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadUserData,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black, // Secondary Black
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
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statut du compte',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black, // Secondary Black
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
          ),
          const SizedBox(height: 32),

          // Bouton de déconnexion
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade700,
                side: BorderSide(color: Colors.orange.shade200, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              onPressed: () => _showLogoutConfirmation(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Bouton de suppression de compte
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade200, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              onPressed: () => _showDeleteAccountConfirmation(context),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text(
                'Supprimer mon compte',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Confirmation dialog for logout
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                const Text('Déconnexion'),
              ],
            ),
            content: const Text(
              'Êtes-vous sûr de vouloir vous déconnecter ?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Se déconnecter',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  // Confirmation dialog for account deletion
  Future<void> _showDeleteAccountConfirmation(BuildContext context) async {
    final firstConfirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                const SizedBox(width: 12),
                const Text('Attention !'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vous êtes sur le point de supprimer votre compte.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cette action est irréversible et entraînera :',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                _buildWarningItem('Suppression de toutes vos données'),
                _buildWarningItem('Perte de votre historique'),
                _buildWarningItem('Annulation de vos commandes en cours'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cette action ne peut pas être annulée',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Continuer',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    );

    if (firstConfirm == true) {
      // Second confirmation
      final finalConfirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.delete_forever, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  const Text('Confirmation finale'),
                ],
              ),
              content: const Text(
                'Confirmez-vous définitivement la suppression de votre compte ?',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Supprimer définitivement',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            'Annuler',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      );

      if (finalConfirm == true) {
        await _deleteAccount(context);
      }
    }
  }

  // Helper widget for warning items
  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.close, color: Colors.red.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Delete account action
  Future<void> _deleteAccount(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Show loading indicator
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Suppression en cours...'),
                      ],
                    ),
                  ),
                ),
              ),
        );
      }

      await authProvider.deleteProfile();

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        NotificationHelper.showSuccess(context, 'Compte supprimé avec succès');
      }

      // Navigate to login
      if (context.mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        NotificationHelper.showError(context, 'Erreur: ${e.toString()}');
      }
    }
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black, // Secondary Black
              ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 20),
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
                  color: Colors.blue.shade700,
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
