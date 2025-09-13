import 'package:feelings/main.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // In your SignUpPage
Future<void> _signUp() async {
  if (_nameController.text.isEmpty ||
      _emailController.text.isEmpty ||
      _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Please fill all fields'),
      backgroundColor: Colors.red,
    ));
    return;
  }
  if (_passwordController.text != _confirmPasswordController.text) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Passwords do not match'),
      backgroundColor: Colors.red,
    ));
    return;
  }
  if (_passwordController.text.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Password must be at least 6 characters long'),
      backgroundColor: Colors.red,
    ));
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Step 1: Sign the user up
    final response = await supabase.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text, // ⚡ don’t trim password
    );

    final newUser = response.user;

    // Step 2: Insert into profiles if user is created
    if (newUser != null) {
      await supabase.from('profiles').insert({
        'id': newUser.id,
        'email': _emailController.text.trim(),
        'full_name': _nameController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Success! Please check your email for a confirmation link.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  } on AuthException catch (error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
      ));
    }
  } catch (error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An unexpected error occurred: $error'.toString()), // ⚡ log error
        backgroundColor: Colors.red,
      ));
    }
  }

  if (mounted) {
    setState(() => _isLoading = false);
  }
}
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0BBE4), // Light Violet
              Color(0xFF957DAD), // Medium Violet
              Color(0xFFD291BC), // Pinkish Violet
            ],
            stops: [0.1, 0.5, 0.9],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.person_add_alt_1,
                    size: 80,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 16),
                  const Text('Create Your Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Join the Manas community today',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 48.0),
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: Color(0xFF4A4E69)),
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      prefixIcon: const Icon(Icons.person_outline,
                          color: Color(0xFF6B5B95)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Color(0xFF4A4E69)),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Color(0xFF6B5B95)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Color(0xFF4A4E69)),
                    decoration: InputDecoration(
                      hintText: 'Create a password',
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Color(0xFF6B5B95)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Color(0xFF4A4E69)),
                    decoration: InputDecoration(
                      hintText: 'Confirm your password',
                      labelText: 'Confirm Password',
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      prefixIcon: const Icon(Icons.lock_person_outlined,
                          color: Color(0xFF6B5B95)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B5B95),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.0),
                          )
                        : const Text('Sign Up',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Already have an account?",
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.8))),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}