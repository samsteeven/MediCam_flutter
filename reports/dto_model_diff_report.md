# Rapport de comparaison DTO Backend ↔ Modèles Flutter

Date: 2026-01-13

Résumé: scan automatique limité aux DTO Java présents dans `src/.../dto` et aux modèles Dart dans `lib/data/models`.

---

## Méthodologie
- Extraction manuelle des champs déclarés dans les DTO Java (types Lombok/Java).
- Extraction des champs principaux exposés par les modèles Dart (`fromJson` / propriétés).
- Comparaison simple: champs manquants, noms différents, différences de type évidentes (UUID→String, LocalDateTime→DateTime, BigDecimal/BigDecimal→double).

---

## Résultats par entité

### Delivery
- DTO Java (`DeliveryDTO`) — champs clés:
  - `UUID deliveryId`, `UUID orderId`, `String orderNumber`
  - `UUID deliveryPersonId`, `String deliveryPersonName`
  - `String status`
  - `BigDecimal currentLatitude`, `BigDecimal currentLongitude`
  - `String photoProofUrl`
  - `LocalDateTime assignedAt`, `pickedUpAt`, `deliveredAt`
  - `String deliveryAddress`, `deliveryCity`, `deliveryPhone`, `patientName`
- Modèle Dart (`Delivery`):
  - `id` (String) — accepte `deliveryId` et `id`
  - `orderId` (String)
  - `driverId` (String?) — accepts `deliveryPersonId` and `driverId`
  - `status` (enum DeliveryStatus, nouveaux états `IN_DELIVERY`, `FAILED` ajoutés)
  - `assignedAt`, `pickedUpAt`, `deliveredAt` (DateTime?)
  - `proofUrl` (photoProofUrl/ proofUrl)
  - `order` (Order?) construit si objet imbriqué absent

Différences / risques:
- DTO a `deliveryPersonName`, `currentLatitude`/`currentLongitude`, `orderNumber`, `deliveryAddress/city/phone`, `patientName` — **non exposés** par le modèle Dart.
- Dart tolère flat DTO but loses geolocation/contact info.

Recommandation:
- Ajouter `currentLatitude`/`currentLongitude` et `delivery*` fields au modèle Flutter si affichés dans l'UI.
- Ou documenter qu'ils sont accessibles via endpoints séparés.

---

### Order
- DTO Java (`OrderDTO`) — champs clés:
  - `UUID id`, `String orderNumber`
  - `UUID patientId`, `String patientName`
  - `UUID pharmacyId`, `String pharmacyName`
  - `BigDecimal totalAmount`, `OrderStatus status`
  - `String deliveryAddress`, `deliveryCity`, `deliveryPhone`
  - `LocalDateTime created`
  - `List<OrderItemDTO> items`
- Modèle Dart (`Order`):
  - `id`, `patientId`, `pharmacyId`, `status` (enum local), `items`, `totalAmount`, `createdAt`, `updatedAt`

Différences / risques:
- DTO utilise `created` tandis que Dart attend `createdAt`/`created`; Dart gère alias `created` dans parsing.
- DTO contient `patientName` / `pharmacyName` / delivery address/phone — non présents dans Dart.

Recommandation:
- Si l'UI montre `patientName`/`pharmacyName`, ajouter les champs ou extraire depuis endpoint `User`/`Pharmacy`.

---

### Medication
- DTO Java (`MedicationDTO`): `id`, `name`, `genericName`, `TherapeuticClass`, `description`, `dosage`, `photoUrl`, `noticePdfUrl`, `requiresPrescription`
- Modèle Dart (`Medication`): `id`, `name`, `genericName`, `therapeuticClass`, `description`, `price`, `requiresPrescription`, `createdAt`, `updatedAt`

Différences / risques:
- Backend expose `photoUrl`/`noticePdfUrl` — Dart may reference `photoUrl` but the current model expects `price`/timestamps not present in DTO.

Recommandation:
- Harmoniser: either backend include `price`/timestamps or Dart stop expecting them for base DTO; add `photoUrl` alias handling.

---

### Pharmacy
- DTO Java (`PharmacyDTO`): many fields including `id`, `userId`, `ownerFirstName/LastName`, `name`, `licenseNumber`, `address`, `city`, `phone`, `latitude`/`longitude` (BigDecimal), `description`, `openingHours`, `averageRating` (Double), `ratingCount` (Integer), `status`, `licenseDocumentUrl`, `validatedAt`, `createdAt`, `updatedAt`
- Modèle Dart (`Pharmacy`): `id`, `name`, `address`, `city`, `phone`, `latitude`, `longitude`, `licenseNumber?`, `status`, `createdAt`, `updatedAt` and nested `PharmacyMedicationInventory` etc.

Différences / risques:
- DTO exposes owner fields (`ownerFirstName/LastName`) and `averageRating`/`ratingCount` — Dart has `averageRating` handling? (Dart `Pharmacy` has `averageRating` in Java but check model). Dart handles some fields; verify mapping for `validatedAt` and `licenseDocumentUrl`.

