import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import '../models/game.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'game_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Game>> _defaultGames;
  Future<List<Game>>? _searchResults;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _defaultGames = ApiService().fetchGames(limit: 50); // İlk 50 oyunu getir
  }

  void _searchGames(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchResults = ApiService().searchGames(query);
      });
    });
  }

  void _showGameDetails(Game game) async {
    final gameDetails = await ApiService().fetchGameById(game.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailScreen(game: gameDetails),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search games...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onChanged: _searchGames,
            ),
          ),
        ),
      ),
      body: _searchResults == null
          ? FutureBuilder<List<Game>>(
        future: _defaultGames,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No games found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final game = snapshot.data![index];
                return ListTile(
                  leading: game.backgroundImage.isNotEmpty
                      ? Image.network(game.backgroundImage, width: 50, height: 50, fit: BoxFit.cover)
                      : Container(width: 50, height: 50, color: Colors.grey),
                  title: Text(game.name),
                  onTap: () => _showGameDetails(game),
                );
              },
            );
          }
        },
      )
          : FutureBuilder<List<Game>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No games found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final game = snapshot.data![index];
                return ListTile(
                  leading: game.backgroundImage.isNotEmpty
                      ? Image.network(game.backgroundImage, width: 50, height: 50, fit: BoxFit.cover)
                      : Container(width: 50, height: 50, color: Colors.grey),
                  title: Text(game.name),
                  onTap: () => _showGameDetails(game),
                );
              },
            );
          }
        },
      ),
    );
  }
}
