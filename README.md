# EasyPharma Flutter Application

Application mobile pour la recherche et commande de médicaments.

## Structure du projet

### Phase 1 - Authentification
- [x] Connexion
- [x] Inscription
- [x] Récupération profil

### Phase 2 - Gestion profil
- [x] Modification profil
- [x] Déconnexion
- [x] Mot de passe oublié

### Phase 3 - Navigation par rôle
- [x] Accueil Patient
- [x] Accueil Livreur

## Configuration

1. Installer les dépendances:
```bash
flutter pub get
31/12/2025
les fonctionnalité que j'ai dû ajouter pour pouvoir gerer ma tache qui est donner la possibilité aux clients de passer une commande
✅ Ajout au panier : Les médicaments sont maintenant ajoutés au panier avec leurs informations complètes
✅ Gestion du stock : Le système vérifie le stock disponible avant d'ajouter
✅ Organisation par pharmacie : Les articles sont groupés par pharmacie
✅ Modification des quantités : Possibilité d'augmenter/diminuer les quantités
✅ Calcul automatique : Total calculé automatiquement
✅ Badge de notification : Indicateur du nombre d'articles dans le panier
✅ Suppression d'articles : Possibilité de retirer des articles individuels ou vider tout le panier
✅ Nouvelles fonctionnalités
1. Traitement des commandes

Lorsque l'utilisateur clique sur "Commander", le système crée une commande pour chaque pharmacie
Gère les succès partiels (certaines commandes réussissent, d'autres échouent)
Affiche un indicateur de progression pendant le traitement

2. Gestion des erreurs

Messages d'erreur détaillés par pharmacie
Dialogue d'alerte en cas d'échec
Gestion des erreurs réseau avec Dio

3. Historique des commandes

Affichage de toutes les commandes avec leur statut
Pull-to-refresh pour actualiser
Cartes cliquables (prêtes pour navigation vers détails)
Badges de statut colorés (En attente, Confirmée, etc.)

4. Interface améliorée

Compteur de commandes sur la page d'accueil
État de chargement pendant les requêtes
Messages de succès/échec clairs
Navigation automatique vers l'historique après succès

5. Flux complet
1. Utilisateur ajoute des médicaments au panier
2. Clique sur "Commander"
3. Confirme dans le dialogue
4. Le système crée les commandes (une par pharmacie)
5. Affiche le résultat (succès/échec)
6. Vide le panier si succès
7. Redirige vers l'historique
8. Actualise la liste des commandes