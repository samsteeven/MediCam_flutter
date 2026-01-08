# Guide de la partie Web d'administration

## Objectif

La partie web d'administration permet aux pharmaciens et administrateurs de:
- Gérer les pharmacies et leurs détails
- Gérer l'inventaire des médicaments
- Consulter les commandes et statistiques
- Gérer les utilisateurs

## Architecture recommandée

### Stack technologique

**Frontend:**
- React.js ou Vue.js
- TypeScript
- Material-UI ou Ant Design pour l'UI
- Redux/Vuex pour la gestion d'état
- Axios pour les appels API

**Backend:**
- Déjà existant (endpoints API)
- Base de données commune avec Flutter

### Structure de dossiers

```
easypharma-web/
├── public/
├── src/
│   ├── components/
│   │   ├── common/
│   │   │   ├── Header.tsx
│   │   │   ├── Sidebar.tsx
│   │   │   └── Footer.tsx
│   │   ├── pharmacy/
│   │   │   ├── PharmacyList.tsx
│   │   │   ├── PharmacyForm.tsx
│   │   │   └── PharmacyDetails.tsx
│   │   ├── medications/
│   │   │   ├── MedicationList.tsx
│   │   │   ├── MedicationForm.tsx
│   │   │   └── InventoryManager.tsx
│   │   ├── orders/
│   │   │   ├── OrderList.tsx
│   │   │   ├── OrderDetails.tsx
│   │   │   └── OrderStatus.tsx
│   │   └── dashboard/
│   │       ├── Dashboard.tsx
│   │       ├── Statistics.tsx
│   │       └── Charts.tsx
│   ├── pages/
│   │   ├── LoginPage.tsx
│   │   ├── DashboardPage.tsx
│   │   ├── PharmaciesPage.tsx
│   │   ├── MedicationsPage.tsx
│   │   ├── OrdersPage.tsx
│   │   └── SettingsPage.tsx
│   ├── services/
│   │   ├── api.ts
│   │   ├── pharmacyService.ts
│   │   ├── medicationService.ts
│   │   ├── orderService.ts
│   │   └── authService.ts
│   ├── store/
│   │   ├── auth.ts
│   │   ├── pharmacy.ts
│   │   ├── medications.ts
│   │   └── orders.ts
│   ├── styles/
│   │   ├── global.css
│   │   └── theme.ts
│   ├── App.tsx
│   └── index.tsx
└── package.json
```

---

## Pages principales

### 1. **Dashboard** (`/dashboard`)

Affiche:
- Nombre total de commandes
- Chiffre d'affaires
- Médicaments les plus vendus
- Dernières commandes
- Graphiques de tendances

```tsx
// Exemple de composant
function Dashboard() {
  const [stats, setStats] = useState(null);
  
  useEffect(() => {
    apiService.get('/statistics').then(setStats);
  }, []);
  
  return (
    <Container>
      <Row>
        <Card title="Commandes" value={stats?.totalOrders} />
        <Card title="Chiffre d'affaires" value={`${stats?.totalRevenue} FCFA`} />
      </Row>
      <ChartComponent data={stats?.chartData} />
    </Container>
  );
}
```

### 2. **Gestion des Pharmacies** (`/pharmacies`)

**Liste:**
- Tableau avec nom, adresse, téléphone, statut
- Filtres: ville, statut
- Actions: Voir détails, Éditer, Activer/Suspendre

**Détails:**
- Informations de la pharmacie
- Licence médicale
- Informations géographiques
- Inventaire des médicaments
- Historique des commandes

```tsx
function PharmacyList() {
  const [pharmacies, setPharmacies] = useState([]);
  
  useEffect(() => {
    apiService.get('/pharmacies').then(setPharmacies);
  }, []);
  
  const handleStatusChange = (id, status) => {
    apiService.put(`/pharmacies/${id}/status`, { status });
  };
  
  return (
    <Table
      columns={['Nom', 'Ville', 'Statut', 'Actions']}
      data={pharmacies}
      actions={{
        edit: handleEdit,
        suspend: handleStatusChange,
      }}
    />
  );
}
```

### 3. **Gestion des Médicaments** (`/medications`)

**Catalogue global:**
- Liste de tous les médicaments
- Ajouter/Éditer/Supprimer
- Chercher par nom ou classe thérapeutique

**Inventaire par pharmacie:**
- Tableau: Médicament, Prix, Stock, Actions
- Éditer prix/stock en ligne
- Ajouter/Retirer médicaments
- Voir l'historique de stock

```tsx
function InventoryManager({ pharmacyId }) {
  const [inventory, setInventory] = useState([]);
  const [medications, setMedications] = useState([]);
  
  useEffect(() => {
    apiService.get(`/pharmacies/${pharmacyId}/medications`)
      .then(setInventory);
    apiService.get('/medications').then(setMedications);
  }, [pharmacyId]);
  
  const handleAddMedication = (medicationId, price, quantity) => {
    apiService.post(
      `/pharmacies/${pharmacyId}/medications/${medicationId}`,
      { price, quantityInStock: quantity }
    ).then(() => refetch());
  };
  
  return (
    <div>
      <InventoryTable data={inventory} />
      <AddMedicationDialog />
    </div>
  );
}
```

