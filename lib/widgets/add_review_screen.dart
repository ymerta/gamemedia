import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AddReviewScreen extends StatefulWidget {
  final String gameId;

  AddReviewScreen({required this.gameId});

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _reviewController = TextEditingController();
  double _rating = 0.0;

  void _submitReview() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance.collection('reviews').add({
      'userId': currentUser.uid,
      'gameId': widget.gameId,
      'review': _reviewController.text,
      'rating': _rating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Review',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            Text('Rating'),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitReview,
              child: Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