Recommandation:
- Add missing aliases in Dart where UI needs them (owner names, license URL).

---

### Notification
- DTO Java (`NotificationDTO`): `UUID id`, `String title`, `String message`, `NotificationType type`, `Boolean isRead`, `LocalDateTime createdAt`
- Modèle Dart (`NotificationDTO`): `id`, `title`, `message`, `createdAt`, `isRead`, `type`, `referenceId`

Différences / risques:
- DTO uses enum `NotificationType` — Dart stores type String, which is acceptable.
- DTO doesn't include `referenceId` in the DTO shown — Dart already tolerates null.

Recommandation:
- None urgent; keep `type` as string, ensure backend includes `referenceId` when relevant.

---

### Review / Prescription
- DTO Java (`ReviewDTO`) fields differ from Dart's simpler model (Java includes pharmacy/courier specific ratings and comments, plus `status`).
- `PrescriptionDTO` Java uses `photoUrl`, `status`, `pharmacistComment`, `createdAt`, `orderId`.

Différences / risques:
- Dart `Review` expects `patientId`/`pharmacyId`/`rating`/`comment` — Java `ReviewDTO` uses different naming (`pharmacyRating`, `courierRating`, etc.).

Recommandation:
- Adapter Dart `Review.fromJson` to extract `pharmacyRating`/`courierRating` appropriately (already partially hardened). Consider server-side unified `rating`/`comment` fields for list endpoints.

---

### Payment / Payout
- DTO Java (`PaymentRequestDTO`, `CreatePayoutDTO`) show types: UUIDs, List<UUID> orderIds, PaymentMethod enum, phoneNumber, BigDecimal amount, transactionReference, method, notes.
- Dart `Payment` and `Payout` models expect `orderId`, `amount`, `method`, `status`, `transactionReference`, `bankAccount` etc.

Différences / risques:
- `PaymentRequestDTO` uses `orderIds` (list) vs Dart often uses single `orderId` in model; endpoints may accept lists — front should support both or use dedicated request DTO.

Recommandation:
- Ensure client uses correct request shapes for create-payment and create-payout endpoints (list vs single). Add client wrappers when necessary.

---

## Statistiques
- DTOs pour stats: `DeliveryStatsDTO` (completedDeliveries, failedDeliveries, ongoingDeliveries, averageDeliveryTimeMinutes, successRate) et `GlobalStatsDTO` (totalOrders, pendingOrders, totalRevenue, activePharmacies, totalPatients).
- Front a `DeliveryStats` model avec `totalDeliveries`, `completedDeliveries`, `ongoingDeliveries`, `totalEarnings` — **mismatch**: backend `DeliveryStatsDTO` uses `averageDeliveryTimeMinutes` and `successRate`; front expects `totalDeliveries` et `totalEarnings`.

Impact:
- Les endpoints statistiques ne s'alignent pas totalement avec l'objet attendu par l'UI. Il faut adapter soit l'API soit le front pour que les métriques affichées correspondent.

Recommandation:
- Clarifier quelles métriques UI doit afficher. Adapter front pour consommer `DeliveryStatsDTO` (ajouter champs `averageDeliveryTimeMinutes` et `successRate`) et/or backend pour exposer `totalEarnings` si nécessaire.

---

## Synthèse & Priorités
1. Corriger le backend 500 (dépendance mail) pour permettre tests d'intégration. Sans cela, difficile de valider dynamiquement.
2. Harmoniser les DTO suivants (critical pour UI): `DeliveryDTO` (ajouter coords/contact si affichés), `DeliveryStatsDTO` ↔ `DeliveryStats` (aligner métriques), `ReviewDTO` ↔ `Review` (unifier noms de champs pour listes vs détails).
3. Pour les champs d'identifiants: UUID → String mapping est déjà géré par Dart (les `safeString`), garder cette convention.
4. Endpoint shape differences (flat vs nested objects): front already tolérant mais documenter API shape or update backend to embed nested objects where useful.

---

## Actions recommandées (rapides)
- Backend: ajouter `spring-boot-starter-mail` dependency et corriger compilation. Ajouter `@JsonAlias` ou `@JsonProperty` sur DTO fields là où noms alternatifs existent (ex: `@JsonAlias({"id","deliveryId"})`).
- Front: ajouter quelques champs manquants au modèle `Delivery` (coords, deliveryAddress) et adapter `DeliveryStats` pour accepter `averageDeliveryTimeMinutes`/`successRate`.
- Tests: générer tests unitaires de désérialisation pour chaque DTO important (`Delivery`, `Order`, `Payment`, `Review`, `Notification`).

---

## Propositions de suites
- (A) Générer un patch backend minimal (pom/gradle + JsonAlias + date format) — PR prête.
- (B) Générer et committer les changements front recommandés (ajout champs Delivery/Stats + tests unitaires de désérialisation).
- (C) Lancer une passe de tests unitaires Flutter pour valider les parsing (nécessite Flutter installé localement).

Choisis A/B/C et j'exécute.
