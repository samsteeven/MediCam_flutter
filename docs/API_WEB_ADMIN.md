# API Web - Documentation Administrative

## Vue d'ensemble
Cette documentation couvre les endpoints API nécessaires pour la partie web d'administration d'EasyPharma.

## Endpoints Pharmacie

### GET /api/v1/pharmacies
Récupère la liste de toutes les pharmacies

**Paramètres:**
- `status` (optional): PENDING, APPROVED, SUSPENDED
- `city` (optional): Filtrer par ville
- `page` (optional): Pagination (défaut: 1)
- `limit` (optional): Éléments par page (défaut: 10)

**Réponse:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Pharmacie du Soleil",
      "address": "Rue de la Joie, Akwa",
      "city": "Douala",
      "phone": "+237699999999",
      "latitude": 4.04830000,
      "longitude": 9.70420000,
      "licenseNumber": "LIC-TEST-001",
      "status": "APPROVED",
      "createdAt": "2026-01-05T14:18:22Z",
      "updatedAt": "2026-01-05T14:18:22Z"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 10
}
```

### GET /api/v1/pharmacies/:id
Récupère les détails d'une pharmacie spécifique

### PUT /api/v1/pharmacies/:id/status
Met à jour le statut d'une pharmacie (APPROVED, SUSPENDED, etc.)

**Body:**
```json
{
  "status": "APPROVED"
}
```

---

## Endpoints Médicaments

### GET /api/v1/medications
Récupère la liste de tous les médicaments du catalogue

**Paramètres:**
- `therapeuticClass` (optional): Filtrer par classe thérapeutique
- `requiresPrescription` (optional): true/false
- `page` (optional): Pagination
- `limit` (optional): Éléments par page

**Réponse:**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "Paracétamol 500mg",
      "genericName": "Paracétamol",
      "therapeuticClass": "ANTALGIQUE",
      "description": "Analgésique et antipyrétique...",
      "requiresPrescription": false,
      "createdAt": "2026-01-05T14:14:44Z",
      "updatedAt": "2026-01-05T14:14:44Z"
    }
  ],
  "total": 28,
  "page": 1,
  "limit": 10
}
```

### POST /api/v1/medications
Crée un nouveau médicament dans le catalogue

**Body:**
```json
{
  "name": "Ibuprofène 400mg",
  "genericName": "Ibuprofène",
  "therapeuticClass": "ANTIINFLAMMATOIRE",
  "description": "Anti-inflammatoire non stéroïdien",
  "requiresPrescription": false
}
```

### PUT /api/v1/medications/:id
Met à jour un médicament

### DELETE /api/v1/medications/:id
Supprime un médicament

---

## Endpoints Inventaire Pharmacie

### GET /api/v1/pharmacies/:pharmacyId/medications
Récupère l'inventaire complet d'une pharmacie

**Réponse:**
```json
{
  "data": [
    {
      "id": "uuid",
      "medicationId": "uuid",
      "pharmacyId": "uuid",
      "price": 5000,
      "quantityInStock": 100,
      "medication": { ... },
      "pharmacy": { ... },
      "createdAt": "2026-01-05T14:14:44Z",
      "updatedAt": "2026-01-05T14:14:44Z"
    }
  ],
  "total": 28
}
```

### POST /api/v1/pharmacies/:pharmacyId/medications/:medicationId
Ajoute un médicament à l'inventaire d'une pharmacie

**Body:**
```json
{
  "price": 5000,
  "quantityInStock": 100
}
```

### PUT /api/v1/pharmacies/:pharmacyId/medications/:medicationId
Met à jour le prix et/ou la quantité

**Body:**
```json
{
  "price": 5500,
  "quantityInStock": 85
}
```

### DELETE /api/v1/pharmacies/:pharmacyId/medications/:medicationId
Supprime un médicament de l'inventaire

---

## Endpoints Commandes

### GET /api/v1/orders
Récupère les commandes (filtres disponibles)

**Paramètres:**
- `pharmacyId` (optional): Commandes d'une pharmacie
- `status` (optional): PENDING, CONFIRMED, PREPARED, READY_FOR_PICKUP, COMPLETED, CANCELLED
- `startDate` (optional): Format ISO 8601
- `endDate` (optional): Format ISO 8601
- `page` (optional): Pagination

**Réponse:**
```json
{
  "data": [
    {
      "id": "uuid",
      "pharmacyId": "uuid",
      "patientId": "uuid",
      "status": "COMPLETED",
      "items": [
        {
          "medicationId": "uuid",
          "quantity": 2,
          "price": 5000,
          "subtotal": 10000
        }
      ],
      "totalAmount": 10000,
      "createdAt": "2026-01-05T14:14:44Z",
      "updatedAt": "2026-01-05T14:14:44Z"
    }
  ],
  "total": 150,
  "page": 1,
  "limit": 10
}
```

### PUT /api/v1/orders/:id/status
Met à jour le statut d'une commande

**Body:**
```json
{
  "status": "PREPARED"
}
```

---

## Endpoints Statistiques

### GET /api/v1/pharmacies/:pharmacyId/statistics
Récupère les statistiques d'une pharmacie

**Réponse:**
```json
{
  "totalOrders": 150,
  "completedOrders": 145,
  "pendingOrders": 5,
  "totalRevenue": 750000,
  "averageOrderValue": 5000,
  "topMedications": [
    {
      "medicationId": "uuid",
      "name": "Paracétamol 500mg",
      "salesCount": 45,
      "totalRevenue": 225000
    }
  ],
  "period": {
    "startDate": "2026-01-01",
    "endDate": "2026-01-31"
  }
}
```

### GET /api/v1/medications/:medicationId/statistics
Récupère les statistiques de vente d'un médicament

---

## Endpoints Utilisateurs Administrateurs

### GET /api/v1/admin/users
Liste les utilisateurs (patients, pharmaciens, livreurs)

### PUT /api/v1/admin/users/:id/role
Change le rôle d'un utilisateur

### DELETE /api/v1/admin/users/:id
Supprime un utilisateur

---

## Codes d'erreur

| Code | Signification |
|------|---------------|
| 200 | Succès |
| 201 | Créé avec succès |
| 204 | Supprimé avec succès |
| 400 | Requête invalide |
| 401 | Non authentifié |
| 403 | Accès refusé |
| 404 | Ressource non trouvée |
| 409 | Conflit (doublon, etc.) |
| 500 | Erreur serveur |

---

## Authentification

Tous les endpoints (sauf login/register) nécessitent le header:
```
Authorization: Bearer {token}
```

---

## Base URL

**Production:** `https://api.easypharma.com/api/v1`
**Développement:** `http://localhost:8080/api/v1`
