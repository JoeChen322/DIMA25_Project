/*to show the movie name, poster, summary, cast, ratings from several platforms, 
and allow user to favorite and rate the movie*/
/*get info from both TMDb API and OMDb API*/

import 'package:flutter/material.dart';
import '../widgets/cast_strip.dart';
import '../models/cast.dart';
import '../services/tmdb_api.dart';
import '../services/omdb_api.dart'; 
import '../database/favorite.dart';
import '../database/personal_rate.dart';
import '../database/seelater.dart';
import '../widgets/icon_action_button.dart';
class MovieDetailPage extends StatefulWidget {
  final Map<String, dynamic> movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool isFavorite = false;
  int? userRating; 
  bool _isExpanded=false;
  bool isSeeLater = false;
  
  final TmdbService tmdbService = TmdbService(
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U');

  List<CastMember> cast = [];
  bool isLoadingCast = true;
  String? realImdbId; 
  Map<String, dynamic>? fullOmdbData; 
  String _plot="Loading Summary...";
  String _year = "NA";
  String _director = "No Info";
  String _genre = "No Info";
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  /*------isolated net request，use future to load parallelly and avoid blocking the UI------ */
  Future<void> _initializeData() async {
    String? id = widget.movie['imdbID']; 
    int? tmdbId;

    // change all ids to both TMDb and IMDB into IMDB ID
    if (id != null && !id.startsWith('tt'))
    {
      tmdbId = int.parse(id);
      realImdbId = await tmdbService.getImdbIdByTmdbId(tmdbId);
      _loadOmdbDetails(realImdbId!);
    } else if (id != null && id.startsWith('tt')) {
      _loadOmdbDetails(id);
      realImdbId = id;
      tmdbId = await tmdbService.getMovieIdByImdb(id);
    }

    // load cast and OMDb data
    if (tmdbId != null) _loadCast(tmdbId);

    if (realImdbId != null) {
      final omdbData = await OmdbApi.getMovieById(realImdbId!);
      final favoriteStatus = await FavoriteDao.isFavorite(realImdbId!);   
      final laterStatus = await SeeLaterDao.isSeeLater(realImdbId!);
      final savedRating = await PersonalRateDao.getRating(realImdbId!);
      if (mounted) {
        setState(() {
          fullOmdbData = omdbData;
          isFavorite = favoriteStatus;
          isSeeLater = laterStatus;
          userRating = savedRating;

        });
      }
    }
  }

Future<void> _loadOmdbDetails(String id) async {
  try {
    final details = await OmdbApi.getMovieById(id); 
    
    if (mounted && details != null) {
      setState(() {
        _director = details['Director'] ?? "No Info";
        _plot = details['Plot'] ?? "No summary available.";
        _year = details['Year'] ?? "";
        _genre = details['Genre'] ?? "No Info";
      });
    }
  } catch (e) {
    setState(() {
      _plot = "Failed to load summary.";
    });
  }
}

  Future<void> _checkSeeLaterStatus() async {
  if (realImdbId != null) {
    final status = await SeeLaterDao.isSeeLater(realImdbId!);
    setState(() => isSeeLater = status);
  }
}

// see later status
Future<void> _toggleSeeLater() async {
  if (realImdbId == null) return;
  if (isSeeLater) {
    await SeeLaterDao.deleteSeeLater(realImdbId!);
  } else {
    await SeeLaterDao.insertSeeLater(
      imdbId: realImdbId!,
      title: widget.movie['Title'] ?? "Unknown",
      poster: widget.movie['Poster'] ?? "",
    );
  }
  setState(() => isSeeLater = !isSeeLater);
 }
  
  Future<void> _loadCast(int tmdbId) async {
    try {
      final result = await tmdbService.getCast(tmdbId);
      if (mounted) setState(() { cast = result; isLoadingCast = false; });
    } catch (e) {
      if (mounted) setState(() => isLoadingCast = false);
    }
  }
 // favorite state
  Future<void> _toggleFavorite() async {
    if (realImdbId == null) return;
    if (isFavorite) {
      await FavoriteDao.deleteFavorite(realImdbId!);
    } else {
      await FavoriteDao.insertFavorite(
        imdbId: realImdbId!,
        title: widget.movie['Title'] ?? "Unknown",
        poster: widget.movie['Poster'] ?? "",
        genre: _genre,
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
      content: Wrap(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        alignment: WrapAlignment.center,
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

    /*---------split genre string into list----------  */  
    List<String> genreList = _genre.split(',').map((e) => e.trim()).toList();
    genreList.removeWhere((element) => element == "No Info" || element.isEmpty);
   /*-----------------------------------------------*/
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
                  widget.movie['Poster'] ?? "",
                  width: double.infinity, height: 530, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 530, color: Colors.grey[900], child: const Icon(Icons.broken_image, size: 80, color: Colors.white)),
                ),
                Positioned(top: 80, left: 20, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${widget.movie['Title']} ($_year)", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("——$_director", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MovieActionButton(
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                        iconColor: Colors.red,
                        label: isFavorite ? "Saved" : "My List",
                        onTap: _toggleFavorite,
                      ),
                      // star rating buttons
                      MovieActionButton(
                        icon: Icons.star,
                        iconColor: userRating != null ? Colors.amber : Colors.grey,
                        label: userRating != null ? "My: $userRating" : "Rate",
                        onTap: _showRatingDialog,
                      ),
                      //add to watch later list
                      MovieActionButton(
                        icon: isSeeLater ? Icons.watch_later : Icons.watch_later_outlined,
                        iconColor: Colors.blueAccent,
                        label: isSeeLater ? "In Later" : "Later",
                        onTap: _toggleSeeLater,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),

                  /*-----------------summary section with expandable text-------*/
                  const Text( "Summary",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final span = TextSpan(
                        text: _plot ?? "No summary available.",
                        style: const TextStyle(fontSize: 16),
                      );
                      final tp = TextPainter(
                        text: span,
                        maxLines: 3, // if more than 3 lines, show "More..." button
                        textDirection: TextDirection.ltr,
                      );
                    tp.layout(maxWidth: constraints.maxWidth);
                    final bool isExceeding = tp.didExceedMaxLines;

                      return InkWell(
                        onTap: isExceeding 
                            ? () => setState(() => _isExpanded = !_isExpanded) 
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _plot ?? "No summary available.",
                              maxLines: _isExpanded ? null : 3,
                              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: const TextStyle(color: Color.fromARGB(255, 215, 214, 214), fontSize: 16),
                            ),
                            if (isExceeding)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    _isExpanded ? "Fold" : "More...",
                                    style: const TextStyle(
                                      color: Colors.deepPurpleAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  /*--- ---------------Genre Tags-------------------------*/
                  const SizedBox(height: 20),
                  if (genreList.isNotEmpty)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.0, 
                      runSpacing: 4.0, 
                      children: genreList.map((genre) => Chip(
                        label: Text(
                          genre,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: const Color.fromARGB(255, 87, 33, 235).withOpacity(0.3),
                        side: BorderSide(color: const Color.fromARGB(255, 95, 47, 225).withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                  
                  if (genreList.isNotEmpty) const SizedBox(height: 20),
                  
                /*-------------------------------cast section---------------------------------*/
                
                  //Text(fullOmdbData?['Plot'] ?? widget.movie['Plot'] ?? "No summary available.", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 20),
                  const Text("Cast", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  isLoadingCast ? const Center(child: CircularProgressIndicator()) : CastStrip(cast: cast),
                  
                  /*-------------------------Ratings from --------------------------------*/
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
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(platform, style: const TextStyle(color: Colors.white70)),
          Text(score, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
