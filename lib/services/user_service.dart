import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> followUser(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _firestore.runTransaction((transaction) async {
      DocumentReference currentUserRef = _firestore.collection('users').doc(currentUser.uid);
      DocumentReference userToFollowRef = _firestore.collection('users').doc(userId);

      transaction.update(currentUserRef, {
        'following': FieldValue.arrayUnion([userId]),
      });

      transaction.update(userToFollowRef, {
        'followers': FieldValue.arrayUnion([currentUser.uid]),
      });
    });
  }

  Future<void> unfollowUser(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await _firestore.runTransaction((transaction) async {
      DocumentReference currentUserRef = _firestore.collection('users').doc(currentUser.uid);
      DocumentReference userToUnfollowRef = _firestore.collection('users').doc(userId);

      transaction.update(currentUserRef, {
        'following': FieldValue.arrayRemove([userId]),
      });

      transaction.update(userToUnfollowRef, {
        'followers': FieldValue.arrayRemove([currentUser.uid]),
      });
    });
  }

  Future<bool> isFollowing(String userId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    DocumentSnapshot snapshot = await _firestore.collection('users').doc(currentUser.uid).get();
    List following = snapshot['following'] ?? [];
    return following.contains(userId);
  }
}
