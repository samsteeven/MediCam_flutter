import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/presentation/providers/delivery_provider.dart';
import 'package:easypharma_flutter/presentation/providers/notification_provider.dart';
import 'package:easypharma_flutter/presentation/screens/delivery/widgets/delivery_card.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});
  static const routeName = '/delivery-home';

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DeliveryProvider>();
      provider.fetchStats();
      provider.fetchOngoingDeliveries();
      provider.fetchAllDeliveries();
    });
  }

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
            backgroundColor: Colors.grey.shade50,
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
              elevation: 8,
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
                colors: [Colors.blue.shade400, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade700.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                      builder:
                          (context, authProvider, _) => Text(
                            authProvider.user?.firstName ?? 'Livreur',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gérez vos livraisons en toute simplicité',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // === STATISTIQUES ===
          Consumer<DeliveryProvider>(
            builder: (context, provider, _) {
              final stats = provider.stats;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.local_shipping_outlined,
                            title: 'En cours',
                            value: '${stats?.ongoingDeliveries ?? 0}',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle_outline,
                            title: 'Terminées',
                            value: '${stats?.completedDeliveries ?? 0}',
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Gains',
                            value:
                                '${stats?.totalEarnings.toStringAsFixed(0) ?? 0} F',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.star_outline,
                            title: 'Note',
                            value: '4.8',
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // === RACCOURCIS ===
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actions rapides',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Secondary Black
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildShortcutCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Livraisons',
                      color: Colors.blue,
                      onTap:
                          () => context.read<NavigationProvider>().setIndex(1),
                    ),
                    _buildShortcutCard(
                      icon: Icons.assignment_outlined,
                      title: 'Commandes',
                      color: Colors.green,
                      onTap:
                          () => context.read<NavigationProvider>().setIndex(2),
                    ),
                    _buildShortcutCard(
                      icon: Icons.history_outlined,
                      title: 'Historique',
                      color: Colors.orange,
                      onTap:
                          () => context.read<NavigationProvider>().setIndex(3),
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
                const Text(
                  'Informations importantes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Secondary Black
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, child) {
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
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Actualiser',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchAllDeliveries(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.allDeliveries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final delivery = provider.allDeliveries[index];
              return DeliveryCard(delivery: delivery);
            },
          ),
        );
      },
    );
  }

  Widget _buildDeliveriesView() {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.ongoingDeliveries.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.ongoingDeliveries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune livraison en cours',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchOngoingDeliveries(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'Actualiser',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchOngoingDeliveries(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.ongoingDeliveries.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return DeliveryCard(delivery: provider.ongoingDeliveries[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrdersView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune commande disponible',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Statut : En ligne',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '• Assurez-vous d\'être connecté pour recevoir les nouvelles commandes\n'
            '• Mettez à jour votre statut de disponibilité\n'
            '• Vérifiez régulièrement les notifications',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF424242), // Grey 800
              fontWeight: FontWeight.w400,
              height: 1.5,
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color.shade700, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 8),
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color.shade700, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
