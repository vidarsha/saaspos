import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:saaspos/core/routing/router.dart';
import 'package:saaspos/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://wnkbkpawgdgxkzbnbtve.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indua2JrcGF3Z2RneGt6Ym5idHZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyMjI2OTYsImV4cCI6MjA5MDc5ODY5Nn0.ROJw_4xracnEUPGBzpsYSbGXXTaAL5dGTYVw5fMBVfo',
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SaaS POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system, // Supports dark/light mode
      routerConfig: router,
    );
  }
}
