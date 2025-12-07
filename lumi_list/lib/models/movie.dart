class Movie {
  final int id;
  final String title;
  final String posterUrl;
  final String overview;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.overview,
  });

  factory Movie.fromTMDb(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? "",
      posterUrl: json['poster_path'] != null
          ? "https://image.tmdb.org/t/p/w500${json['poster_path']}"
          : "",
      overview: json['overview'] ?? "",
    );
  }
}
