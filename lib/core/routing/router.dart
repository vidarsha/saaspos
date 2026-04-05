import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:saaspos/features/auth/welcome_screen.dart';
import 'package:saaspos/features/auth/splash_screen.dart';
import 'package:saaspos/features/auth/login_screen.dart';
import 'package:saaspos/features/auth/signup_screen.dart';
import 'package:saaspos/features/onboarding/business_setup_wizard.dart';
import 'package:saaspos/core/widgets/main_scaffold.dart';
import 'package:saaspos/features/dashboard/dashboard_screen.dart';
import 'package:saaspos/features/settings/settings_screen.dart';
import 'package:saaspos/features/products/products_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/splash',
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const BusinessSetupWizard(),
    ),
    
    // Shell Route for Dashboard & Modules
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/pos',
          builder: (context, state) => const PlaceholderScreen('POS Terminal'),
        ),
        GoRoute(
          path: '/products',
          builder: (context, state) => const ProductsScreen(),
        ),
        GoRoute(
          path: '/orders',
          builder: (context, state) => const PlaceholderScreen('Orders & Transactions'),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const PlaceholderScreen('Customers'),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const PlaceholderScreen('Reports & Analytics'),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

// Placeholder for other screens
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.construction_rounded, size: 64, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 8),
          Text(
            'This module is coming soon.',
            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
