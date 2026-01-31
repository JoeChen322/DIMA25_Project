import 'package:flutter/material.dart';
import '../widgets/cast_strip.dart';
import '../models/cast.dart';
import '../services/tmdb_api.dart';
import '../database/favorite.dart';

class MovieDetailPage extends StatefulWidget {
  final Map<String, dynamic> movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool isFavorite = false; // add to the list（wait for the page set up）
  int? userRating; // user rating score 1-5
  final TmdbService tmdbService =
      TmdbService('eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U');
      // TMDb API token V4 versiom

  List<CastMember> cast = [];
  bool isLoadingCast = true;
  @override
  void initState() {
    super.initState();
    _checkFavorite();
    _loadCast();
  }
  Future<void> _checkFavorite() async {
  final imdbId = widget.movie['imdbID'];
  if (imdbId == null) return;

  final exists = await FavoriteDao.isFavorite(imdbId);
  setState(() {
    isFavorite = exists;
  });
}

// 在 movie_detail.dart 中找到 _loadCast
Future<void> _loadCast() async {
  final imdbId = widget.movie['imdbID']; // 获取 tt123456 格式 ID
  if (imdbId == null) {
    setState(() => isLoadingCast = false);
    return;
  }

  // 使用你已有的 getMovieIdByImdb 方法将 tt 号转回 TMDb 数字 ID
  final movieId = await tmdbService.getMovieIdByImdb(imdbId);
  if (movieId == null) {
    setState(() => isLoadingCast = false);
    return;
  }

  // 获取演员表
  final result = await tmdbService.getCast(movieId);

  setState(() {
    cast = result;
    isLoadingCast = false;
  });
}

void _showRatingDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Your Rating"),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final ratingValue = index + 1;
            return IconButton(
              icon: Icon(
                Icons.star,
                color: userRating != null && userRating! >= ratingValue
                    ? Colors.amber
                    : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  userRating = ratingValue;
                });
                Navigator.pop(context);
              },
            );
          }),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final director=movie["Director"] ?? "Unknown Director";
    String imdb = movie["imdbRating"] ?? "no rating";
    String? rotten;
    String? meta;

    final ratings = movie["Ratings"] as List<dynamic>? ?? [];
    for (var r in ratings) {
      if (r["Source"] == "Rotten Tomatoes") rotten = r["Value"];
      if (r["Source"] == "Metacritic") meta = r["Value"];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(movie["Title"] ?? "Movie Detail"),       
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (movie["Poster"] != null && movie["Poster"] != "N/A")
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              movie["Poster"],
              width: 120,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),

        const SizedBox(width: 16),

        Expanded(
          child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie["Title"] ?? "",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

          const SizedBox(height: 4),

          Text(
            "${movie["Year"] ?? ""} - $director",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),

            Row(
              children: [
                // List button
                // onTap to save or remove from favorite list
                _IconButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  iconColor: const Color.fromARGB(255, 195, 32, 21),
                  label: "Saves",
                  onTap: () async {
                    final imdbId = movie["imdbID"]; 
                    if (imdbId == null) {
                      print("Error: imdbID is null");
                      return;
                    }

                    try {
                      if (!isFavorite) {
                        // save to database
                        await FavoriteDao.insertFavorite(
                          imdbId: imdbId,
                          title: movie["Title"] ?? "Unknown",
                          poster: movie["Poster"] ?? "",
                          rating: userRating, 
                        );
                      } else {
                        //  remove from database
                        await FavoriteDao.deleteFavorite(imdbId);
                      }

                      // update UI
                      setState(() {
                        isFavorite = !isFavorite;
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isFavorite ? "Added to Saves List ❤️" : "Removed from List 💔"),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    } catch (e) {
                      //debug info
                      print("Database Error: $e"); 
                    }
                  },
                ),

                const SizedBox(width: 12),

                // Rating button
                  _IconButton(
                    icon: Icons.star_border,
                    iconColor: Colors.amber,
                    onTap: _showRatingDialog,
                    label: "Rate",
                  ),
                
              ],
            ),


                const SizedBox(height: 12),

                if (userRating != null)
                  Text(
                    "Your Rating: ${"★" * userRating!}${"☆" * (5 - userRating!)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 252, 189, 1),
                    ),
                  ),
              ],
                  ),
                  
                ),
              ],
),


            const SizedBox(height: 12),
            const Text(
              "Summary",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(movie["Plot"] ?? "No info available",
                style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),
            
            const SizedBox(height: 24),

            if (isLoadingCast)
              const Center(child: CircularProgressIndicator())
            else
              CastStrip(cast: cast),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:  const Color.fromARGB(255, 227, 219, 240), // Item color background
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ratings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  

                  const SizedBox(height: 8),

                  Text("IMDb: $imdb"),
                  Text("Rotten Tomatoes: ${rotten ?? "No Info"}"),
                  Text("Metascore: ${meta ?? "No Info"}"),

                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}
//define the icon button widget
Widget _IconButton({
  required IconData icon,
  required Color iconColor,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: onTap,
    child: Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

