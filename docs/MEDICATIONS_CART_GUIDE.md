# Guide de gestion des médicaments et du panier

## Architecture

### Composants principaux

1. **MedicationProvider** (`lib/presentation/providers/medication_provider.dart`)
   - Gère la recherche de médicaments
   - Filtrage par classe thérapeutique, ordonnance, prix, localisation
   - Tri: NEAREST, NAME, PRICE

2. **PharmacyInventoryProvider** (`lib/presentation/providers/pharmacy_inventory_provider.dart`) **[AMÉLIORÉ]**
   - Gère l'inventaire par pharmacie
   - Déduplication automatique
   - Cache avec invalidation
   - Validation des données

3. **CartProvider** (`lib/presentation/providers/cart_provider.dart`)
   - Gère les articles du panier
   - Groupement par pharmacie
   - Calcul automatique des totaux

---

## Flux d'utilisation

### 1. Recherche de médicaments

```dart
// Dans PatientHomeScreen
final medProvider = context.read<MedicationProvider>();
await medProvider.searchMedications(
  query: 'Paracétamol',
  userLat: 4.048,
  userLon: 9.704,
  sortBy: 'NEAREST',
  therapeuticClass: 'ANTALGIQUE',
);

// Résultats = List<PharmacyMedication>
final results = medProvider.searchResults;
```

### 2. Affichage des résultats

Les médicaments s'affichent dans `_buildSearchResults()`:
```dart
Card(
  child: Column(
    children: [
      Text(med.name),           // Nom du médicament
      Text('${pm.price} FCFA'), // Prix
      Container(
        child: Text(
          isOutOfStock ? 'Rupture' : 'Stock: ${pm.quantityInStock}',
        ),
      ),
      IconButton(
        icon: Icon(Icons.add_shopping_cart),
        onPressed: isOutOfStock ? null : () => addToCart(),
      ),
    ],
  ),
)
```

### 3. Ajout au panier

```dart
void addToCart(PharmacyMedication medication) {
  final isOutOfStock = medication.quantityInStock <= 0;
  
  if (!isOutOfStock) {
    context.read<CartProvider>().addItem(
      medication.medication,
      medication.pharmacy,
      medication.price,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${medication.medication.name} ajouté au panier')),
    );
  }
}
```

### 4. Gestion du panier

```dart
// Ajouter
cart.addItem(medication, pharmacy, price);

// Mettre à jour la quantité
cart.updateQuantity(medicationId, 3);

// Supprimer
cart.removeItem(medicationId);

// Obtenir le total
print('Total: ${cart.totalAmount} FCFA');
print('Articles: ${cart.totalItems}');

// Vider
cart.clear();
```

### 5. Commande

```dart
// Pour chaque pharmacie du panier
for (final pharmacyId in cart.cartByPharmacy.keys) {
  final items = cart.cartByPharmacy[pharmacyId]!;
  
  final orderRequest = CreateOrderRequest(
    pharmacyId: pharmacyId,
    items: items.map((item) => CreateOrderItem(
      medicationId: item.medication.id,
      quantity: item.quantity,
    )).toList(),
  );
  
  await ordersProvider.createOrder(orderRequest);
}

cart.clear(); // Vider après succès
```

---

## Gestion de l'inventaire (Pharmacien)

### Charger l'inventaire

```dart
final inventoryProvider = context.read<PharmacyInventoryProvider>();

// Chargement initial (utilise le cache)
await inventoryProvider.loadInventory(pharmacyId);

// Forcer la mise à jour
await inventoryProvider.loadInventory(pharmacyId, forceRefresh: true);
```

### Ajouter un médicament

```dart
await inventoryProvider.addMedication(
  pharmacyId: 'pharmacy-uuid',
  medicationId: 'medication-uuid',
  price: 5000.0,
  quantityInStock: 100,
);

// Message de succès si pas d'erreur
if (inventoryProvider.successMessage != null) {
  showSnackBar(inventoryProvider.successMessage!);
}
```

### Mettre à jour le stock

```dart
// Vente (réduire stock)
await inventoryProvider.updateStock(
  pharmacyId,
  medicationId,
  newQuantity - 1,  // 100 - 1 = 99
);

// Rupture (marquer)
await inventoryProvider.updateStock(
  pharmacyId,
  medicationId,
  0,  // Rupture
);
```

