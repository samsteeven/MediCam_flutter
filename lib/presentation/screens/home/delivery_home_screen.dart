import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/presentation/providers/delivery_provider.dart';
import 'package:easypharma_flutter/presentation/screens/delivery/widgets/delivery_card.dart';
import 'package:easypharma_flutter/presentation/screens/delivery/delivery_confirmation_screen.dart';
import 'package:easypharma_flutter/data/models/delivery_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryHomeScreen extends StatefulWidget {
  const DeliveryHomeScreen({super.key});
  static const routeName = '/delivery-home';

  @override
  State<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends State<DeliveryHomeScreen> {
  bool _isAvailable = true; // Par défaut disponible

  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().loadDashboardData();
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
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue.shade700),
                  onPressed:
                      () =>
                          context.read<DeliveryProvider>().loadDashboardData(),
                  tooltip: 'Actualiser',
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
                  label: 'Historique',
                ),
              ],
              currentIndex:
                  navProvider.currentIndex > 2
                      ? 0
                      : navProvider
                          .currentIndex, // Adjust if index out of bounds
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
        return _buildDeliveriesView(context); // Ongoing
      case 2:
        return _buildHistoryView(context); // History
      default:
        return _buildHomeView(context);
    }
  }

  Widget _buildHomeView(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.stats.totalDeliveries == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadDashboardData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // === HEADER DE BIENVENUE ===
                Container(
                  margin: const EdgeInsets.all(16),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  children: [
                                    const Text(
                                      'Bonjour ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Consumer<AuthProvider>(
                                      builder:
                                          (context, authProvider, _) => Text(
                                            authProvider.user?.firstName ??
                                                'Livreur',
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
                                  _isAvailable ? 'Prêt à livrer ?' : 'En pause',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Switch(
                                value: _isAvailable,
                                onChanged: (value) {
                                  setState(() {
                                    _isAvailable = value;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        value
                                            ? 'Vous êtes maintenant en ligne'
                                            : 'Vous êtes maintenant hors ligne',
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                activeColor: Colors.white,
                                activeTrackColor: Colors.green.shade400,
                              ),
                              Text(
                                _isAvailable ? 'En ligne' : 'Hors ligne',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // === STATISTIQUES ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_shipping_outlined,
                          title: 'En cours',
                          value: provider.ongoingDeliveries.length.toString(),
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle_outlined,
                          title: 'Livrées',
                          value: provider.stats.successfulDeliveries.toString(),
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.error_outline,
                          title: 'Échecs',
                          value: provider.stats.failedDeliveries.toString(),
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // === INFO ===
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildInfoCard(),
                ),

                // === LIVRAISONS EN COURS ===
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Livraisons en cours',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      if (provider.ongoingDeliveries.isNotEmpty)
                        TextButton(
                          onPressed:
                              () => context.read<NavigationProvider>().setIndex(
                                1,
                              ),
                          child: const Text('Voir tout'),
                        ),
                    ],
                  ),
                ),

                if (provider.ongoingDeliveries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Aucune livraison en cours",
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.ongoingDeliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = provider.ongoingDeliveries[index];
                      return DeliveryCard(
                        delivery: delivery,
                        onAccept: () => provider.acceptDelivery(delivery.id),
                        onConfirm: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DeliveryConfirmationScreen(
                                    delivery: delivery,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeliveriesView(BuildContext context) {
    // Pour cet onglet, on pourrait afficher TOUTES les livraisons (assignées, en cours)
    // Mais ici on utilise ongoingDeliveries du dashboard simplifie ou on fetchAll
    // On va utiliser ongoingDeliveries pour l'instant pour la démo "Gestion"
    return Consumer<DeliveryProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.fetchOngoingDeliveries(),
          child:
              provider.ongoingDeliveries.isEmpty
                  ? Center(child: Text("Aucune livraison en cours"))
                  : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: provider.ongoingDeliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = provider.ongoingDeliveries[index];
                      return DeliveryCard(
                        delivery: delivery,
                        onAccept: () => provider.acceptDelivery(delivery.id),
                        onConfirm: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DeliveryConfirmationScreen(
                                    delivery: delivery,
                                  ),
                            ),
                          );
                        },
                      );
                    },
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
        if (provider.allDeliveries.isEmpty && !provider.isLoading) {
          // Try fetch
          provider.fetchAllDeliveries();
          return const Center(child: CircularProgressIndicator());
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
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isAvailable ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isAvailable ? Colors.blue.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: _isAvailable ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 12),
          Text(
            'Statut : ${_isAvailable ? 'Disponible' : 'Indisponible'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isAvailable ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color.shade700, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
