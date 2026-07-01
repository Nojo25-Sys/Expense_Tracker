# Expense Tracker

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-FFD700?logo=hive&logoColor=black)
![Material 3](https://img.shields.io/badge/Material%203-757575?logo=materialdesign&logoColor=white)

Application Flutter de suivi de dépenses personnelles avec stockage local.

## 📋 Description

Expense Tracker est une application mobile et desktop qui permet de gérer vos dépenses quotidiennes de manière simple et efficace. Les données sont stockées localement sur votre appareil grâce à la base de données Hive.

## ✨ Fonctionnalités

### Gestion des dépenses
- ✓ **Ajout de dépenses** : Enregistrez vos dépenses avec un titre, un montant, une catégorie et une date
- ✓ **Modification** : Modifiez vos dépenses existantes
- ✓ **Suppression** : Supprimez une dépense avec confirmation
- ✓ **Liste des dépenses** : Visualisez toutes vos dépenses avec des icônes par catégorie

### Filtrage et recherche
- ✓ **Recherche** : Recherchez vos dépenses par titre ou catégorie
- ✓ **Filtrage par catégorie** : Filtrez par (Nourriture, Transport, Santé, Éducation, Loisirs, Autres)
- ✓ **Filtrage par date** : Sélectionnez une plage de dates pour filtrer vos dépenses

### Statistiques et visualisation
- ✓ **Dashboard** : Écran de statistiques avec cartes récapitulatives
- ✓ **Pie Chart** : Graphique circulaire de la répartition par catégorie
- ✓ **Line Chart** : Graphique mensuel de l'évolution des dépenses
- ✓ **Budget mensuel** : Suivi du budget avec indicateur de progression

### Export et personnalisation
- ✓ **Export CSV** : Exportez vos dépenses au format CSV
- ✓ **Mode sombre** : Thème sombre/clair avec persistance
- ✓ **Paramètres** : Écran de configuration du budget et du thème

### Stockage
- ✓ **Stockage local** : Vos données sont stockées localement sur votre appareil avec Hive

## 📸 Captures d'écran

<!-- Ajoutez vos captures d'écran ici -->
<!--
![Home Screen](screenshots/home.png)
![Dashboard](screenshots/dashboard.png)
![Dark Mode](screenshots/dark_mode.png)
![Settings](screenshots/settings.png)
-->

## 🛠️ Technologies

- **Flutter** : Framework de développement multiplateforme
- **Hive** : Base de données NoSQL légère et rapide pour le stockage local
- **fl_chart** : Bibliothèque de graphiques pour Flutter
- **intl** : Internationalisation et formatage de dates
- **csv** : Export de données au format CSV
- **share_plus** : Partage de fichiers et de texte
- **uuid** : Génération d'identifiants uniques
- **Dart** : Langage de programmation

## 📦 Installation

### Prérequis

- Flutter SDK (version 3.11.5 ou supérieure)
- Dart SDK
- Un IDE (VS Code, Android Studio, ou IntelliJ IDEA)

### Étapes d'installation

1. Clonez le repository :
```bash
git clone https://github.com/Nojo25-Sys/Expense_Tracker.git
cd expense_tracker
```

2. Installez les dépendances :
```bash
flutter pub get
```

3. Lancez l'application :
```bash
flutter run
```

## 📱 Plateformes supportées

- Android
- iOS
- Windows
- Linux
- macOS
- Web

## 🏗️ Structure du projet

```
lib/
├── main.dart                  # Point d'entrée de l'application
├── models/
│   └── expense.dart           # Modèle de données Expense
├── services/
│   ├── hive_service.dart      # Service de persistance Hive
│   ├── theme_service.dart     # Service de gestion du thème et budget
│   └── csv_service.dart       # Service d'export CSV
└── view/
    ├── home.dart              # Écran principal avec liste des dépenses
    ├── add.dart               # Écran d'ajout/modification de dépense
    ├── dashboard.dart         # Écran de statistiques et graphiques
    └── settings.dart          # Écran des paramètres
```

## 💰 Catégories de dépenses

- Nourriture
- Transport
- Santé
- Éducation
- Loisirs
- Autres

## 🎨 Interface

- **Thème** : Material Design 3 avec couleur indigo
- **Mode sombre** : Thème sombre/clair avec persistance
- **Devise** : FCFA (Franc CFA)
- **Langue** : Français

## 📊 Statistiques

- **Total des dépenses** : Somme de toutes les dépenses
- **Nombre de transactions** : Compteur de dépenses
- **Catégorie dominante** : Catégorie avec le plus de dépenses
- **Moyenne** : Montant moyen par dépense
- **Budget du mois** : Dépenses actuelles / budget mensuel
- **Progression** : Pourcentage du budget utilisé

### Tests

- **expense_test.dart** : Tests unitaires du modèle Expense
  - Création avec données valides
  - Conversion toMap/fromMap
  - Sécurité de type (int → double)
  - Round-trip conversion

Note: Les tests d'intégration HiveService nécessitent une refonte de l'architecture pour permettre le mocking de Hive. Pour l'instant, seuls les tests unitaires du modèle sont disponibles.

### Commandes utiles

```bash
# Installer les dépendances
flutter pub get

# Lancer l'application en mode développement
flutter run

# Builder pour Android
flutter build apk

# Builder pour iOS
flutter build ios

# Lancer les tests
flutter test

# Analyser le code
flutter analyze
```

## 📈 Version

**Version actuelle** : 2.3.0

### Historique des versions

- **V2.3** : Correction du thème réactif avec ValueNotifier, simplification de l'export CSV
- **V2.2** : Confirmation avant suppression, export CSV, écran Paramètres
- **V2.1** : Mode sombre, modification de dépenses, recherche, filtrage par date, graphique mensuel, budget mensuel
- **V2.0** : Dashboard avec statistiques, Pie Chart, Line Chart
- **V1.0** : Version initiale avec gestion de base des dépenses

## 📄 Licence

Ce projet est créé à des fins éducatives.

## 👨‍💻 Auteur

Projet de formation Flutter/Dart
