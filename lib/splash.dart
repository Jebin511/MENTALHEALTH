import 'package:feelings/home.dart';
import 'package:feelings/loginpage.dart';
import 'package:feelings/main.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Run the redirect logic after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirect();
    });
  }

  Future<void> _redirect() async {
    // await a short delay to show the splash screen
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) {
      return;
    }

    final session = supabase.auth.currentSession;

    if (session != null) {
      // If user is logged in, go to Home page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } else {
      // If user is not logged in, go to Login page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}