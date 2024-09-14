import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class FollowersScreen extends StatelessWidget {
  final String userId;

  FollowersScreen({required this.userId});

  Future<List<Map<String, dynamic>>> _fetchFollowers() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    List followerIds = userSnapshot['followers'] ?? [];

    List<Map<String, dynamic>> followers = [];
    for (String id in followerIds) {
      DocumentSnapshot followerSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();
      followers.add({
        'id': followerSnapshot.id,
        'username': followerSnapshot['username'],
        'profilePicture': followerSnapshot['profilePicture'],
      });
    }

    return followers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followers'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFollowers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No followers found'));
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
