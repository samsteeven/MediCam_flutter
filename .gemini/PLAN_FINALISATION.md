# 🚀 Plan d'Action : Finalisation de l'Application Patient

## 📋 Tâches à Accomplir

### ✅ **1. Renommer "Historique" en "Commandes"**

- [ ] Bottom navigation bar (ligne 195)
- [ ] Raccourci page d'accueil (ligne 606)
- [ ] Titre de la section

### ✅ **2. Supprimer le Bouton Favoris**

- [ ] Carte statistique page d'accueil (lignes 556-562)
- [ ] Toute logique liée aux favoris

### ✅ **3. Créer Page de Détails du Médicament**

- [ ] Nouvelle route `/medication-details`
- [ ] Afficher informations complètes
- [ ] Bouton ajouter au panier
- [ ] Liste des pharmacies vendant ce médicament

### ✅ **4. Corriger les Notifications Push**

- [ ] Vérifier `NotificationProvider`
- [ ] S'assurer que les alertes s'affichent
- [ ] Tester le polling

### ✅ **5. Finaliser les Filtres de Recherche**

- [ ] Vérifier que tous les filtres fonctionnent
- [ ] Prix min/max
- [ ] Classe thérapeutique
- [ ] Disponibilité
- [ ] Tri (prix, nom, proximité)

### ✅ **6. Utiliser TOUS les Endpoints Patient**

#### **Endpoints Utilisés** ✅

- [x] `/auth/login`
- [x] `/auth/register`
- [x] `/auth/me`
- [x] `/users/me` (update profile)
- [x] `/users/me/password`
- [x] `/orders/my-orders`
- [x] `/orders` (create order)
- [x] `/orders/{id}/status`
- [x] `/patient/search` (medications)
- [x] `/pharmacies/nearby`
- [x] `/pharmacies/{id}`
- [x] `/reviews` (create review)
- [x] `/reviews/pharmacy/{id}`
- [x] `/notifications/my-notifications`
- [x] `/notifications/{id}/read`
- [x] `/prescriptions/my-prescriptions`
- [x] `/prescriptions` (upload)

#### **Endpoints à Implémenter** ⚠️

- [ ] `/medications/{id}` - Détails d'un médicament
- [ ] `/medications/by-class/{class}` - Filtrer par classe
- [ ] `/medications/prescription-required` - Médicaments sur ordonnance
- [ ] `/pharmacies/search/by-name` - Recherche pharmacie par nom
- [ ] `/pharmacies/search/by-city` - Recherche pharmacie par ville
- [ ] `/orders/{id}` - Détails d'une commande
- [ ] `/payments/order/{orderId}` - Paiement d'une commande
- [ ] `/reviews/{id}` - Supprimer un avis
- [ ] `/files/upload` - Upload de fichiers (ordonnances)

### ✅ **7. Redirection Bouton Commandes**

- [ ] Vérifier que le clic sur "Commandes" redirige vers l'onglet 3
- [ ] S'assurer que l'onglet 3 affiche bien l'historique

---

## 🎯 Ordre d'Implémentation

1. **Renommer "Historique" → "Commandes"** (Simple, rapide)
2. **Supprimer le bouton Favoris** (Simple, rapide)
3. **Corriger les notifications push** (Important pour UX)
4. **Créer la page de détails du médicament** (Fonctionnalité clé)
5. **Finaliser les filtres de recherche** (Amélioration UX)
6. **Implémenter les endpoints manquants** (Compléter l'app)

---

## 📝 Notes

- **Endpoints Admin/Pharmacien** : Ignorés (comme demandé)
- **Endpoints Livreur** : Déjà implémentés dans `delivery_home_screen.dart`
- **Focus** : Patient uniquement

---

## 🚀 Prochaines Étapes

1. Commencer par les modifications simples (renommage, suppression favoris)
2. Corriger les notifications
3. Créer la page de détails du médicament
4. Finaliser les filtres
5. Implémenter les endpoints manquants
