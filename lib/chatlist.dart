// In chat_list_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:feelings/message.dart'; // Ensure this path is correct

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  late Future<List<Map<String, dynamic>>> _coordinatorsFuture;

  @override
  void initState() {
    super.initState();
    _coordinatorsFuture = _fetchCoordinators();
  }

  /// --- MODIFIED: Fetches users with the 'coordinator' role from the profiles table ---
  Future<List<Map<String, dynamic>>> _fetchCoordinators() async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('role', 'coordinator'); // Filter for users with the 'coordinator' role
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _openChatRoom(String coordinatorId, String coordinatorName) async {
    try {
      final roomId = await Supabase.instance.client.rpc(
        'create_chat_room',
        params: {'coordinator_id_in': coordinatorId},
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Message(
              roomId: roomId.toString(),
              recipientName: coordinatorName,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening chat: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coordinators'),
        backgroundColor: const Color(0xFFA786DF),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _coordinatorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          }
          final coordinators = snapshot.data!;
          if (coordinators.isEmpty){
             return const Center(child: Text('No coordinators found.'));
          }
          return ListView.builder(
            itemCount: coordinators.length,
            itemBuilder: (context, index) {
              final coordinator = coordinators[index];
              // Use 'full_name' which is the correct column name in your profiles table
              final coordinatorName = coordinator['full_name'] ?? 'Coordinator'; 
              
              return ListTile(
                leading: CircleAvatar(
                  child: Text(coordinatorName[0]),
                ),
                title: Text(coordinatorName),
                subtitle: const Text('Tap to chat'),
                onTap: () => _openChatRoom(
                  coordinator['id'],
                  coordinatorName,
                ),
              );
            },
          );
        },
      ),
    );
  }
}