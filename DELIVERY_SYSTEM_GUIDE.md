# 📦 Système de Livraison - Documentation Flutter

## ✅ Composants créés

### 1. **Modèles de données** (`delivery_model.dart`)
- `DeliveryStatus` : Enum des états (PENDING, ACCEPTED, IN_TRANSIT, DELIVERED, CANCELLED)
- `Delivery` : Modèle complet avec méthodes helper
- `DeliveryStats` : Statistiques du livreur

### 2. **Provider de gestion d'état** (`delivery_provider.dart`)
Gère :
- Liste des commandes **disponibles**
- Liste des **mes livraisons**
- Compteurs : pending, in_transit, completed
- Actions : accepter, marquer en route, marquer livrée

**Méthodes principales** :
```dart
- fetchAvailableDeliveries()    // Récupérer les commandes disponibles
- acceptDelivery(id)             // Accepter une commande
- fetchMyDeliveries()            // Récupérer mes commandes
- markAsInTransit(id)            // Marquer comme en route
- markAsDelivered(id)            // Marquer comme livrée
- fetchStats()                   // Récupérer statistiques
```

### 3. **Écrans livreur** 

#### `AvailableDeliveriesScreen` 
Affiche les commandes disponibles pour acceptation
- Filtrage automatique par zone (à implémenter)
- Bouton "Accepter cette commande"
- Affiche : pharmacie, client, adresse, montant, articles

#### `MyDeliveriesScreen`
Affiche les commandes assignées avec onglets :
- **Toutes** : toutes mes livraisons
- **En attente** : acceptées mais pas encore en route
- **En route** : en déplacement
- **Livrées** : complétées

Actions par statut :
- Acceptée → "Partir en route"
- En route → "Marquer comme livrée"

#### `DeliveryHomeScreen`
Écran principal avec navigation :
- Onglet 1 : Commandes disponibles
- Onglet 2 : Mes livraisons
- Badge de notification pour les livraisons en route

---

## 🔧 Intégration Backend requise

### Endpoints API à créer :

```
GET  /deliveries/available              → Liste commandes disponibles
POST /deliveries/{id}/accept            → Accepter une commande
GET  /deliveries/my-deliveries          → Mes commandes
PATCH /deliveries/{id}/status           → Changer statut (IN_TRANSIT, DELIVERED)
GET  /deliveries/stats                  → Stats du livreur
PATCH /deliveries/{id}/cancel           → Annuler livraison
```

### Modifications Base de données :

Table `orders` :
```sql
ALTER TABLE orders ADD COLUMN delivery_status VARCHAR(50);
ALTER TABLE orders ADD COLUMN assigned_delivery_user_id UUID;
```

### Logique métier backend :

1. **Filtrer les commandes disponibles** :
   - Status = READY (prête à être livrée)
   - Delivery status = PENDING
   - Même zone géographique que le livreur (optionnel)

2. **Accepter une commande** :
   - Vérifier qu'aucun autre livreur ne l'a acceptée
   - Créer entrée delivery ou mettre à jour order
   - Retourner la commande mise à jour

3. **Gérer les statuts** :
   - PENDING → ACCEPTED → IN_TRANSIT → DELIVERED

---

## 📱 Comment utiliser

### 1. Enregistrer le Provider

Dans `main.dart` ou votre setup :
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => DeliveryProvider(
        repository: DeliveryRepository(Dio()),
      ),
    ),
    // ... autres providers
  ],
  child: MyApp(),
)
```

### 2. Ajouter les routes

Dans `main.dart` :
```dart
routes: {
  DeliveryHomeScreen.routeName: (ctx) => const DeliveryHomeScreen(),
  // ...
}
```

### 3. Naviguer vers l'écran livreur

```dart
Navigator.pushNamed(context, DeliveryHomeScreen.routeName);
```

---

## 🚀 Flux utilisateur livreur

1. **Accueil** → Voir les commandes disponibles
2. **Cliquer "Accepter"** → Confirmation → Commande ajoutée à "Mes livraisons"
3. **Dans "Mes livraisons"** → Voir tous les statuts
4. **Action "Partir en route"** → Status = IN_TRANSIT
5. **Action "Marquer comme livrée"** → Status = DELIVERED
6. **Notifications** → Badge avec compteur en route

---

## 🎨 UI/UX Features

✅ Pull to refresh sur les deux écrans
✅ Onglets pour filtrer les statuts
✅ Badges colorés par statut
✅ Modal pour voir détails livraison
✅ Notifications toast (succès/erreur)
✅ Empty states avec icônes
✅ Loading indicators
✅ Badge de notification pour livraisons en route

---

## 📝 Notes importantes

- **Image de preuve** : À implémenter dans `markAsDelivered()` (upload image)
- **Localisation en temps réel** : À ajouter avec `location` package
- **Permissions** : Vérifier que seuls les livreurs accèdent à cet écran
- **Synchronisation** : Implémenter WebSocket/polling pour real-time updates

---

## 🔐 Sécurité

- ✅ Authorization header injecté automatiquement (ApiService)
- ✅ Vérifier `user.role == DELIVERY_PERSON` avant accès
- ✅ Backend doit valider le livreuse est authentifié
- ✅ Backend doit valider que la commande existe ET n'est pas déjà assignée

