import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/biometric_provider.dart';
import 'providers/language_provider.dart';
import 'providers/location_provider.dart';
import 'providers/saved_locations_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/add_maintenance_screen.dart';
import 'screens/add_vehicle_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/edit_vehicle_screen.dart';
import 'screens/emergency_contacts_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/maintenance_detail_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/nearby_services_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/saved_locations_screen.dart';
import 'screens/service_history_screen.dart';
import 'screens/services_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/vehicle_management_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const DriverAssistApp());
}

class DriverAssistApp extends StatelessWidget {
  const DriverAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => BiometricProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SavedLocationsProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            home: const SplashScreen(),
            routes: {
              AppRoutes.splash: (_) => const SplashScreen(),
              AppRoutes.onboarding: (_) => const OnboardingScreen(),
              AppRoutes.login: (_) => const LoginScreen(),
              AppRoutes.register: (_) => const RegisterScreen(),
              AppRoutes.home: (_) => const MainNavigationScreen(),
              AppRoutes.profile: (_) => const ProfileScreen(),
              AppRoutes.services: (_) => const ServicesScreen(),
              AppRoutes.emergency: (_) => const EmergencyScreen(),
              AppRoutes.settings: (_) => const SettingsScreen(),
              AppRoutes.changePassword: (_) => const ChangePasswordScreen(),
              AppRoutes.vehicleManagement: (_) =>
                  const VehicleManagementScreen(),
              AppRoutes.addVehicle: (_) => const AddVehicleScreen(),
              AppRoutes.editVehicle: (_) => const EditVehicleScreen(),
              AppRoutes.maintenance: (_) => const MaintenanceScreen(),
              AppRoutes.addMaintenance: (_) => const AddMaintenanceScreen(),
              AppRoutes.maintenanceDetail: (_) =>
                  const MaintenanceDetailScreen(),
              AppRoutes.serviceHistory: (_) => const ServiceHistoryScreen(),
              AppRoutes.savedLocations: (_) => const SavedLocationsScreen(),
              AppRoutes.chat: (_) => const ChatScreen(),
              AppRoutes.notifications: (_) => const NotificationsScreen(),
              AppRoutes.emergencyContacts: (_) =>
                  const EmergencyContactsScreen(),
              AppRoutes.nearbyServices: (_) => const NearbyServicesScreen(),
            },
            onUnknownRoute: (_) => MaterialPageRoute(
              settings: const RouteSettings(name: AppRoutes.splash),
              builder: (_) => const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
