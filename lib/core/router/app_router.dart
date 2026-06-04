import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/fuel/screens/fuel_form_screen.dart';
import '../../features/fuel/screens/fuel_history_screen.dart';
import '../../features/maintenance/screens/category_list_screen.dart';
import '../../features/maintenance/screens/maintenance_form_screen.dart';
import '../../features/maintenance/screens/maintenance_history_screen.dart';
import '../../features/vehicles/screens/vehicle_detail_screen.dart';
import '../../features/vehicles/screens/vehicle_form_screen.dart';
import '../../features/vehicles/screens/vehicle_list_screen.dart';

// Named routes
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const vehicles = '/vehicles';
  static const vehicleAdd = '/vehicles/add';
  static const vehicleEdit = '/vehicles/edit/:vehicleId';
  static const vehicleDetail = '/vehicles/:vehicleId';
  static const fuelAdd = '/vehicles/:vehicleId/fuel/add';
  static const fuelHistory = '/vehicles/:vehicleId/fuel';
  static const maintenanceAdd = '/vehicles/:vehicleId/maintenance/add';
  static const maintenanceHistory = '/vehicles/:vehicleId/maintenance';
  static const categories = '/categories';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoading = authState.isLoading;
      final location = state.uri.path;

      if (isLoading) return AppRoutes.splash;

      final publicRoutes = [AppRoutes.login, AppRoutes.register, AppRoutes.splash];
      final isPublic = publicRoutes.contains(location);

      if (!isLoggedIn && !isPublic) return AppRoutes.login;
      if (isLoggedIn && isPublic && location != AppRoutes.splash) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.vehicles,
        builder: (context, state) => const VehicleListScreen(),
      ),
      GoRoute(
        path: AppRoutes.vehicleAdd,
        builder: (context, state) => const VehicleFormScreen(),
      ),
      GoRoute(
        path: AppRoutes.vehicleEdit,
        builder: (context, state) => VehicleFormScreen(
          vehicleId: state.pathParameters['vehicleId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.vehicleDetail,
        builder: (context, state) => VehicleDetailScreen(
          vehicleId: state.pathParameters['vehicleId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.fuelAdd,
        builder: (context, state) => FuelFormScreen(
          vehicleId: state.pathParameters['vehicleId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.fuelHistory,
        builder: (context, state) => FuelHistoryScreen(
          vehicleId: state.pathParameters['vehicleId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.maintenanceAdd,
        builder: (context, state) => MaintenanceFormScreen(
          vehicleId: state.pathParameters['vehicleId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.maintenanceHistory,
        builder: (context, state) => MaintenanceHistoryScreen(
          vehicleId: state.pathParameters['vehicleId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoryListScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page introuvable: ${state.uri}')),
    ),
  );
});
