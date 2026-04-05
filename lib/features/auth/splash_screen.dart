import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:saaspos/core/providers/providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check initial state after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider).value;
      if (authState != null) {
        if (authState.session != null) {
          _checkOnboarding(context, authState.session!.user.id);
        } else {
          context.go('/welcome');
        }
      }
    });

    // Also listen for changes
    ref.listen(authStateProvider, (previous, next) {
      final authState = next.value;
      if (authState != null) {
        if (authState.session != null) {
          _checkOnboarding(context, authState.session!.user.id);
        } else {
          context.go('/welcome');
        }
      }
    });

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _checkOnboarding(BuildContext context, String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.from('profiles').select('business_id').eq('id', userId).maybeSingle();

      if (response == null || response['business_id'] == null) {
        if (context.mounted) context.go('/onboarding');
      } else {
        if (context.mounted) context.go('/dashboard');
      }
    } catch (e) {
      debugPrint('Splash Redirection Error: $e');
      // If profile fails, send to welcome to try again
      if (context.mounted) context.go('/welcome');
    }
  }
}
