import 'package:feelings/colors.dart';
import 'package:feelings/splash.dart' show SplashPage;
 // Import the new splash page
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://jhsyybjsdztleswsfmlk.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impoc3l5YmpzZHp0bGVzd3NmbWxrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM2MjYzNTQsImV4cCI6MjA2OTIwMjM1NH0.v5i7rADhJJciXDg9_BN48DqIsH9UXChz_vvKJ-B8ZQM';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FeelFree App',
      theme: mentalHealthTheme,
      home: const SplashPage(), // ✅ Use SplashPage as the starting point
    ),
  );
}

// Helper to access the Supabase client from anywhere in the app
final supabase = Supabase.instance.client;