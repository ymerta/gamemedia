import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';

class ApiService {
  static const String apiKey = '298e4dfab228462381c3f9cd2b8bbe47'; // Your RAWG API key here
  static const String baseUrl = 'https://api.rawg.io/api';

  Future<List<Game>> fetchGames({int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games?key=$apiKey&page_size=$limit'),
    );

    if (response.statusCode == 200) {
      final List games = json.decode(response.body)['results'];
      return games.map((json) => Game.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load games');
    }
  }

  Future<List<Game>> searchGames(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games?key=$apiKey&search=$query'),
    );

    if (response.statusCode == 200) {
      final List games = json.decode(response.body)['results'];
      return games.map((json) => Game.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search games');
    }
  }

  Future<Game> fetchGameById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games/$id?key=$apiKey'),
    );

    if (response.statusCode == 200) {
      return Game.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load game');
    }
  }

  Future<List<Game>> fetchGamesByGenre(String genre) async {
    final response = await http.get(
      Uri.parse('$baseUrl/games?key=$apiKey&genres=$genre&page_size=50'),
    );

    if (response.statusCode == 200) {
      final List games = json.decode(response.body)['results'];
      return games.map((json) => Game.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load games by genre');
    }
  }
}
