class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String services = '/services';
  static const String emergency = '/emergency';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  static const String vehicleManagement = '/vehicle-management';
  static const String addVehicle = '/add-vehicle';
  static const String editVehicle = '/edit-vehicle';
  static const String maintenance = '/maintenance';
  static const String addMaintenance = '/add-maintenance';
  static const String maintenanceDetail = '/maintenance-detail';
  static const String serviceHistory = '/service-history';
  static const String savedLocations = '/saved-locations';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String emergencyContacts = '/emergency-contacts';
}

class AppConstants {
  static const String appName = 'DriverAssist';
  static const String onboardingKey = 'onboarding_seen';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String locationAccuracyKey = 'location_accuracy';
  static const String biometricEnabledKey = 'biometric_enabled';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String vehiclesCollection = 'vehicles';
  static const String maintenanceCollection = 'maintenance';
  static const String serviceHistoryCollection = 'service_history';
  static const String emergencyCollection = 'emergency_requests';
  static const String serviceProvidersCollection = 'service_providers';
  static const String chatCollection = 'chats';
  static const String notificationsCollection = 'notifications';

  // Maintenance priorities
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';

  // Emergency types
  static const String emergencyPolice = 'police';
  static const String emergencyAmbulance = 'ambulance';
  static const String emergencyFire = 'fire';
  static const String emergencyMechanic = 'mechanic';

  // Service provider types
  static const String providerFuelStation = 'fuel_station';
  static const String providerMechanic = 'mechanic';
  static const String providerChargingStation = 'charging_station';
  static const String providerCarWash = 'car_wash';
  static const String providerParking = 'parking';

  // Saved location types
  static const String locationHome = 'home';
  static const String locationWork = 'work';
  static const String locationOther = 'other';
}
