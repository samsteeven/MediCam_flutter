import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/presentation/providers/delivery_provider.dart';
import 'package:easypharma_flutter/presentation/providers/notification_provider.dart';
import 'package:easypharma_flutter/presentation/screens/delivery/widgets/delivery_card.dart';
import 'package:easypharma_flutter/presentation/screens/delivery/delivery_confirmation_screen.dart';
import 'package:easypharma_flutter/data/models/delivery_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryHomeScreen extends StatelessWidget {
  const DeliveryHomeScreen({super.key});
  static const routeName = '/delivery-home';

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, _) {
        return WillPopScope(
          onWillPop: () async {
            if (navProvider.currentIndex != 0) {
              navProvider.setIndex(0);
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading:
                  navProvider.currentIndex != 0
                      ? IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.blue.shade700,
                          ),
                          onPressed: () => navProvider.setIndex(0),
                        )
                      : null,
              title: Text(
                'EasyPharma',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              automaticallyImplyLeading: false,
              actions: [
                Consumer<NotificationProvider>(
                  builder: (context, provider, _) {
                    return Stack(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.notifications_none,
                            color: Colors.blue.shade700,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/notifications');
                          },
                          tooltip: 'Notifications',
                        ),
                        if (provider.unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${provider.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person_outline, color: Colors.blue.shade700),
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  tooltip: 'Mon profil',
                ),
              ],
            ),
            body: _buildContent(context, navProvider.currentIndex),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.blue.shade700,
              unselectedItemColor: Colors.grey.shade400,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping_outlined),
                  activeIcon: Icon(Icons.local_shipping),
                  label: 'Livraisons',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment),
                  label: 'Commandes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'Historique',
                ),
              ],
              currentIndex: navProvider.currentIndex,
              onTap: (index) => navProvider.setIndex(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, int currentIndex) {
    switch (currentIndex) {
      case 0:
        return _buildHomeView(context);
      case 1:
        return _buildDeliveriesView();
      case 2:
        return _buildOrdersView();
      case 3:
        return _buildHistoryView();
      default:
        return _buildHomeView(context);
    }
  }

  Widget _buildHomeView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // === HEADER DE BIENVENUE ===
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade600.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  children: [
                    const Text(
                      'Bienvenue, ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) => Text(
                        authProvider.user?.firstName ?? 'Livreur',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Gérez vos livraisons en toute simplicité',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // === STATISTIQUES ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_shipping_outlined,
                    title: 'En cours',
                    value: '0',
                    color: Colors.blue,
                  ),
        );
      },
    );
  }

  Widget _buildHistoryView(BuildContext context) {
    // Nécessite d'appeler fetchAllDeliveries si pas fait
    // On le fait au premier build de cet onglet via un FutureBuilder ou state init local
    // Simplification: bouton chargement
    return Consumer<DeliveryProvider>(
      builder: (context, provider, child) {
        // Si la liste est vide et qu'on ne charge pas, déclencher le chargement APRÈS le build
        if (provider.allDeliveries.isEmpty && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.fetchAllDeliveries();
          });
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.isLoading && provider.allDeliveries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.allDeliveries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Aucune livraison',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchAllDeliveries(),
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Actualiser',
                    style: TextStyle(color: Colors.white),
                    
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchAllDeliveries(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.allDeliveries.length,
            itemBuilder: (context, index) {
              final delivery = provider.allDeliveries[index];
              // Carte simplifiée ou la même
              return DeliveryCard(delivery: delivery);
            },
          ),
          const SizedBox(height: 24),

          // === RACCOURCIS ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildShortcutCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Livraisons',
                      color: Colors.blue,
                      onTap: () => context.read<NavigationProvider>().setIndex(1),
                    ),
                    _buildShortcutCard(
                      icon: Icons.assignment_outlined,
                      title: 'Commandes',
                      color: Colors.green,
                      onTap: () => context.read<NavigationProvider>().setIndex(2),
                    ),
                    _buildShortcutCard(
                      icon: Icons.history_outlined,
                      title: 'Historique',
                      color: Colors.orange,
                      onTap: () => context.read<NavigationProvider>().setIndex(3),
                    ),
                    _buildShortcutCard(
                      icon: Icons.person_outlined,
                      title: 'Mon Profil',
                      color: Colors.purple,
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // === SECTION INFOS IMPORTANTES ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informations importantes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoCard(),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Statut : En ligne',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Assurez-vous d\'être connecté pour recevoir les nouvelles commandes\n'
            '• Mettez à jour votre statut de disponibilité\n'
            '• Vérifiez régulièrement les notifications',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required MaterialColor color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
        boxShadow: [
          BoxShadow(
            color: color.shade100.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color.shade700, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildShortcutCard({
    required IconData icon,
    required String title,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.shade200),
          boxShadow: [
            BoxShadow(
              color: color.shade100.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color.shade700, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveriesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 40,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Mes Livraisons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune livraison en cours',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 40,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Commandes à préparer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune commande en attente',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.history_outlined,
              size: 40,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Historique',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune livraison complétée',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}