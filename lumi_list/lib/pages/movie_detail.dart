import 'package:flutter/material.dart';

class MovieDetailPage extends StatefulWidget {
  final Map<String, dynamic> movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool isFavorite = false; // add to the list（wait for the page set up）
  int? userRating; // user rating (1-5)
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
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),

            Row(
              children: [
                // List button
                _IconButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  iconColor: const Color.fromARGB(255, 195, 32, 21),
                  label: "Saves",
                  onTap: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? "Added to Saves List ❤️"
                              : "Removed from List 💔",
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
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

            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 158, 158, 158).withOpacity(0.22), // grey background
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

