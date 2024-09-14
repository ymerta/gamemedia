import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/game.dart';
import '../services/api_service.dart';
import '../services/recommendation_service.dart';
import 'game_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _reviews = [];
  List<Game> _recommendations = [];
  bool _isLoadingReviews = true;
  bool _isLoadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _fetchRecommendations();
  }

  Future<void> _fetchReviews() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    List following = userSnapshot['following'] ?? [];

    if (following.isEmpty) {
      setState(() {
        _isLoadingReviews = false;
      });
      return;
    }

    QuerySnapshot reviewSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('userId', whereIn: following)
        .orderBy('timestamp', descending: true)
        .get();

    List<Map<String, dynamic>> reviewsWithGames = [];
    for (var doc in reviewSnapshot.docs) {
      var reviewData = doc.data() as Map<String, dynamic>;
      Game game = await ApiService().fetchGameById(reviewData['gameId']);
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(reviewData['userId'])
          .get();
      var userData = userSnapshot.data() as Map<String, dynamic>;
      reviewsWithGames.add({
        'review': reviewData,
        'game': game,
        'user': userData,
      });
    }

    setState(() {
      _reviews = reviewsWithGames;
      _isLoadingReviews = false;
    });
  }

  Future<void> _fetchRecommendations() async {
    List<Game> recommendations = await RecommendationService().getRecommendations();
    setState(() {
      _recommendations = recommendations;
      _isLoadingRecommendations = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: _isLoadingReviews && _isLoadingRecommendations
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await _fetchReviews();
          await _fetchRecommendations();
        },
        child: ListView(
          children: [
            if (!_isLoadingReviews) _buildReviewSection(),
            if (!_isLoadingRecommendations) _buildRecommendationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Recent Reviews',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ..._reviews.map((reviewWithGame) {
          var review = reviewWithGame['review'];
          var game = reviewWithGame['game'] as Game;
          var user = reviewWithGame['user'];
          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
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
                          builder: (context) => ProfileScreen(userId: review['userId']),
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetailScreen(game: game),
                        ),
                      );
                    },
                    child: Image.network(
                      game.backgroundImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(review['review']),
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
                  Text(
                    '${review['timestamp'].toDate()}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Recommended for You',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ..._recommendations.map((game) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameDetailScreen(game: game),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    game.backgroundImage,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text('Genres: ${game.genres.join(', ')}'),
                        SizedBox(height: 8.0),
                        Text('Rating: ${game.rating.toString()}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
