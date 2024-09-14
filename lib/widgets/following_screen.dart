import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class FollowingScreen extends StatelessWidget {
  final String userId;

  FollowingScreen({required this.userId});

  Future<List<Map<String, dynamic>>> _fetchFollowing() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    List followingIds = userSnapshot['following'] ?? [];

    List<Map<String, dynamic>> followingUsers = [];
    for (String id in followingIds) {
      DocumentSnapshot followingSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();
      followingUsers.add({
        'id': followingSnapshot.id,
        'username': followingSnapshot['username'],
        'profilePicture': followingSnapshot['profilePicture'],
      });
    }

    return followingUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Following'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFollowing(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No following found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var user = snapshot.data![index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['profilePicture'] != null
                        ? NetworkImage(user['profilePicture'])
                        : null,
                  ),
                  title: Text(user['username']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(userId: user['id']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
