import 'package:flutter/material.dart';
import '../widgets/cast_strip.dart';
import '../models/cast.dart';
import '../services/tmdb_api.dart';
import '../services/omdb_api.dart'; 
import '../database/favorite.dart';
import '../database/personal_rate.dart';
class MovieDetailPage extends StatefulWidget {
  final Map<String, dynamic> movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool isFavorite = false;
  int? userRating; 
  
  final TmdbService tmdbService = TmdbService(
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U');

  List<CastMember> cast = [];
  bool isLoadingCast = true;
  String? realImdbId; 
  Map<String, dynamic>? fullOmdbData; 

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    String? id = widget.movie['imdbID']; 
    int? tmdbId;

    // change all ids to both TMDb and IMDB into IMDB ID
    if (id != null && !id.startsWith('tt')) {
      tmdbId = int.parse(id);
      realImdbId = await tmdbService.getImdbIdByTmdbId(tmdbId);
    } else if (id != null && id.startsWith('tt')) {
      realImdbId = id;
      tmdbId = await tmdbService.getMovieIdByImdb(id);
    }

    // load cast and OMDb data
    if (tmdbId != null) _loadCast(tmdbId);

    if (realImdbId != null) {
      final omdbData = await OmdbApi.getMovieById(realImdbId!);
      final favoriteStatus = await FavoriteDao.isFavorite(realImdbId!);
      final savedRating = await PersonalRateDao.getRating(realImdbId!);
      if (mounted) {
        setState(() {
          fullOmdbData = omdbData;
          isFavorite = favoriteStatus;
          userRating = savedRating;
        });
      }
    }
  }

  Future<void> _loadCast(int tmdbId) async {
    try {
      final result = await tmdbService.getCast(tmdbId);
      if (mounted) setState(() { cast = result; isLoadingCast = false; });
    } catch (e) {
      if (mounted) setState(() => isLoadingCast = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (realImdbId == null) return;
    if (isFavorite) {
      await FavoriteDao.deleteFavorite(realImdbId!);
    } else {
      await FavoriteDao.insertFavorite(
        imdbId: realImdbId!,
        title: widget.movie['Title'] ?? "Unknown",
        poster: widget.movie['Poster'] ?? "",
      );
    }
    setState(() => isFavorite = !isFavorite);
  }

  // show rating dialog
void _showRatingDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Rate this Movie"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) => IconButton(
          icon: Icon(
            Icons.star, 
            color: (userRating ?? 0) > index ? Colors.amber : Colors.grey
          ),
          onPressed: () async {
            int newScore = index + 1;
            //store the new rating in the database
            if (realImdbId != null) {
              await PersonalRateDao.insertOrUpdateRate(
                imdbId: realImdbId!,
                title: widget.movie['Title'] ?? "Unknown",
                rating: newScore,
              );
            }

            if (mounted) {
              setState(() => userRating = newScore); 
            }
            Navigator.pop(context);
          },
        )),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    // load ratings from several platforms
    String imdb = "No Info";
    String rotten = "No Info";
    String meta = "No Info";

    final ratings = fullOmdbData?['Ratings'] as List?;
    if (ratings != null) {
      for (var r in ratings) {
        if (r['Source'] == 'Internet Movie Database') imdb = r['Value'];
        if (r['Source'] == 'Rotten Tomatoes') rotten = r['Value'];
        if (r['Source'] == 'Metacritic') meta = r['Value'];
      }
    } else {
      imdb = widget.movie['imdbRating'] ?? "No Info";
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  widget.movie["Poster"] ?? "",
                  width: double.infinity, height: 450, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 450, color: Colors.grey[900], child: const Icon(Icons.broken_image, size: 80, color: Colors.white)),
                ),
                Positioned(top: 50, left: 20, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${widget.movie['Title']} (${widget.movie['Year']})", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _IconButton(
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                        iconColor: Colors.red,
                        label: isFavorite ? "Saved" : "My List",
                        onTap: _toggleFavorite,
                      ),
                      // star rating buttons
                      _IconButton(
                        icon: Icons.star,
                        iconColor: userRating != null ? Colors.amber : Colors.grey,
                        label: userRating != null ? "My: $userRating" : "Rate",
                        onTap: _showRatingDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(fullOmdbData?['Plot'] ?? widget.movie['Plot'] ?? "No summary available.", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 20),
                  const Text("Cast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  isLoadingCast ? const Center(child: CircularProgressIndicator()) : CastStrip(cast: cast),
                  
                  // Ratings from 
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity, 
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Ratings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        _buildRatingLine("IMDb", imdb),
                        _buildRatingLine("Rotten Tomatoes", rotten),
                        _buildRatingLine("Metascore", meta),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildRatingLine(String platform, String score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(platform, style: const TextStyle(color: Colors.white70)),
          Text(score, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

//  _IconButton form
Widget _IconButton({required IconData icon, required Color iconColor, required String label, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 100, height: 50,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}