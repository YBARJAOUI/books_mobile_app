# Bookstore Backoffice - Flutter Application

Une application Flutter de back-office pour la gestion d'une librairie.

## Fonctionnalités

### 📚 Gestion des Livres
- ✅ CRUD complet (Créer, Lire, Mettre à jour, Supprimer)
- ✅ Recherche par titre, auteur ou ISBN
- ✅ Gestion des catégories et langues
- ✅ Gestion du stock et disponibilité
- ✅ Support des images en base64

### 👥 Gestion des Clients
- ✅ CRUD complet des clients
- ✅ Recherche par nom, email ou téléphone
- ✅ Gestion du statut actif/inactif
- ✅ Informations complètes (adresse, ville, pays, etc.)

### 🛒 Gestion des Commandes
- ✅ Visualisation de toutes les commandes
- ✅ Filtrage par statut
- ✅ Mise à jour du statut des commandes
- ✅ Détails complets (articles, client, adresse)
- ✅ Gestion des statuts de paiement

### 📦 Gestion des Packs
- ✅ CRUD complet des packs de livres
- ✅ Gestion des prix et stock
- ✅ Statut actif/inactif et vedette
- ✅ Support des images

### 🎯 Offres du Jour
- ✅ CRUD complet des offres spéciales
- ✅ Gestion des prix et remises
- ✅ Périodes de validité
- ✅ Quantités limitées
- ✅ Calcul automatique des pourcentages

## Architecture

L'application suit une architecture claire et modulaire :

```
lib/
├── models/          # Modèles de données
├── services/        # Services API
├── screens/         # Écrans de l'application
├── providers/       # Gestion d'état (Provider pattern)
├── widgets/         # Composants réutilisables
└── utils/          # Utilitaires
```

## Installation

### Prérequis
- Flutter SDK (version 3.7.2 ou plus)
- Dart SDK
- Backend API fonctionnel sur `http://localhost:8080`

### Étapes

1. **Installer les dépendances :**
   ```bash
   flutter pub get
   ```

2. **Vérifier l'installation :**
   ```bash
   flutter analyze
   ```

3. **Lancer l'application :**
   ```bash
   flutter run
   ```

## Configuration

### Configuration de l'API

L'URL de l'API est configurée dans `lib/services/api_service.dart` :

```dart
static const String baseUrl = 'http://localhost:8080/api';
```

Modifiez cette URL selon votre configuration backend.

## Utilisation

### Navigation
L'application utilise une navigation rail sur la gauche avec les sections :
- 🏠 **Tableau de bord** : Vue d'ensemble
- 📚 **Livres** : Gestion du catalogue
- 👥 **Clients** : Gestion de la clientèle
- 🛒 **Commandes** : Gestion des ventes
- 📦 **Packs** : Gestion des offres groupées
- 🎯 **Offres du jour** : Promotions spéciales

### Fonctionnalités clés
- **Recherche en temps réel** dans toutes les sections
- **Formulaires de création/édition** intuitifs
- **Validation des données** côté client
- **Interface responsive** et moderne
- **Gestion d'erreurs** avec messages utilisateur

## Dépendances principales

- `provider` : Gestion d'état
- `http` : Communication API
- `intl` : Internationalization
- `shared_preferences` : Stockage local
- `image_picker` : Sélection d'images
- `cached_network_image` : Cache d'images
- `flutter_staggered_grid_view` : Grilles flexibles

## Structure des données

L'application gère les entités suivantes, synchronisées avec le backend Spring Boot :

- **Book** : Livres avec ISBN, titre, auteur, prix, stock
- **Customer** : Clients avec informations complètes
- **Order** : Commandes avec statuts et articles  
- **OrderItem** : Articles de commande
- **Pack** : Packs de livres avec prix groupés
- **DailyOffer** : Offres spéciales avec périodes et remises
