import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class UserSearchScreen extends StatefulWidget {
  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];

  void _searchUsers(String query) async {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    List<Map<String, dynamic>> users = [];
    for (var doc in snapshot.docs) {
      var userData = doc.data() as Map<String, dynamic>;
      users.add({
        'id': doc.id,
        'username': userData['username'],
        'profilePicture': userData['profilePicture'],
      });
    }

    setState(() {
      _searchResults = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: _searchUsers,
              decoration: InputDecoration(
                hintText: 'Search user',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20),
            _searchQuery.isEmpty
                ? Center(child: Text('Please enter a username to search'))
                : Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var user = _searchResults[index];
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
