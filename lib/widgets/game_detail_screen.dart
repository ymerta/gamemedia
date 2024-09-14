import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart'; // flutter_widget_from_html paketini ekleyin
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game.dart';
import 'add_review_screen.dart';

class GameDetailScreen extends StatelessWidget {
  final Game game;

  GameDetailScreen({required this.game});

  void _addToFavorites(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı girişi gerekli')),
      );
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userDoc.update({
      'favorites': FieldValue.arrayUnion([game.id])
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${game.name} favorilere eklendi')),
    );
  }

  void _addToWishlist(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kullanıcı girişi gerekli')),
      );
      return;
    }

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userDoc.update({
      'wishlist': FieldValue.arrayUnion([game.id])
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${game.name} istek listesine eklendi')),
    );
  }

  void _writeReview(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewScreen(gameId: game.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              game.backgroundImage.isNotEmpty
                  ? Image.network(game.backgroundImage)
                  : Container(height: 200, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                game.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Rating: ${game.rating}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Genres: ${game.genres}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Metacritic: ${game.metacritic}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              HtmlWidget(game.description), // HTML içeriğini işlemek için HtmlWidget widget'ını kullanın
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _addToFavorites(context),
                child: Text('Favorilere Ekle'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _addToWishlist(context),
                child: Text('İstek Listesine Ekle'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _writeReview(context),
                child: Text('Yorum Yaz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
