import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/presentation/widgets/medication_search_bar.dart';
import 'package:easypharma_flutter/presentation/providers/location_provider.dart';
import 'package:easypharma_flutter/presentation/providers/notification_provider.dart';
import 'package:easypharma_flutter/presentation/providers/medication_provider.dart';
import 'package:easypharma_flutter/presentation/providers/cart_provider.dart';
import 'package:easypharma_flutter/presentation/providers/orders_provider.dart';
import 'package:easypharma_flutter/presentation/providers/prescription_provider.dart';
import 'package:easypharma_flutter/presentation/providers/pharmacies_provider.dart';
import 'package:easypharma_flutter/data/models/order_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:easypharma_flutter/presentation/providers/review_provider.dart';
import 'package:easypharma_flutter/core/utils/notification_helper.dart';
import 'package:easypharma_flutter/presentation/screens/pharmacy/pharmacy_reviews_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});
  static const routeName = '/patient-home';

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  bool _hasLoadedInitialMedications = false;
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Tenter de récupérer la localisation si elle n'est pas déjà là
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.userLocation == null) {
        locationProvider.ensureLocation();
      }
      // Charger les données essentielles à l'ouverture
      final ordersProvider = context.read<OrdersProvider>();
      final pharmaciesProvider = context.read<PharmaciesProvider>();
      final notificationProvider = context.read<NotificationProvider>();
      final medProvider = context.read<MedicationProvider>();
      final prescriptionProvider = context.read<PrescriptionProvider>();

      // Historique / commandes
      ordersProvider.fetchMyOrders();

      // Pharmacies (pour affichage des noms, inventaires...)
      pharmaciesProvider.fetchAllPharmacies();

      // Notifications : initialise et démarre le polling (attendre le fetch initial)
      await notificationProvider.initialize();

      // Prescriptions de l'utilisateur
      prescriptionProvider.fetchMyPrescriptions();

      // Charger les top médicaments pour la page d'accueil (une seule fois)
      if (!_hasLoadedInitialMedications) {
        medProvider.fetchTopSoldMedications();
        _hasLoadedInitialMedications = true;
      }

      // Ecoute des alertes locales (UI badge etc.)
      _setupNotificationListener();
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    _notificationSubscription = context
        .read<NotificationProvider>()
        .alertStream
        .listen((_) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('EasyPharma'),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, provider, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_none,
                          color: Colors.blue.shade700,
                        ),
                        onPressed:
                            () =>
                                Navigator.pushNamed(context, '/notifications'),
                      ),
                      if (provider.unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
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
                icon: _buildCartIcon(
                  cartProvider,
                  navProvider.currentIndex == 2,
                ),
                onPressed: () => navProvider.setIndex(2),
              ),
              IconButton(
                icon: Icon(Icons.person_outline, color: Colors.blue.shade700),
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                tooltip: 'Mon profil',
              ),
            ],
          ),
          body: IndexedStack(
            index: navProvider.currentIndex,
            children: [
              _buildHomeView(context),
              _buildSearchView(),
              _buildCartView(),
              _buildHistoryView(),
            ],
          ),
          bottomNavigationBar: Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              return BottomNavigationBar(
                backgroundColor: Colors.white,
                selectedItemColor: Colors.blue.shade700,
                unselectedItemColor: Colors.grey.shade400,
                type: BottomNavigationBarType.fixed,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Accueil',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.search_outlined),
                    activeIcon: Icon(Icons.search),
                    label: 'Recherche',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_outlined),
                    activeIcon: Icon(Icons.shopping_cart),
                    label: 'Panier',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.history_outlined),
                    activeIcon: Icon(Icons.history),
                    label: 'Historique',
                  ),
                ],
                currentIndex: navProvider.currentIndex,
                onTap: (index) => navProvider.setIndex(index),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCartIcon(CartProvider cartProvider, bool isActive) {
    return Stack(
      children: [
        Icon(Icons.shopping_cart_outlined),
        if (cartProvider.totalItems > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '${cartProvider.totalItems}',
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
  }

  Widget _buildHomeView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [_buildDefaultHomeContent(context)]),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    MedicationProvider medProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Résultats (${medProvider.searchResults.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () => medProvider.clearResults(),
                child: const Text('Tout effacer'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: medProvider.searchResults.length,
            itemBuilder: (context, index) {
              final pm = medProvider.searchResults[index];
              final med = pm.medication;
              final isOutOfStock = pm.stockQuantity <= 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/pharmacy',
                      arguments: {
                        'pharmacyId': pm.pharmacy.id,
                        'name': pm.pharmacy.name,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.medication,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                med.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_pharmacy_outlined,
                                    size: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      pm.pharmacy.name,
                                      style: TextStyle(
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (pm.pharmacy.averageRating > 0)
                                    Row(
                                      children: [
                                        ...List.generate(5, (index) {
                                          double starRating = index + 1.0;
                                          IconData icon;
                                          if (pm.pharmacy.averageRating >=
                                              starRating) {
                                            icon = Icons.star;
                                          } else if (pm
                                                  .pharmacy
                                                  .averageRating >=
                                              starRating - 0.5) {
                                            icon = Icons.star_half;
                                          } else {
                                            icon = Icons.star_border;
                                          }
                                          return Icon(
                                            icon,
                                            color: Colors.amber,
                                            size: 14,
                                          );
                                        }),
                                        const SizedBox(width: 4),
                                        Text(
                                          pm.pharmacy.averageRating
                                              .toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                med.description ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '${pm.price} FCFA',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isOutOfStock
                                              ? Colors.red.shade50
                                              : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isOutOfStock
                                          ? 'Rupture'
                                          : 'Stock: ${pm.stockQuantity}',
                                      style: TextStyle(
                                        color:
                                            isOutOfStock
                                                ? Colors.red
                                                : Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.add_shopping_cart,
                            color:
                                isOutOfStock
                                    ? Colors.grey
                                    : Colors.blue.shade700,
                          ),
                          onPressed:
                              isOutOfStock
                                  ? null
                                  : () {
                                    context.read<CartProvider>().addItem(
                                      med,
                                      pm.pharmacy,
                                      pm.price,
                                    );
                                    NotificationHelper.showSuccess(
                                      context,
                                      '${med.name} ajouté au panier',
                                      onTap: () {
                                        context
                                            .read<NavigationProvider>()
                                            .setIndex(2);
                                      },
                                    );
                                  },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultHomeContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // === HEADER DE BIENVENUE ===
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.blue.shade700],
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
                children: [
                  const Text(
                    'Bienvenue, M. ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Consumer<AuthProvider>(
                    builder:
                        (context, authProvider, _) => Text(
                          authProvider.user?.lastName ?? 'Utilisateur',
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
                'Trouvez vos médicaments en quelques clics',
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
          child: Consumer<OrdersProvider>(
            builder: (context, ordersProvider, _) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Commandes',
                      value: ordersProvider.myOrders.length.toString(),
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.favorite_outline,
                      title: 'Favoris',
                      value: '0',
                      color: Colors.red,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // === RACCOURCIS ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accès rapide',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
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
                    icon: Icons.search_outlined,
                    title: 'Recherche',
                    color: Colors.blue,
                    onTap: () => context.read<NavigationProvider>().setIndex(1),
                  ),
                  _buildShortcutCard(
                    icon: Icons.shopping_cart_outlined,
                    title: 'Panier',
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
                    icon: Icons.person_outline,
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

        // === SECTION OFFRES SPÉCIALES ===
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offres spéciales',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildOfferCard(),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  static Widget _buildOfferCard() {
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
              Icon(Icons.local_offer_outlined, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '-15% sur votre première commande',
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
            'Utilisez le code WELCOME15 lors de votre commande',
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
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchView() {
    final locationProvider = context.watch<LocationProvider>();
    return Consumer<MedicationProvider>(
      builder: (context, medProvider, _) {
        if (!_hasLoadedInitialMedications &&
            medProvider.searchResults.isEmpty &&
            !medProvider.isLoading) {
          _hasLoadedInitialMedications = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            medProvider.searchMedications(
              '',
              userLat: locationProvider.userLocation?.latitude,
              userLon: locationProvider.userLocation?.longitude,
              sortBy: 'NEAREST',
            );
          });
        }

        return Column(
          children: [
            MedicationSearchBar(
              showButton: true,
              userLat: locationProvider.userLocation?.latitude,
              userLon: locationProvider.userLocation?.longitude,
            ),
            if (medProvider.isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (medProvider.searchResults.isNotEmpty)
              Expanded(child: _buildSearchResults(context, medProvider))
            else
              Expanded(
                child: Center(
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
                          Icons.search_off_outlined,
                          size: 40,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Aucun résultat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Essayez une autre recherche',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCartView() {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 50,
                    color: Colors.blue.shade300,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Votre panier est vide',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ajoutez des médicaments pour commencer\nvotre commande',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed:
                      () => context.read<NavigationProvider>().setIndex(1),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Rechercher des produits'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cart.items.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = cart.items.values.toList()[index];
                  final medicationId = cart.items.keys.toList()[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shadowColor: Colors.black.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.medication_outlined,
                              color: Colors.blue.shade700,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.medication.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  item.pharmacy.name,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                                if (item.pharmacy.averageRating > 0)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ...List.generate(5, (index) {
                                            double starRating = index + 1.0;
                                            IconData icon;
                                            if (item.pharmacy.averageRating >=
                                                starRating) {
                                              icon = Icons.star;
                                            } else if (item
                                                    .pharmacy
                                                    .averageRating >=
                                                starRating - 0.5) {
                                              icon = Icons.star_half;
                                            } else {
                                              icon = Icons.star_border;
                                            }
                                            return Icon(
                                              icon,
                                              color: Colors.amber,
                                              size: 16,
                                            );
                                          }),
                                          const SizedBox(width: 8),
                                          Text(
                                            item.pharmacy.averageRating
                                                .toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${item.pharmacy.ratingCount} avis',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.price} FCFA / unité',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                onPressed: () => cart.removeItem(medicationId),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed:
                                          () => cart.updateQuantity(
                                            medicationId,
                                            item.quantity - 1,
                                          ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed:
                                          () => cart.updateQuantity(
                                            medicationId,
                                            item.quantity + 1,
                                          ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sous-total',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          '${cart.totalAmount} FCFA',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Livraison',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const Text(
                          'Gratuit',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total à payer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${cart.totalAmount} FCFA',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _handleValidateOrder(context, cart),
                        child: const Text(
                          'Valider ma commande',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleValidateOrder(
    BuildContext context,
    CartProvider cart,
  ) async {
    // Vérifier si une ordonnance est requise
    if (cart.requiresPrescription) {
      final hasConfirmed = await _showPrescriptionUploadDialog(context);
      if (!hasConfirmed) return;
      if (!mounted) return;
    }

    final firstItem = cart.items.values.first;
    final auth = context.read<AuthProvider>();
    final location = context.read<LocationProvider>();
    final addressData = await location.getAddressFromLocation();
    if (!mounted) return;

    final request = CreateOrderRequest(
      pharmacyId: firstItem.pharmacy.id,
      items:
          cart.items.values
              .map(
                (item) => CreateOrderItem(
                  medicationId: item.medication.id,
                  quantity: item.quantity,
                ),
              )
              .toList(),
      deliveryAddress:
          addressData != null ? addressData['address'] : auth.user?.address,
      deliveryCity: addressData != null ? addressData['city'] : auth.user?.city,
      deliveryLatitude: location.userLocation?.latitude,
      deliveryLongitude: location.userLocation?.longitude,
      deliveryPhone: auth.user?.phone,
    );

    try {
      await context.read<OrdersProvider>().createOrder(
        request,
        onOrderCreated: () async {
          await context.read<NotificationProvider>().fetchNotifications();
        },
      );
      if (!mounted) return;
      cart.clear();
      NotificationHelper.showSuccess(
        context,
        'Commande validée avec succès !',
        onTap: () => context.read<NavigationProvider>().setIndex(3),
      );
      context.read<NavigationProvider>().setIndex(3);
    } catch (e) {
      if (!mounted) return;
      NotificationHelper.showError(context, 'Erreur: $e');
    }
  }

  Future<bool> _showPrescriptionUploadDialog(BuildContext context) async {
    final picker = ImagePicker();
    XFile? pickedFile;

    return await showDialog<bool>(
          context: context,
          builder:
              (context) => StatefulBuilder(
                builder: (context, setDialogState) {
                  return AlertDialog(
                    title: const Text('Ordonnance requise'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Certains médicaments de votre panier nécessitent une ordonnance. Veuillez en télécharger une pour continuer.',
                        ),
                        const SizedBox(height: 20),
                        if (pickedFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(pickedFile!.path),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(
                              Icons.add_a_photo_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final photo = await picker.pickImage(
                                  source: ImageSource.camera,
                                );
                                if (photo != null) {
                                  setDialogState(() => pickedFile = photo);
                                }
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Camera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final photo = await picker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (photo != null) {
                                  setDialogState(() => pickedFile = photo);
                                }
                              },
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galerie'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed:
                            pickedFile == null
                                ? null
                                : () async {
                                  try {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (context) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                    );

                                    final formData = FormData.fromMap({
                                      'file': await MultipartFile.fromFile(
                                        pickedFile!.path,
                                        filename: path.basename(
                                          pickedFile!.path,
                                        ),
                                        contentType: MediaType(
                                          'image',
                                          path
                                              .extension(pickedFile!.path)
                                              .replaceAll('.', ''),
                                        ),
                                      ),
                                    });

                                    await context
                                        .read<PrescriptionProvider>()
                                        .uploadPrescription(formData);

                                    Navigator.pop(context);
                                    Navigator.pop(context, true);
                                  } catch (e) {
                                    Navigator.pop(context);
                                    NotificationHelper.showError(
                                      context,
                                      'Erreur d\'upload: $e',
                                    );
                                  }
                                },
                        child: const Text('Confirmer & Continuer'),
                      ),
                    ],
                  );
                },
              ),
        ) ??
        false;
  }

  void _showReviewDialog(BuildContext context, Order order) {
    int selectedRating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Laisser un avis'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Comment s\'est passée votre commande ? Votre avis aide les autres utilisateurs.',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() => selectedRating = index + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Votre commentaire...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(const Size(90, 40)),
                    ),
                    onPressed: () async {
                      try {
                        await context.read<ReviewProvider>().submitReview(
                          pharmacyId: order.pharmacyId,
                          rating: selectedRating,
                          comment: commentController.text,
                          orderId: order.id,
                        );
                        Navigator.pop(context);
                        NotificationHelper.showSuccess(
                          context,
                          'Merci pour votre avis !',
                        );
                      } catch (e) {
                        NotificationHelper.showError(context, 'Erreur: $e');
                      }
                    },
                    child: const Text('Envoyer'),
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildHistoryView() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, _) {
        if (ordersProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ordersProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    ordersProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ordersProvider.fetchMyOrders(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          );
        }

        if (ordersProvider.myOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_outlined,
                  size: 60,
                  color: Colors.orange.shade200,
                ),
                const SizedBox(height: 20),
                Text(
                  'Aucune commande',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vous n\'avez pas encore passé de commande. Commandez un médicament pour voir votre historique ici.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<NavigationProvider>().setIndex(1);
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Rechercher des médicaments'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ordersProvider.fetchMyOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersProvider.myOrders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.myOrders[index];
              return _buildOrderCard(context, order);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final pname = Provider.of<OrdersProvider>(
            context,
            listen: false,
          ).pharmacyNameFor(order.pharmacyId);
          // Précharger les avis
          context.read<ReviewProvider>().fetchPharmacyReviews(order.pharmacyId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PharmacyReviewsScreen(
                    pharmacyId: order.pharmacyId,
                    pharmacyName: pname,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commande #${order.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    order.status.displayName,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pharmacie : ${Provider.of<OrdersProvider>(context, listen: false).pharmacyNameFor(order.pharmacyId)}',
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      final pname = Provider.of<OrdersProvider>(
                        context,
                        listen: false,
                      ).pharmacyNameFor(order.pharmacyId);
                      context.read<ReviewProvider>().fetchPharmacyReviews(
                        order.pharmacyId,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => PharmacyReviewsScreen(
                                pharmacyId: order.pharmacyId,
                                pharmacyName: pname,
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.star, size: 16),
                    label: const Text('Avis'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${order.items.length} article(s)',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${order.totalAmount.toStringAsFixed(2)} FCFA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              if (order.status == OrderStatus.DELIVERED) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showReviewDialog(context, order),
                    icon: const Icon(Icons.star_border),
                    label: const Text('Laisser un avis'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange.shade700;
      case OrderStatus.CONFIRMED:
        return Colors.blue.shade700;
      case OrderStatus.PREPARING:
        return Colors.purple.shade700;
      case OrderStatus.READY:
        return Colors.green.shade700;
      case OrderStatus.DELIVERED:
        return Colors.teal.shade700;
      case OrderStatus.PAID:
        return Colors.lightBlue.shade700;
      case OrderStatus.IN_DELIVERY:
        return Colors.teal.shade700;
      case OrderStatus.CANCELLED:
        return Colors.red.shade700;
    }
  }

  // _formatDate removed (unused)
}
