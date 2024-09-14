class Game {
  final String id;
  final String name;
  final String backgroundImage;
  final String description;
  final double rating;
  final List<String> genres;
  final int metacritic;

  Game({
    required this.id,
    required this.name,
    required this.backgroundImage,
    required this.description,
    required this.rating,
    required this.genres,
    required this.metacritic,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    List<String> genreList = (json['genres'] as List)
        .map((genre) => genre['name'] as String)
        .toList();

    return Game(
      id: json['id'].toString(),
      name: json['name'],
      backgroundImage: json['background_image'] ?? '',
      description: json['description'] ?? 'No description available.',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      genres: genreList,
      metacritic: json['metacritic'] ?? 0,
    );
  }
}
