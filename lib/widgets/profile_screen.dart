import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/game.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import 'game_detail_screen.dart';
import 'followers_screen.dart';
import 'following_screen.dart';
import '/user/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  bool _isCurrentUser = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _checkIfFollowing();
    _checkIfCurrentUser();
    _fetchUserData();
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _fetchUserData();
      _checkIfFollowing();
    }
  }

  void _checkIfFollowing() async {
    bool isFollowing = await UserService().isFollowing(widget.userId);
    setState(() {
      _isFollowing = isFollowing;
    });
  }

  void _checkIfCurrentUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid == widget.userId) {
      setState(() {
        _isCurrentUser = true;
      });
    } else {
      setState(() {
        _isCurrentUser = false;
      });
    }
  }

  void _fetchUserData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    setState(() {
      _userData = snapshot.data() as Map<String, dynamic>;
    });
  }

  void _toggleFollow() async {
    if (_isFollowing) {
      await UserService().unfollowUser(widget.userId);
    } else {
      await UserService().followUser(widget.userId);
    }
    setState(() {
      _isFollowing = !_isFollowing;
    });
    _fetchUserData();
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  Future<List<Game>> _fetchGames(List<String> gameIds) async {
    List<Game> games = [];
    for (String id in gameIds) {
      Game game = await ApiService().fetchGameById(id);
      games.add(game);
    }
    return games;
  }

  Future<List<Map<String, dynamic>>> _fetchReviews(String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> reviewsWithGames = [];
    for (var doc in snapshot.docs) {
      var reviewData = doc.data() as Map<String, dynamic>;
      Game game = await ApiService().fetchGameById(reviewData['gameId']);
      reviewsWithGames.add({
        'review': reviewData,
        'game': game,
      });
    }
    return reviewsWithGames;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _userData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchUserData();
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _userData!['profilePicture'] != null
                            ? NetworkImage(_userData!['profilePicture'])
                            : null,
                      ),
                      SizedBox(height: 8),
                      Text(_userData!['username'] ?? 'No username'),
                      SizedBox(height: 8),
                      if (!_isCurrentUser)
                        ElevatedButton(
                          onPressed: _toggleFollow,
                          child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                        ),
                      if (_isCurrentUser)
                        ElevatedButton(
                          onPressed: _signOut,
                          child: Text('Çıkış Yap'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowersScreen(userId: widget.userId),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            '${_userData!['followers'].length}',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text('Followers'),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FollowingScreen(userId: widget.userId),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            '${_userData!['following'].length}',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text('Following'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Favorites', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                FutureBuilder<List<Game>>(
                  future: _fetchGames(List<String>.from(_userData!['favorites'] ?? [])),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No favorites found'));
                    } else {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final game = snapshot.data![index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameDetailScreen(game: game),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Image.network(
                                game.backgroundImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                Text('Wishlist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                FutureBuilder<List<Game>>(
                  future: _fetchGames(List<String>.from(_userData!['wishlist'] ?? [])),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No wishlist found'));
                    } else {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final game = snapshot.data![index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameDetailScreen(game: game),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Image.network(
                                game.backgroundImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchReviews(widget.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No reviews found'));
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var reviewWithGame = snapshot.data![index];
                          var review = reviewWithGame['review'];
                          var game = reviewWithGame['game'] as Game;
                          return ListTile(
                            leading: Image.network(
                              game.backgroundImage,
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                            title: Text(game.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RatingBarIndicator(
                                  rating: review['rating'],
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  direction: Axis.horizontal,
                                ),
                                Text(review['review']),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GameDetailScreen(game: game),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
