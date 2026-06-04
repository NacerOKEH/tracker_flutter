import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            context.go(AppRoutes.dashboard);
          } else {
            context.go(AppRoutes.login);
          }
        },
        loading: () {},
        error: (_, __) => context.go(AppRoutes.login),
      );
    });

    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Tracker Véhicules',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