### Mettre à jour le prix

```dart
await inventoryProvider.updatePrice(
  pharmacyId,
  medicationId,
  5500.0,  // Nouveau prix
);
```

### Supprimer un médicament

```dart
await inventoryProvider.removeMedication(
  pharmacyId,
  medicationId,
);
```

---

## Requêtes d'API

### Rechercher des médicaments (Patient)

**GET** `/api/v1/medications/search`
```json
{
  "query": "Paracétamol",
  "sortBy": "NEAREST",
  "userLat": 4.048,
  "userLon": 9.704,
  "therapeuticClass": "ANTALGIQUE",
  "requiresPrescription": false,
  "minPrice": 1000,
  "maxPrice": 10000,
  "availability": "IN_STOCK"
}
```

### Obtenir l'inventaire d'une pharmacie

**GET** `/api/v1/pharmacies/{pharmacyId}/medications`

Retourne:
```json
{
  "data": [
    {
      "id": "uuid",
      "medicationId": "uuid",
      "pharmacyId": "uuid",
      "price": 5000,
      "quantityInStock": 100,
      "medication": {...},
      "pharmacy": {...},
      "createdAt": "2026-01-05T14:14:44Z",
      "updatedAt": "2026-01-05T14:14:44Z"
    }
  ]
}
```

### Ajouter un médicament à l'inventaire

**POST** `/api/v1/pharmacies/{pharmacyId}/medications/{medicationId}`
```json
{
  "price": 5000,
  "quantityInStock": 100
}
```

---

## Points communs de synchronisation

### 1. **Déduplication**
- Fonction: `PharmacyInventoryProvider._deduplicateMedications()`
- Stratégie: Garder le plus récent par `{medicationId}_{pharmacyId}`
- Exécuté: À chaque `loadInventory()`

### 2. **Validation**
- Prix >= 0
- Quantité >= 0
- Nom non vide
- Exécuté dans: `addMedication()`, `updateStock()`, `updatePrice()`, `_validateMedications()`

### 3. **Cache**
- Durée: 5 minutes par pharmacie
- Invalidation: Automatique après 5 min ou avec `invalidateCache()`
- Affecte: `loadInventory()` uniquement

### 4. **État du stock**
- "En stock": `quantityInStock > 0`
- "Rupture": `quantityInStock <= 0`
- Affichage: Tag coloré dans l'UI avec le nombre exact

---

## Troubleshooting

### Problème: Les noms ne s'affichent pas
**Solution:**
1. Vérifier que `medication.name` n'est pas vide dans la base de données
2. Exécuter `cleanup_duplicates.sql`
3. Forcer le rechargement: `loadInventory(pharmacyId, forceRefresh: true)`

### Problème: Toujours en rupture
**Solution:**
1. Vérifier la base de données: `SELECT quantityInStock FROM pharmacy_medications`
2. Valider qu'aucune quantité n'est négative
3. Exécuter: `UPDATE pharmacy_medications SET quantity_in_stock = 100 WHERE quantity_in_stock < 0`

### Problème: Doublons persistants
**Solution:**
1. Exécuter le script SQL de nettoyage
2. Appeler `invalidateCache(pharmacyId)` côté client
3. Redémarrer l'application

### Problème: Panier vide après création de commande
**Solution:** (Comportement normal)
- Le panier est vidé automatiquement après succès
- C'est attendu via `cart.clear()`

---

## Vérifications

### Avant le déploiement

- [ ] Exécuter `cleanup_duplicates.sql` sur la BD
- [ ] Vérifier que tous les médicaments ont des noms
- [ ] Vérifier que toutes les quantités sont >= 0
- [ ] Tester la recherche dans au moins 2 pharmacies
- [ ] Tester l'ajout au panier
- [ ] Tester la création de commande
- [ ] Vérifier les statistiques d'inventaire

### Lors du déploiement

- [ ] Mettre à jour les codes d'erreur si nécessaire
- [ ] Configurer les endpoints d'API
- [ ] Tester le cache (attendre 5 min ou utiliser `invalidateCache()`)
- [ ] Tester les performances avec ~100 médicaments par pharmacie
