class AppConstants {
  // Firestore collections
  static const String usersCollection = 'users';
  static const String vehiclesCollection = 'vehicles';
  static const String fuelEntriesCollection = 'fuelEntries';
  static const String maintenanceCategoriesCollection = 'maintenanceCategories';
  static const String maintenancesCollection = 'maintenances';

  // Default maintenance categories
  static const List<String> defaultCategories = [
    'Vidange',
    'Freinage',
    'Pneus',
    'Révision générale',
    'Réparation moteur',
    'Assurance',
    'Autre',
  ];
}
