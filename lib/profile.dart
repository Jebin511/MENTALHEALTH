import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _userName;
  String? _userEmail;
  String _moodEmoji = ''; // State variable to hold the emoji
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndMood();
  }

  /// --- MODIFIED: Fetches both profile and the latest survey score ---
  Future<void> _fetchUserProfileAndMood() async {
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Step 1: Fetch the profile data (name and email)
      final profileData = await Supabase.instance.client
          .from('profiles')
          .select('full_name, email')
          .eq('id', user.id)
          .single();

      // Step 2: Fetch the most recent survey score
      final surveyData = await Supabase.instance.client
          .from('gad7_surveys')
          .select('total_score')
          .eq('user_id', user.id)
          .order('created_at', ascending: false) // Get the newest one first
          .limit(1) // We only need the most recent entry
          .maybeSingle(); // Use maybeSingle as the user might not have a survey yet

      if (mounted) {
        setState(() {
          _userName = profileData['full_name'];
          _userEmail = profileData['email'];
          
          // Step 3: Determine the emoji based on the score
          if (surveyData != null && surveyData['total_score'] != null) {
            final score = surveyData['total_score'] as int;
            if (score <= 4) {
              _moodEmoji = '😊'; // Minimal anxiety
            } else if (score <= 9) {
              _moodEmoji = '🙂'; // Mild anxiety
            } else if (score <= 14) {
              _moodEmoji = '😐'; // Moderate anxiety
            } else {
              _moodEmoji = '😟'; // Severe anxiety
            }
          }
          
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error fetching profile data.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    // ... this function remains the same
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    // --- MODIFIED: Row to display name and emoji ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _userName ?? 'No name found',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _moodEmoji, // Display the emoji here
                          style: const TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _userEmail ?? 'No email found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton.icon(
                      onPressed: _changePassword,
                      icon: const Icon(Icons.lock_reset),
                      label: const Text('Change Password'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}