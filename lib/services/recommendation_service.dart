import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gamemmedia/models/game.dart';
import 'package:gamemmedia/services/api_service.dart';

class RecommendationService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  Future<List<Game>> getRecommendations() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    // Kullanıcının favori ve istek listesini al
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(currentUser.uid).get();
    List<String> favoriteGameIds = List<String>.from(userSnapshot['favorites'] ?? []);
    List<String> wishlistGameIds = List<String>.from(userSnapshot['wishlist'] ?? []);

    // Oyun detaylarını çek
    List<Game> favoriteGames = await _fetchGames(favoriteGameIds);
    List<Game> wishlistGames = await _fetchGames(wishlistGameIds);

    // Tüm oyunların türlerini birleştir
    Set<String> genres = {};
    for (var game in favoriteGames + wishlistGames) {
      genres.addAll(game.genres);
    }

    if (genres.isEmpty) return [];

    // Sadece ilk türü alarak öneri yap
    String genre = genres.first;
    List<Game> recommendations = await _apiService.fetchGamesByGenre(genre);

    // Favori ve istek listesindeki oyunları çıkar
    recommendations = recommendations.where((game) =>
    !favoriteGameIds.contains(game.id) && !wishlistGameIds.contains(game.id)).toList();

    return recommendations;
  }

  Future<List<Game>> _fetchGames(List<String> gameIds) async {
    List<Game> games = [];
    for (String id in gameIds) {
      Game game = await _apiService.fetchGameById(id);
      games.add(game);
    }
    return games;
  }
}
