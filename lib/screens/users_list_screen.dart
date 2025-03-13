import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/chat_user.dart';
import '../services/analytics_service.dart';
import 'chat_screen.dart';

class UsersListScreen extends StatefulWidget {
  final String currentUserId;

  const UsersListScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.logTelaUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(title: const Text('Escolha com quem quer conversar:')),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum usuário encontrado.'));
          }

          final docs = snapshot.data!.docs;

          // Filter out the current user
          final otherUsers = docs.where((doc) => doc.id != widget.currentUserId).toList();

          if (otherUsers.isEmpty) {
            return const Center(child: Text('Nenhum outro usuário encontrado.'));
          }

          return ListView.builder(
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              final userDoc = otherUsers[index];
              final data = userDoc.data() as Map<String, dynamic>;

              final user = ChatUser(
                uid: data['uid'],
                displayName: data['displayName'] ?? 'Sem nome',
                email: data['email'] ?? 'Sem email',
                photoURL: data['photoURL'],
                lastSignIn: data['lastSignIn'] ?? Timestamp.now(),
                fcmToken: data['fcmToken'],
              );

              return ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipOval(
                    child: Image.network(
                      user.photoURL ?? '', // Use empty string if null
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Icon(Icons.person, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                title: Text('${user.displayName.split(' ').first} (${user.email})'),
                onTap: () {
                  // Navigate to chat with this user
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        currentUserId: widget.currentUserId,
                        peerUser: user,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
