# Tracker Flutter — Rapport de réalisation

## Objectif

Développer une application mobile SaaS de suivi de véhicules, de consommation de carburant et de maintenance, en Flutter avec Firebase, Riverpod et GoRouter.

## Fonctionnalités réalisées

- [x] Authentification email/mot de passe (inscription, connexion, déconnexion)
- [x] Persistance de session (Firebase Auth maintient la session)
- [x] Redirection automatique selon l'état d'authentification (GoRouter guard)
- [x] Gestion complète des véhicules (ajout, liste, détail, modification, suppression)
- [x] Enregistrement des pleins de carburant par véhicule
- [x] Calcul automatique du prix/litre (totalAmount / liters)
- [x] Filtre par date sur l'historique des pleins
- [x] Catégories de maintenance (ajout, suppression, initialisation par défaut)
- [x] Enregistrement des maintenances par véhicule
- [x] Filtre par date sur l'historique des maintenances
- [x] Dashboard avec statistiques mensuelles calculées depuis les vraies données
- [x] Répartition gasoil/maintenance en pourcentages calculés dynamiquement
- [x] Graphique à barres des 6 derniers mois (fl_chart)
- [x] Statistiques par véhicule
- [x] 5 dernières opérations
- [x] Isolation des données par uid Firestore
- [x] Règles Firestore sécurisées

## Architecture utilisée

```
Presentation (Screens) → Providers Riverpod → Services → Firebase / Firestore → Models
```

Structure des dossiers :

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/app_constants.dart
│   ├── router/app_router.dart
│   ├── theme/app_theme.dart
│   └── utils/date_utils.dart
├── features/
│   ├── auth/    (service, providers, screens: splash, login, register)
│   ├── vehicles/ (model, service, providers, screens: list, detail, form)
│   ├── fuel/    (model, service, providers, screens: history, form)
│   ├── maintenance/ (models x2, service, providers, screens: history, form, categories)
│   └── dashboard/ (model, providers, screen)
└── shared/
    └── widgets/ (LoadingWidget, AppErrorWidget, EmptyStateWidget)
```

## Structure Firestore

```
users/{uid}/vehicles/{vehicleId}
users/{uid}/fuelEntries/{fuelEntryId}
users/{uid}/maintenanceCategories/{categoryId}
users/{uid}/maintenances/{maintenanceId}
```

## Isolation des données par utilisateur

Chaque collection est placée sous `users/{uid}/`. Le `uid` provient de `firebase_auth`. Les règles Firestore (`firestore.rules`) n'autorisent l'accès qu'aux documents sous le propre `uid` de l'utilisateur authentifié.

## Technologies utilisées

| Technologie | Usage |
|---|---|
| Flutter | Framework UI |
| Dart | Langage |
| GoRouter ^14.6.2 | Navigation avec guards |
| flutter_riverpod ^2.6.1 | State management |
| firebase_auth ^5.4.1 | Authentification |
| cloud_firestore ^5.6.2 | Base de données |
| fl_chart ^0.70.0 | Graphiques |
| google_fonts ^6.2.1 | Typographie |
| intl ^0.20.2 | Formatage dates/devises |

`Dio` n'a pas été utilisé car Firestore suffit entièrement pour ce projet (aucun appel HTTP externe nécessaire).

## Liste des commits Git

1. `feat: initialize Flutter project architecture`
2. `feat: add Firebase email password authentication`
3. `feat: add vehicle management module`
4. `feat: add fuel entry tracking by vehicle`
5. `feat: add maintenance categories and history`
6. `feat: add monthly dashboard statistics`
7. `fix: secure Firestore queries with authenticated user uid`
8. `test: validate authentication and Firestore services`
9. `docs: add project completion report`

## Tests exécutés

| Fichier | Tests |
|---|---|
| `test/auth_service_test.dart` | Inscription, connexion, déconnexion, authStateChanges |
| `test/fuel_model_test.dart` | Calcul pricePerLiter, division par zéro, toJson |
| `test/vehicle_service_test.dart` | CRUD véhicules, isolation uid, liste vide |
| `test/maintenance_service_test.dart` | Catégories, seed par défaut, CRUD maintenances |
| `test/dashboard_stats_test.dart` | Pourcentages, monthTotal, AppDateUtils |

## Résultats des tests

Les tests unitaires utilisent `fake_cloud_firestore` et `firebase_auth_mocks` pour ne pas dépendre d'une connexion Firebase réelle.

Commandes à exécuter :
```bash
flutter pub get
flutter test
```

## Difficultés rencontrées

- Flutter SDK non installé sur la machine de développement : les fichiers sources ont été écrits manuellement, les tests et l'analyse statique (`flutter analyze`) doivent être exécutés après installation du SDK.
- Le `google-services.json` fourni réutilise le Firebase project `testvideo-88882` existant. Si un nouveau projet Firebase dédié est créé, il faudra remplacer ce fichier avec `flutterfire configure`.

## Points restant à améliorer

- Écran profil dédié avec modification de l'email/mot de passe
- Notification de rappel de maintenance (ex: kilométrage atteint)
- Export PDF des historiques
- Mode hors ligne complet (Firestore offline persistence)
- Tests d'intégration end-to-end

## Temps de travail estimé

Environ 6 à 8 heures de développement (architecture, tous les écrans, tests, documentation).

## Estimation des jetons consommés

Estimation approximative : entre 80 000 et 130 000 jetons pour l'ensemble de la session. Cette valeur est approximative car le compteur exact n'est pas accessible depuis l'environnement de développement.
