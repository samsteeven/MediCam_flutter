-- Script de nettoyage des doublons de médicaments
-- À exécuter sur la base de données pour éliminer les entrées dupliquées

-- 1. Identifier et supprimer les doublons de médicaments
-- Garder le plus récent et supprimer les anciens
DELETE FROM medications m
WHERE id IN (
    SELECT id FROM (
        SELECT id,
               ROW_NUMBER() OVER (
                   PARTITION BY name, dosage 
                   ORDER BY updated_at DESC
               ) as rn
        FROM medications
    ) ranked
    WHERE rn > 1
);

-- 2. Nettoyer la table pharmacy_medications (inventaire par pharmacie)
-- Garder le plus récent pour chaque combinaison (pharmacy_id, medication_id)
DELETE FROM pharmacy_medications pm
WHERE id NOT IN (
    SELECT id FROM (
        SELECT id,
               ROW_NUMBER() OVER (
                   PARTITION BY pharmacy_id, medication_id 
                   ORDER BY updated_at DESC
               ) as rn
        FROM pharmacy_medications
    ) ranked
    WHERE rn = 1
);

-- 3. Valider l'intégrité des données
-- Supprimer les entrées avec données invalides (prix négatif, quantité négative, nom vide)
DELETE FROM pharmacy_medications
WHERE price < 0 OR quantity_in_stock < 0;

DELETE FROM medications
WHERE name IS NULL OR name = '' OR TRIM(name) = '';

-- 4. Vérifier les résultats
SELECT '=== VÉRIFICATION ===' as check_type;
SELECT COUNT(*) as total_medications FROM medications;
SELECT COUNT(*) as total_inventory_entries FROM pharmacy_medications;
SELECT COUNT(DISTINCT medication_id, pharmacy_id) as unique_entries FROM pharmacy_medications;

-- 5. Afficher les statistiques par pharmacie
SELECT 
    p.id,
    p.name,
    COUNT(pm.medication_id) as total_medications,
    SUM(CASE WHEN pm.quantity_in_stock > 0 THEN 1 ELSE 0 END) as in_stock,
    SUM(CASE WHEN pm.quantity_in_stock <= 0 THEN 1 ELSE 0 END) as out_of_stock
FROM pharmacies p
LEFT JOIN pharmacy_medications pm ON p.id = pm.pharmacy_id
GROUP BY p.id, p.name
ORDER BY p.name;