### 4. **Gestion des Commandes** (`/orders`)

**Liste:**
- Filtres: Statut, Date, Pharmacie
- Tableau: ID, Date, Patient, Statut, Montant
- Actions: Voir détails, Changer statut

**Détails:**
- Liste des articles
- Information patient
- Historique des changements de statut

```tsx
function OrderList() {
  const [orders, setOrders] = useState([]);
  const [filters, setFilters] = useState({});
  
  const handleFilterChange = (newFilters) => {
    setFilters(newFilters);
    apiService.get('/orders', { params: newFilters })
      .then(setOrders);
  };
  
  return (
    <div>
      <FilterBar onChange={handleFilterChange} />
      <OrderTable data={orders} />
    </div>
  );
}
```

---

## Implémentation de l'API

### Service API (`src/services/api.ts`)

```typescript
import axios from 'axios';

const API_URL = 'http://localhost:8080/api/v1';

const api = axios.create({
  baseURL: API_URL,
});

// Intercepteur pour l'authentification
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Intercepteur pour les erreurs
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Rediriger vers login
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
```

### Service Pharmacies (`src/services/pharmacyService.ts`)

```typescript
import api from './api';

export const pharmacyService = {
  getAll: (filters?: any) => 
    api.get('/pharmacies', { params: filters }),
  
  getById: (id: string) => 
    api.get(`/pharmacies/${id}`),
  
  updateStatus: (id: string, status: string) => 
    api.put(`/pharmacies/${id}/status`, { status }),
  
  getInventory: (pharmacyId: string) => 
    api.get(`/pharmacies/${pharmacyId}/medications`),
  
  addMedication: (
    pharmacyId: string,
    medicationId: string,
    price: number,
    quantityInStock: number
  ) => 
    api.post(
      `/pharmacies/${pharmacyId}/medications/${medicationId}`,
      { price, quantityInStock }
    ),
  
  updateMedication: (
    pharmacyId: string,
    medicationId: string,
    price?: number,
    quantityInStock?: number
  ) => 
    api.put(
      `/pharmacies/${pharmacyId}/medications/${medicationId}`,
      { price, quantityInStock }
    ),
  
  removeMedication: (pharmacyId: string, medicationId: string) => 
    api.delete(`/pharmacies/${pharmacyId}/medications/${medicationId}`),
};
```

---

## Authentification

### Flow de login

```tsx
function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  
  const handleLogin = async () => {
    try {
      const response = await api.post('/auth/login', {
        email,
        password,
      });
      
      // Sauvegarder le token
      localStorage.setItem('token', response.data.token);
      localStorage.setItem('user', JSON.stringify(response.data.user));
      
      // Rediriger
      navigate('/dashboard');
    } catch (error) {
      showError('Email ou mot de passe incorrect');
    }
  };
  
  return (
    <LoginForm onSubmit={handleLogin} />
  );
}
```

---

## Dashboard et Statistiques

### Requête statistiques

```typescript
// GET /api/v1/pharmacies/:id/statistics
// Retourne les stats d'une pharmacie
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
  ]
}
```

### Composant de graphique

```tsx
function SalesChart({ data }) {
  return (
    <LineChart
      data={data}
      margin={{ top: 5, right: 30, left: 0, bottom: 5 }}
    >
      <CartesianGrid strokeDasharray="3 3" />
      <XAxis dataKey="date" />
      <YAxis />
      <Tooltip />
      <Line type="monotone" dataKey="revenue" stroke="#8884d8" />
    </LineChart>
  );
}
```

---

## Points de synchronisation

### Entre Flutter et Web

1. **Médicaments**: Catalogue centralisé
   - Créé/Édité via web
   - Affiché dans Flutter

2. **Inventaire**: Par pharmacie
   - Géré par web (admin/pharmacien)
   - Consulté par Flutter (patient/livreur)

3. **Commandes**: Bidirectionnel
   - Créées dans Flutter
   - Gérées dans web

4. **Utilisateurs**: Centralisé
   - Gestion des rôles dans web
   - Authentification partagée

---

## Déploiement

### Pour développement local

```bash
# Backend (Node.js + Express)
cd backend
npm install
npm run dev

# Frontend web (React)
cd easypharma-web
npm install
npm start

# Flutter
flutter run
```

### Pour production

```bash
# Build Flutter web
flutter build web

# Build React
npm run build

# Déployer sur serveur
scp -r build/* user@server:/var/www/html
```

---

## Checklist d'implémentation

- [ ] Créer le projet React
- [ ] Implémenter l'authentification
- [ ] Créer la page d'accueil/Dashboard
- [ ] Implémenter la gestion des pharmacies
- [ ] Implémenter la gestion des médicaments
- [ ] Implémenter la gestion de l'inventaire
- [ ] Implémenter la gestion des commandes
- [ ] Ajouter les statistiques/graphiques
- [ ] Tester l'intégration avec le backend
- [ ] Tester la synchronisation avec Flutter
- [ ] Déployer en production
