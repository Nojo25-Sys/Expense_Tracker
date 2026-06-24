# Expense Tracker

Application Flutter de suivi de dépenses personnelles avec stockage local.

## 📋 Description

Expense Tracker est une application mobile et desktop qui permet de gérer vos dépenses quotidiennes de manière simple et efficace. Les données sont stockées localement sur votre appareil grâce à la base de données Hive.

## ✨ Fonctionnalités

- **Ajout de dépenses** : Enregistrez vos dépenses avec un titre, un montant, une catégorie et une date
- **Liste des dépenses** : Visualisez toutes vos dépenses avec des icônes par catégorie
- **Filtrage** : Filtrez vos dépenses par catégorie (Nourriture, Transport, Santé, Éducation, Loisirs, Autres)
- **Suppression** : Supprimez une dépense par swipe ou via le bouton de suppression
- **Total des dépenses** : Affichage en temps réel du total de vos dépenses
- **Stockage local** : Vos données sont stockées localement sur votre appareil

## 🛠️ Technologies

- **Flutter** : Framework de développement multiplateforme
- **Hive** : Base de données NoSQL légère et rapide pour le stockage local
- **Dart** : Langage de programmation

## 📦 Installation

### Prérequis

- Flutter SDK (version 3.11.5 ou supérieure)
- Dart SDK
- Un IDE (VS Code, Android Studio, ou IntelliJ IDEA)

### Étapes d'installation

1. Clonez le repository :
```bash
git clone <repository-url>
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
├── main.dart              # Point d'entrée de l'application
├── models/
│   └── expense.dart       # Modèle de données Expense
├── services/
│   └── hive_service.dart  # Service de persistance Hive
└── view/
    ├── home.dart          # Écran principal avec liste des dépenses
    └── add.dart           # Écran d'ajout de dépense
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
- **Devise** : FCFA (Franc CFA)
- **Langue** : Français

## 📝 Développement

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
```

## 📄 Licence

Ce projet est créé à des fins éducatives.

## 👨‍💻 Auteur

Projet de formation Flutter/Dart
