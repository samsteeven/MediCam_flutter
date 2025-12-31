import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
import 'package:easypharma_flutter/presentation/widgets/medication_search_bar.dart';
import 'package:easypharma_flutter/presentation/providers/location_provider.dart';
import 'package:easypharma_flutter/presentation/providers/cart_provider.dart';
import 'package:easypharma_flutter/presentation/providers/orders_provider.dart';
import 'package:easypharma_flutter/data/models/cart_item_model.dart';
import 'package:easypharma_flutter/data/models/order_model.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});
  static const routeName = '/patient-home';

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = context.read<LocationProvider>();
      if (locationProvider.userLocation == null) {
        locationProvider.ensureLocation();
      }

      // Charger l'historique des commandes
      context.read<OrdersProvider>().fetchMyOrders();
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
              leading: navProvider.currentIndex != 0
                  ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.blue.shade700),
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
                  icon: Icon(Icons.person_outline, color: Colors.blue.shade700),
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  tooltip: 'Mon profil',
                ),
              ],
            ),
            body: _buildContent(context, navProvider.currentIndex),
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
                    BottomNavigationBarItem(
                      icon: _buildCartIcon(cartProvider, false),
                      activeIcon: _buildCartIcon(cartProvider, true),
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
          ),
        );
      },
    );
  }

  Widget _buildCartIcon(CartProvider cartProvider, bool isActive) {
    return Stack(
      children: [
        Icon(isActive ? Icons.shopping_cart : Icons.shopping_cart_outlined),
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
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
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

  Widget _buildContent(BuildContext context, int currentIndex) {
    switch (currentIndex) {
      case 0:
        return _buildHomeView(context);
      case 1:
        return _buildSearchView();
      case 2:
        return _buildCartView();
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
          const MedicationSearchBar(showButton: true),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                        authProvider.user?.firstName ?? 'Utilisateur',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Consumer<OrdersProvider>(
                    builder: (context, ordersProvider, _) => _buildStatCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Commandes',
                      value: '${ordersProvider.myOrders.length}',
                      color: Colors.blue,
                    ),
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
            ),
          ),
          const SizedBox(height: 24),
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
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildOfferCard(),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
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

  static Widget _buildSearchView() {
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
              Icons.search_outlined,
              size: 40,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recherche de médicaments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trouvez rapidement les médicaments\nque vous recherchez',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCartView() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        if (cartProvider.isEmpty) {
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
                    Icons.shopping_cart_outlined,
                    size: 40,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Panier',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Votre panier est vide',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mon Panier',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Text(
                        '${cartProvider.totalItems} article(s) - ${cartProvider.pharmacyCount} pharmacie(s)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                    onPressed: () => _showClearCartDialog(context, cartProvider),
                    tooltip: 'Vider le panier',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartProvider.cartByPharmacy.length,
                itemBuilder: (context, index) {
                  final pharmacyId = cartProvider.cartByPharmacy.keys.elementAt(index);
                  final items = cartProvider.cartByPharmacy[pharmacyId]!;
                  final pharmacyName = items.first.pharmacyName;

                  return _buildPharmacySection(
                    context,
                    pharmacyId,
                    pharmacyName,
                    items,
                    cartProvider,
                  );
                },
              ),
            ),
            _buildCartBottomBar(context, cartProvider),
          ],
        );
      },
    );
  }

  Widget _buildPharmacySection(
      BuildContext context,
      String pharmacyId,
      String pharmacyName,
      List<CartItem> items,
      CartProvider cartProvider,
      ) {
    final pharmacyTotal = cartProvider.getPharmacyTotal(pharmacyId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade50.withOpacity(0.6),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_pharmacy, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      pharmacyName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${pharmacyTotal.toStringAsFixed(2)} FCFA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildCartItem(context, item, cartProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context,
      CartItem item,
      CartProvider cartProvider,
      ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medicationName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.price.toStringAsFixed(2)} FCFA',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: ${item.availableStock}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      try {
                        cartProvider.decrementQuantity(
                          item.pharmacyId,
                          item.medicationId,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.remove,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      try {
                        cartProvider.incrementQuantity(
                          item.pharmacyId,
                          item.medicationId,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${item.subtotal.toStringAsFixed(2)} FCFA',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
            onPressed: () {
              cartProvider.removeItem(item.pharmacyId, item.medicationId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Article retiré du panier'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartBottomBar(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${cartProvider.totalPrice.toStringAsFixed(2)} FCFA',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _showCheckoutDialog(context, cartProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Commander',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le panier'),
        content: const Text('Êtes-vous sûr de vouloir vider tout le panier ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              cartProvider.clearCart();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Panier vidé'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Vider',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer la commande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: ${cartProvider.totalPrice.toStringAsFixed(2)} FCFA'),
            Text('Articles: ${cartProvider.totalItems}'),
            Text('Pharmacies: ${cartProvider.pharmacyCount}'),
            const SizedBox(height: 8),
            Text(
              'Vous allez passer ${cartProvider.pharmacyCount} commande(s).',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          Consumer<OrdersProvider>(
            builder: (context, ordersProvider, _) {
              return ElevatedButton(
                onPressed: ordersProvider.isLoading
                    ? null
                    : () => _processOrders(context, dialogContext, cartProvider, ordersProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                ),
                child: ordersProvider.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text('Confirmer'),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _processOrders(
      BuildContext context,
      BuildContext dialogContext,
      CartProvider cartProvider,
      OrdersProvider ordersProvider,
      ) async {
    // Fermer le dialogue de confirmation
    Navigator.pop(dialogContext);

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Traitement de vos commandes...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Créer une commande pour chaque pharmacie
      final pharmacyIds = cartProvider.cartByPharmacy.keys.toList();
      int successCount = 0;
      int failCount = 0;
      List<String> errorMessages = [];

      for (final pharmacyId in pharmacyIds) {
        final items = cartProvider.cartByPharmacy[pharmacyId]!;

        // Créer la requête de commande
        final orderRequest = CreateOrderRequest(
          pharmacyId: pharmacyId,
          items: items.map((item) => CreateOrderItem(
            medicationId: item.medicationId,
            quantity: item.quantity,
          )).toList(),
        );

        try {
          // Envoyer la commande au backend
          await ordersProvider.createOrder(orderRequest);
          successCount++;
        } catch (e) {
          failCount++;
          errorMessages.add('Pharmacie ${items.first.pharmacyName}: ${e.toString()}');
        }
      }

      // Fermer l'indicateur de chargement
      if (context.mounted) Navigator.pop(context);

      // Afficher le résultat
      if (failCount == 0) {
        // Toutes les commandes ont réussi
        if (context.mounted) {
          cartProvider.clearCart();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$successCount commande(s) créée(s) avec succès !'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Naviguer vers l'historique
          context.read<NavigationProvider>().setIndex(3);
        }
      } else if (successCount == 0) {
        // Toutes les commandes ont échoué
        if (context.mounted) {
          _showErrorDialog(
            context,
            'Échec de la commande',
            'Aucune commande n\'a pu être créée.\n\n${errorMessages.join('\n')}',
          );
        }
      } else {
        // Succès partiel
        if (context.mounted) {
          // Supprimer du panier uniquement les commandes réussies
          // Pour l'instant on garde tout, mais vous pouvez implémenter une logique plus fine

          _showErrorDialog(
            context,
            'Commandes partiellement traitées',
            '$successCount commande(s) créée(s), $failCount échouée(s).\n\n${errorMessages.join('\n')}',
            isWarning: true,
          );
        }
      }
    } catch (e) {
      // Erreur générale
      if (context.mounted) {
        Navigator.pop(context); // Fermer l'indicateur de chargement

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showErrorDialog(
      BuildContext context,
      String title,
      String message, {
        bool isWarning = false,
      }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isWarning ? Icons.warning : Icons.error,
              color: isWarning ? Colors.orange : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          if (isWarning)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<NavigationProvider>().setIndex(3);
              },
              child: const Text('Voir l\'historique'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, _) {
        if (ordersProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (ordersProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red.shade300,
                ),
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
                  'Aucune commande pour le moment',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigation vers les détails de la commande
          // Navigator.pushNamed(context, '/order-details', arguments: order.id);
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(order.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '${order.items.length} article(s)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case OrderStatus.PENDING:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade700;
        break;
      case OrderStatus.CONFIRMED:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        break;
      case OrderStatus.PREPARED:
        backgroundColor = Colors.purple.shade100;
        textColor = Colors.purple.shade700;
        break;
      case OrderStatus.READY_FOR_PICKUP:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        break;
      case OrderStatus.COMPLETED:
        backgroundColor = Colors.teal.shade100;
        textColor = Colors.teal.shade700;
        break;
      case OrderStatus.CANCELLED:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:easypharma_flutter/presentation/providers/auth_provider.dart';
// import 'package:easypharma_flutter/presentation/providers/navigation_provider.dart';
// import 'package:easypharma_flutter/presentation/widgets/medication_search_bar.dart';
// import 'package:easypharma_flutter/presentation/providers/location_provider.dart';
// import 'package:easypharma_flutter/presentation/providers/cart_provider.dart';
// import 'package:easypharma_flutter/data/models/cart_item_model.dart';
// class PatientHomeScreen extends StatefulWidget {
//   const PatientHomeScreen({super.key});
//   static const routeName = '/patient-home';
//
//   @override
//   State<PatientHomeScreen> createState() => _PatientHomeScreenState();
// }
//
// class _PatientHomeScreenState extends State<PatientHomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // Tenter de récupérer la localisation si elle n'est pas déjà là
//       // Cela déclenchera les demandes de permission/service natives
//       final locationProvider = context.read<LocationProvider>();
//       if (locationProvider.userLocation == null) {
//         locationProvider.ensureLocation();
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<NavigationProvider>(
//       builder: (context, navProvider, _) {
//         return WillPopScope(
//           onWillPop: () async {
//             if (navProvider.currentIndex != 0) {
//               navProvider.setIndex(0);
//               return false;
//             }
//             return true;
//           },
//           child: Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               backgroundColor: Colors.white,
//               elevation: 0,
//               leading:
//                   navProvider.currentIndex != 0
//                       ? IconButton(
//                         icon: Icon(
//                           Icons.arrow_back,
//                           color: Colors.blue.shade700,
//                         ),
//                         onPressed: () => navProvider.setIndex(0),
//                       )
//                       : null,
//               title: Text(
//                 'EasyPharma',
//                 style: TextStyle(
//                   color: Colors.blue.shade700,
//                   fontSize: 22,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.3,
//                 ),
//               ),
//               automaticallyImplyLeading: false,
//               actions: [
//                 IconButton(
//                   icon: Icon(Icons.person_outline, color: Colors.blue.shade700),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/profile');
//                   },
//                   tooltip: 'Mon profil',
//                 ),
//               ],
//             ),
//             body: _buildContent(context, navProvider.currentIndex),
//             // Remplacez votre bottomNavigationBar dans le Scaffold par ceci :
//
//             bottomNavigationBar: Consumer<CartProvider>(
//               builder: (context, cartProvider, _) {
//                 return BottomNavigationBar(
//                   backgroundColor: Colors.white,
//                   selectedItemColor: Colors.blue.shade700,
//                   unselectedItemColor: Colors.grey.shade400,
//                   type: BottomNavigationBarType.fixed,
//                   items: [
//                     const BottomNavigationBarItem(
//                       icon: Icon(Icons.home_outlined),
//                       activeIcon: Icon(Icons.home),
//                       label: 'Accueil',
//                     ),
//                     const BottomNavigationBarItem(
//                       icon: Icon(Icons.search_outlined),
//                       activeIcon: Icon(Icons.search),
//                       label: 'Recherche',
//                     ),
//                     BottomNavigationBarItem(
//                       icon: Stack(
//                         children: [
//                           const Icon(Icons.shopping_cart_outlined),
//                           if (cartProvider.totalItems > 0)
//                             Positioned(
//                               right: 0,
//                               top: 0,
//                               child: Container(
//                                 padding: const EdgeInsets.all(2),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 constraints: const BoxConstraints(
//                                   minWidth: 16,
//                                   minHeight: 16,
//                                 ),
//                                 child: Text(
//                                   '${cartProvider.totalItems}',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       activeIcon: Stack(
//                         children: [
//                           const Icon(Icons.shopping_cart),
//                           if (cartProvider.totalItems > 0)
//                             Positioned(
//                               right: 0,
//                               top: 0,
//                               child: Container(
//                                 padding: const EdgeInsets.all(2),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 constraints: const BoxConstraints(
//                                   minWidth: 16,
//                                   minHeight: 16,
//                                 ),
//                                 child: Text(
//                                   '${cartProvider.totalItems}',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       label: 'Panier',
//                     ),
//                     const BottomNavigationBarItem(
//                       icon: Icon(Icons.history_outlined),
//                       activeIcon: Icon(Icons.history),
//                       label: 'Historique',
//                     ),
//                   ],
//                   currentIndex: navProvider.currentIndex,
//                   onTap: (index) => navProvider.setIndex(index),
//                 );
//               },
//             ),
//             // bottomNavigationBar: BottomNavigationBar(
//             //   backgroundColor: Colors.white,
//             //   selectedItemColor: Colors.blue.shade700,
//             //   unselectedItemColor: Colors.grey.shade400,
//             //   type: BottomNavigationBarType.fixed,
//             //   items: const [
//             //     BottomNavigationBarItem(
//             //       icon: Icon(Icons.home_outlined),
//             //       activeIcon: Icon(Icons.home),
//             //       label: 'Accueil',
//             //     ),
//             //     BottomNavigationBarItem(
//             //       icon: Icon(Icons.search_outlined),
//             //       activeIcon: Icon(Icons.search),
//             //       label: 'Recherche',
//             //     ),
//             //     BottomNavigationBarItem(
//             //       icon: Icon(Icons.shopping_cart_outlined),
//             //       activeIcon: Icon(Icons.shopping_cart),
//             //       label: 'Panier',
//             //     ),
//             //     BottomNavigationBarItem(
//             //       icon: Icon(Icons.history_outlined),
//             //       activeIcon: Icon(Icons.history),
//             //       label: 'Historique',
//             //     ),
//             //   ],
//             //   currentIndex: navProvider.currentIndex,
//             //   onTap: (index) => navProvider.setIndex(index),
//             // ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildContent(BuildContext context, int currentIndex) {
//     switch (currentIndex) {
//       case 0:
//         return _buildHomeView(context);
//       case 1:
//         return _buildSearchView();
//       case 2:
//         return _buildCartView();
//       case 3:
//         return _buildHistoryView();
//       default:
//         return _buildHomeView(context);
//     }
//   }
//
//   Widget _buildHomeView(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           // === BARRE DE RECHERCHE DE MÉDICAMENTS ===
//           const MedicationSearchBar(showButton: true),
//           const SizedBox(height: 16),
//
//           // === HEADER DE BIENVENUE ===
//           Container(
//             width: double.infinity,
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue.shade300, Colors.blue.shade600],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.shade600.withOpacity(0.4),
//                   blurRadius: 15,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     const Text(
//                       'Bienvenue, ',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Consumer<AuthProvider>(
//                       builder:
//                           (context, authProvider, _) => Text(
//                             authProvider.user?.firstName ?? 'Utilisateur',
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.white,
//                             ),
//                           ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Trouvez vos médicaments en quelques clics',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.white.withOpacity(0.9),
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // === STATISTIQUES ===
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _buildStatCard(
//                     icon: Icons.shopping_bag_outlined,
//                     title: 'Commandes',
//                     value: '0',
//                     color: Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildStatCard(
//                     icon: Icons.favorite_outline,
//                     title: 'Favoris',
//                     value: '0',
//                     color: Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // === RACCOURCIS ===
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Accès rapide',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 GridView.count(
//                   crossAxisCount: 2,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                   children: [
//                     _buildShortcutCard(
//                       icon: Icons.search_outlined,
//                       title: 'Recherche',
//                       color: Colors.blue,
//                       onTap:
//                           () => context.read<NavigationProvider>().setIndex(1),
//                     ),
//                     _buildShortcutCard(
//                       icon: Icons.shopping_cart_outlined,
//                       title: 'Panier',
//                       color: Colors.green,
//                       onTap:
//                           () => context.read<NavigationProvider>().setIndex(2),
//                     ),
//                     _buildShortcutCard(
//                       icon: Icons.history_outlined,
//                       title: 'Historique',
//                       color: Colors.orange,
//                       onTap:
//                           () => context.read<NavigationProvider>().setIndex(3),
//                     ),
//                     _buildShortcutCard(
//                       icon: Icons.person_outline,
//                       title: 'Mon Profil',
//                       color: Colors.purple,
//                       onTap: () => Navigator.pushNamed(context, '/profile'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // === SECTION OFFRES SPÉCIALES ===
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Offres spéciales',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 _buildOfferCard(),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }
//
//   static Widget _buildOfferCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue.shade50, Colors.blue.shade100],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.local_offer_outlined, color: Colors.blue.shade700),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   '-15% sur votre première commande',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.blue.shade800,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Utilisez le code WELCOME15 lors de votre commande',
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.blue.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static Widget _buildStatCard({
//     required IconData icon,
//     required String title,
//     required String value,
//     required MaterialColor color,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: color.shade100.withOpacity(0.3),
//             blurRadius: 8,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 45,
//             height: 45,
//             decoration: BoxDecoration(
//               color: color.shade50,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: color.shade700, size: 24),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w800,
//               color: color.shade700,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   static Widget _buildShortcutCard({
//     required IconData icon,
//     required String title,
//     required MaterialColor color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.shade200),
//           boxShadow: [
//             BoxShadow(
//               color: color.shade100.withOpacity(0.2),
//               blurRadius: 8,
//               spreadRadius: 0,
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: color.shade50,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(icon, color: color.shade700, size: 26),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.blue.shade800,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   static Widget _buildSearchView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: Colors.blue.shade100,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               Icons.search_outlined,
//               size: 40,
//               color: Colors.blue.shade700,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Recherche de médicaments',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Colors.blue.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Trouvez rapidement les médicaments\nque vous recherchez',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // static Widget _buildCartView() {
//   //   return Center(
//   //     child: Column(
//   //       mainAxisAlignment: MainAxisAlignment.center,
//   //       children: [
//   //         Container(
//   //           width: 80,
//   //           height: 80,
//   //           decoration: BoxDecoration(
//   //             color: Colors.green.shade100,
//   //             borderRadius: BorderRadius.circular(20),
//   //           ),
//   //           child: Icon(
//   //             Icons.shopping_cart_outlined,
//   //             size: 40,
//   //             color: Colors.green.shade700,
//   //           ),
//   //         ),
//   //         const SizedBox(height: 20),
//   //         Text(
//   //           'Panier',
//   //           style: TextStyle(
//   //             fontSize: 18,
//   //             fontWeight: FontWeight.w700,
//   //             color: Colors.blue.shade700,
//   //           ),
//   //         ),
//   //         const SizedBox(height: 8),
//   //         Text(
//   //           'Votre panier est vide',
//   //           textAlign: TextAlign.center,
//   //           style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   Widget _buildCartView() {
//     return Consumer<CartProvider>(
//       builder: (context, cartProvider, _) {
//         if (cartProvider.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Icon(
//                     Icons.shopping_cart_outlined,
//                     size: 40,
//                     color: Colors.green.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Text(
//                   'Panier',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Votre panier est vide',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     context.read<NavigationProvider>().setIndex(1);
//                   },
//                   icon: const Icon(Icons.search),
//                   label: const Text('Rechercher des médicaments'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue.shade700,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Column(
//           children: [
//             // En-tête avec actions
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border(
//                   bottom: BorderSide(color: Colors.grey.shade200),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Mon Panier',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.blue.shade700,
//                         ),
//                       ),
//                       Text(
//                         '${cartProvider.totalItems} article(s) - ${cartProvider.pharmacyCount} pharmacie(s)',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
//                     onPressed: () {
//                       _showClearCartDialog(context, cartProvider);
//                     },
//                     tooltip: 'Vider le panier',
//                   ),
//                 ],
//               ),
//             ),
//
//             // Liste des articles
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: cartProvider.cartByPharmacy.length,
//                 itemBuilder: (context, index) {
//                   final pharmacyId =
//                   cartProvider.cartByPharmacy.keys.elementAt(index);
//                   final items = cartProvider.cartByPharmacy[pharmacyId]!;
//                   final pharmacyName = items.first.pharmacyName;
//
//                   return _buildPharmacySection(
//                     context,
//                     pharmacyId,
//                     pharmacyName,
//                     items,
//                     cartProvider,
//                   );
//                 },
//               ),
//             ),
//
//             // Barre de total et commande
//             _buildCartBottomBar(context, cartProvider),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildPharmacySection(
//       BuildContext context,
//       String pharmacyId,
//       String pharmacyName,
//       List<CartItem> items,
//       CartProvider cartProvider,
//       ) {
//     final pharmacyTotal = cartProvider.getPharmacyTotal(pharmacyId);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.blue.shade50.withOpacity(0.6),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // En-tête de la pharmacie
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.local_pharmacy,
//                         color: Colors.blue.shade700, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       pharmacyName,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   '${pharmacyTotal.toStringAsFixed(2)} FCFA',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: Colors.green.shade700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Liste des médicaments
//           ListView.separated(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: items.length,
//             separatorBuilder: (_, __) => Divider(
//               height: 1,
//               color: Colors.grey.shade200,
//             ),
//             itemBuilder: (context, index) {
//               final item = items[index];
//               return _buildCartItem(context, item, cartProvider);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCartItem(
//       BuildContext context,
//       CartItem item,
//       CartProvider cartProvider,
//       ) {
//     return Padding(
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Informations du médicament
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.medicationName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '${item.price.toStringAsFixed(2)} FCFA',
//                   style: TextStyle(
//                     color: Colors.green.shade700,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Stock: ${item.availableStock}',
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Contrôles de quantité
//           Column(
//             children: [
//               Row(
//                 children: [
//                   // Bouton diminuer
//                   InkWell(
//                     onTap: () {
//                       try {
//                         cartProvider.decrementQuantity(
//                           item.pharmacyId,
//                           item.medicationId,
//                         );
//                       } catch (e) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(e.toString()),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Icon(
//                         Icons.remove,
//                         size: 16,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                   ),
//
//                   // Quantité
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: Text(
//                       '${item.quantity}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//
//                   // Bouton augmenter
//                   InkWell(
//                     onTap: () {
//                       try {
//                         cartProvider.incrementQuantity(
//                           item.pharmacyId,
//                           item.medicationId,
//                         );
//                       } catch (e) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(e.toString()),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Icon(
//                         Icons.add,
//                         size: 16,
//                         color: Colors.blue.shade700,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//
//               // Sous-total
//               Text(
//                 '${item.subtotal.toStringAsFixed(2)} FCFA',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 13,
//                 ),
//               ),
//             ],
//           ),
//
//           // Bouton supprimer
//           IconButton(
//             icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
//             onPressed: () {
//               cartProvider.removeItem(item.pharmacyId, item.medicationId);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Article retiré du panier'),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCartBottomBar(BuildContext context, CartProvider cartProvider) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Total',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 Text(
//                   '${cartProvider.totalPrice.toStringAsFixed(2)} FCFA',
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _showCheckoutDialog(context, cartProvider);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue.shade700,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 32,
//                   vertical: 16,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'Commander',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Vider le panier'),
//         content: const Text('Êtes-vous sûr de vouloir vider tout le panier ?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Annuler'),
//           ),
//           TextButton(
//             onPressed: () {
//               cartProvider.clearCart();
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Panier vidé'),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//             },
//             child: const Text(
//               'Vider',
//               style: TextStyle(color: Colors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showCheckoutDialog(BuildContext context, CartProvider cartProvider) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirmer la commande'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Total: ${cartProvider.totalPrice.toStringAsFixed(2)} FCFA'),
//             Text('Articles: ${cartProvider.totalItems}'),
//             Text('Pharmacies: ${cartProvider.pharmacyCount}'),
//             const SizedBox(height: 8),
//             Text(
//               'Vous allez passer ${cartProvider.pharmacyCount} commande(s).',
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Annuler'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Implémenter la logique de commande ici
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Commande en cours de traitement...'),
//                   duration: Duration(seconds: 3),
//                 ),
//               );
//               // Optionnel: vider le panier après la commande
//               // cartProvider.clearCart();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue.shade700,
//             ),
//             child: const Text('Confirmer'),
//           ),
//         ],
//       ),
//     );
//   }
//   static Widget _buildHistoryView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: Colors.orange.shade100,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(
//               Icons.history_outlined,
//               size: 40,
//               color: Colors.orange.shade700,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Historique',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Colors.blue.shade700,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Aucune commande pour le moment',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }
}