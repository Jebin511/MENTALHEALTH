import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Counselor data class (remains the same)
class Counselor {
  final String name;
  final String email;
  final String imageUrl;

  Counselor({required this.name, required this.email, required this.imageUrl});
}

class Counsel extends StatefulWidget {
  const Counsel({super.key});

  @override
  State<Counsel> createState() => _CounselState();
}

class _CounselState extends State<Counsel> {
  // --- MODIFIED: State variables to hold fetched and filtered data ---
  List<Counselor> _allCounselors = [];
  List<Counselor> _filteredCounselors = [];
  bool _isLoading = true; // For loading indicator
  final _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Fetch data from Supabase when the widget is first created
    _fetchCounselorsFromSupabase();
    _searchController.addListener(_filterCounselors);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// --- NEW: Fetches counselor data from the Supabase table ---
  Future<void> _fetchCounselorsFromSupabase() async {
    try {
      final response = await Supabase.instance.client.from('counsel').select();
      
      final List<Counselor> fetchedCounselors = response.map<Counselor>((data) {
        return Counselor(
          name: data['name'] ?? 'No Name',
          email: data['email'] ?? 'No Email',
          imageUrl: data['image_url'] ?? '',
        );
      }).toList();
      
      if(mounted){
        setState(() {
          _allCounselors = fetchedCounselors;
          _filteredCounselors = fetchedCounselors;
          _isLoading = false;
        });
      }
    } catch (error) {
       if(mounted){
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching counselors: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Filtering logic (remains the same)
  void _filterCounselors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCounselors = _allCounselors.where((counselor) {
        return counselor.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Email launch function (remains the same)
  Future<void> _launchEmail(BuildContext context, String email) async {
    // ... same as your original code
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect with a Counselor'),
        backgroundColor: const Color(0xFFA786DF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a counselor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // --- MODIFIED: Handle loading state ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCounselors.isEmpty
                      ? const Center(
                          child: Text(
                            'No counselors found.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredCounselors.length,
                          itemBuilder: (context, index) {
                            final counselor = _filteredCounselors[index];
                            return CounselorCard(
                              counselor: counselor,
                              onBookPressed: () =>
                                  _launchEmail(context, counselor.email),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// CounselorCard widget (remains the same)
class CounselorCard extends StatelessWidget {
  // ... same as your original code
  final Counselor counselor;
  final VoidCallback onBookPressed;

  const CounselorCard({
    super.key,
    required this.counselor,
    required this.onBookPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(counselor.imageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    counselor.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    counselor.email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onBookPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF957DAD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Book'),
            ),
          ],
        ),
      ),
    );
  }
}