// Modèle pour un article dans le panier
class CartItem {
  final String pharmacyId;
  final String pharmacyName;
  final String medicationId;
  final String medicationName;
  final double price;
  int quantity;
  final int availableStock;

  CartItem({
    required this.pharmacyId,
    required this.pharmacyName,
    required this.medicationId,
    required this.medicationName,
    required this.price,
    this.quantity = 1,
    required this.availableStock,
  });

  // Calculer le sous-total pour cet article
  double get subtotal => price * quantity;

  // Convertir en Map (pour la sauvegarde locale si nécessaire)
  Map<String, dynamic> toJson() => {
    'pharmacyId': pharmacyId,
    'pharmacyName': pharmacyName,
    'medicationId': medicationId,
    'medicationName': medicationName,
    'price': price,
    'quantity': quantity,
    'availableStock': availableStock,
  };

  // Créer depuis un Map
  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    pharmacyId: json['pharmacyId'],
    pharmacyName: json['pharmacyName'],
    medicationId: json['medicationId'],
    medicationName: json['medicationName'],
    price: json['price'],
    quantity: json['quantity'],
    availableStock: json['availableStock'],
  );

  // Copier avec modifications
  CartItem copyWith({
    String? pharmacyId,
    String? pharmacyName,
    String? medicationId,
    String? medicationName,
    double? price,
    int? quantity,
    int? availableStock,
  }) {
    return CartItem(
      pharmacyId: pharmacyId ?? this.pharmacyId,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      availableStock: availableStock ?? this.availableStock,
    );
  }
}