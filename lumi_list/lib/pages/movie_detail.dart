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
  bool _isExpanded = false;
  bool isSeeLater = false;

  final TmdbService tmdbService = TmdbService(
    'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U',
  );

  List<CastMember> cast = [];
  bool isLoadingCast = true;

  String? realImdbId;
  Map<String, dynamic>? fullOmdbData;

  String _plot = "Loading Summary...";
  String _year = "NA";
  String _director = "No Info";
  String _genre = "No Info";

  // ---------------- Reviews (TMDb) ----------------
  List<dynamic> _topReviews = [];
  bool _isLoadingReviews = true;
  final Set<String> _expandedReviewIds = <String>{};

  // how many pages we fetch to build top 5
  static const int _reviewPrefetchPages = 3; // up to 60 reviews

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    String? id = widget.movie['imdbID'];
    int? tmdbId;

    if (id != null && !id.startsWith('tt')) {
      tmdbId = int.tryParse(id);
      if (tmdbId != null) {
        realImdbId = await tmdbService.getImdbIdByTmdbId(tmdbId);
        if (realImdbId != null) _loadOmdbDetails(realImdbId!);
      }
    } else if (id != null && id.startsWith('tt')) {
      _loadOmdbDetails(id);
      realImdbId = id;
      tmdbId = await tmdbService.getMovieIdByImdb(id);
    }

    if (tmdbId != null) {
      _loadCast(tmdbId);
      _loadTopReviews(tmdbId); // <-- Reviews
    } else {
      // if no tmdbId available, stop loading reviews
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
          _topReviews = [];
        });
      }
    }

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
      if (mounted) setState(() => _plot = "Failed to load summary.");
    }
  }

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
      if (mounted) {
        setState(() {
          cast = result;
          isLoadingCast = false;
        });
      }
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
        genre: _genre,
      );
    }
    setState(() => isFavorite = !isFavorite);
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rate this Movie"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.star,
                      size: 45,
                      color: (userRating ?? 0) > index
                          ? Colors.amber
                          : Colors.grey,
                    ),
                    onPressed: () async {
                      int newScore = index + 1;
                      if (realImdbId != null) {
                        await PersonalRateDao.insertOrUpdateRate(
                          imdbId: realImdbId!,
                          title: widget.movie['Title'] ?? "Unknown",
                          rating: newScore,
                        );
                      }
                      if (mounted) setState(() => userRating = newScore);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Reviews: fetch + pick top 5 ----------------
  Future<void> _loadTopReviews(int tmdbId) async {
    try {
      setState(() {
        _isLoadingReviews = true;
        _topReviews = [];
        _expandedReviewIds.clear();
      });

      final collected = <dynamic>[];
      for (int page = 1; page <= _reviewPrefetchPages; page++) {
        final batch = await tmdbService.getMovieReviews(tmdbId,
            page: page, language: 'en-US');
        if (batch.isEmpty) break;
        collected.addAll(batch);
        if (batch.length < 20) break;
      }

      final picked = _pickTop5(collected);

      if (!mounted) return;
      setState(() {
        _topReviews = picked;
        _isLoadingReviews = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _topReviews = [];
        _isLoadingReviews = false;
      });
    }
  }

  List<dynamic> _pickTop5(List<dynamic> all) {
    final list = List<dynamic>.from(all);
    list.removeWhere((r) => _reviewContent(r).isEmpty);

    list.sort((a, b) {
      final ar = _authorRating10(a);
      final br = _authorRating10(b);
      if (br != ar) return br.compareTo(ar);

      final alen = _reviewContent(a).length;
      final blen = _reviewContent(b).length;
      if (blen != alen) return blen.compareTo(alen);

      final ad = (a is Map) ? (a['created_at'] ?? '') : '';
      final bd = (b is Map) ? (b['created_at'] ?? '') : '';
      return bd.toString().compareTo(ad.toString());
    });

    return list.take(5).toList();
  }

  String _formatIsoDate(String? iso) {
    if (iso == null || iso.isEmpty) return "";
    try {
      final dt = DateTime.parse(iso);
      final y = dt.year.toString().padLeft(4, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      return "$y-$m-$d";
    } catch (_) {
      return iso.length >= 10 ? iso.substring(0, 10) : iso;
    }
  }

  double _authorRating10(dynamic review) {
    final ad = (review is Map) ? review['author_details'] : null;
    final r = (ad is Map) ? ad['rating'] : null;
    if (r is num) return r.toDouble(); // usually 0..10
    return 0.0;
  }

  String _authorName(dynamic review) {
    final author = (review is Map) ? review['author'] : null;
    final ad = (review is Map) ? review['author_details'] : null;
    final username = (ad is Map) ? ad['username'] : null;
    return (author ?? username ?? "Anonymous").toString();
  }

  String _reviewId(dynamic review) {
    final id = (review is Map) ? review['id'] : null;
    return (id ?? "").toString();
  }

  String _reviewContent(dynamic review) {
    final c = (review is Map) ? review['content'] : null;
    return (c ?? "").toString().trim();
  }

  String? _avatarUrl(dynamic review) {
    final ad = (review is Map) ? review['author_details'] : null;
    final ap = (ad is Map) ? ad['avatar_path'] : null;
    if (ap == null) return null;

    final s = ap.toString();
    if (s.startsWith('/https://') || s.startsWith('/http://')) {
      return s.substring(1);
    }
    if (s.startsWith('/')) {
      return "https://image.tmdb.org/t/p/w185$s";
    }
    if (s.startsWith('http')) return s;
    return null;
  }

  Widget _starRowFrom10(double rating10, ColorScheme cs) {
    final stars = (rating10 / 2.0).clamp(0.0, 5.0);
    final full = stars.floor();
    final hasHalf = (stars - full) >= 0.5;
    final empty = 5 - full - (hasHalf ? 1 : 0);

    final icons = <Widget>[];
    for (int i = 0; i < full; i++) {
      icons.add(const Icon(Icons.star, size: 16, color: Colors.amber));
    }
    if (hasHalf) {
      icons.add(const Icon(Icons.star_half, size: 16, color: Colors.amber));
    }
    for (int i = 0; i < empty; i++) {
      icons.add(Icon(Icons.star_border, size: 16, color: cs.onSurfaceVariant));
    }

    return Row(children: icons);
  }

  Widget _buildReviewsSection(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Short Reviews",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        if (_isLoadingReviews)
          const Center(child: CircularProgressIndicator())
        else if (_topReviews.isEmpty)
          Text("No reviews found.",
              style: TextStyle(color: cs.onSurfaceVariant))
        else
          Column(
            children: _topReviews.map((r) => _buildReviewTile(r, cs)).toList(),
          ),
      ],
    );
  }

  Widget _buildReviewTile(dynamic review, ColorScheme cs) {
    final id = _reviewId(review);
    final author = _authorName(review);
    final rating10 = _authorRating10(review);
    final date = _formatIsoDate((review is Map) ? review['created_at'] : null);
    final content = _reviewContent(review);
    final avatar = _avatarUrl(review);

    final expanded = _expandedReviewIds.contains(id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.surfaceContainerHighest,
                backgroundImage: (avatar != null && avatar.isNotEmpty)
                    ? NetworkImage(avatar)
                    : null,
                child: (avatar == null || avatar.isEmpty)
                    ? Icon(Icons.person, color: cs.onSurfaceVariant)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (rating10 > 0) _starRowFrom10(rating10, cs),
                        if (rating10 > 0) const SizedBox(width: 8),
                        if (date.isNotEmpty)
                          Text(
                            date,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final span = TextSpan(
                text: content,
                style: TextStyle(fontSize: 14.5, color: cs.onSurfaceVariant),
              );
              final tp = TextPainter(
                text: span,
                maxLines: 3,
                textDirection: TextDirection.ltr,
              );
              tp.layout(maxWidth: constraints.maxWidth);
              final exceeding = tp.didExceedMaxLines;

              return InkWell(
                onTap: exceeding
                    ? () {
                        setState(() {
                          if (expanded) {
                            _expandedReviewIds.remove(id);
                          } else {
                            _expandedReviewIds.add(id);
                          }
                        });
                      }
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content,
                      maxLines: expanded ? null : 3,
                      overflow: expanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 14.5,
                        height: 1.35,
                      ),
                    ),
                    if (exceeding)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            expanded ? "Fold" : "More...",
                            style: const TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;

    String imdb = "No Info";
    String rotten = "No Info";
    String meta = "No Info";

    List<String> genreList = _genre.split(',').map((e) => e.trim()).toList();
    genreList.removeWhere((element) => element == "No Info" || element.isEmpty);

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

    Widget detailContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${widget.movie['Title']} ($_year)",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            "——$_director",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
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
              MovieActionButton(
                icon: Icons.star,
                iconColor: userRating != null ? Colors.amber : Colors.grey,
                label: userRating != null ? "Rated: $userRating" : "Rate",
                onTap: _showRatingDialog,
              ),
              MovieActionButton(
                icon:
                    isSeeLater ? Icons.watch_later : Icons.watch_later_outlined,
                iconColor: Colors.blueAccent,
                label: isSeeLater ? "In Later" : "Later",
                onTap: _toggleSeeLater,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final span =
                  TextSpan(text: _plot, style: const TextStyle(fontSize: 16));
              final tp = TextPainter(
                text: span,
                maxLines: 3,
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
                      _plot,
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
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
          const SizedBox(height: 20),

          // ------------- show category -----------
          if (genreList.isNotEmpty)
            Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                const Text(
                  "Category: ",
                  style: TextStyle(
                    color: Color.fromARGB(179, 166, 67, 188),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...genreList
                    .map(
                      (genre) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          if (genreList.isNotEmpty) const SizedBox(height: 20),

          // ------------------------ cast ------------------------
          Text(
            "Cast",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          isLoadingCast
              ? const Center(child: CircularProgressIndicator())
              : CastStrip(cast: cast),
          const SizedBox(height: 30),

          // ------------------------ ratings ------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ratings",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRatingLine("IMDb", imdb, colorScheme),
                _buildRatingLine("Rotten Tomatoes", rotten, colorScheme),
                _buildRatingLine("Metascore", meta, colorScheme),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ------------------------ reviews (NEW) ------------------------
          _buildReviewsSection(colorScheme),

          const SizedBox(height: 50),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: isLandscape
          ? Row(
              children: [
                SizedBox(
                  width: screenWidth * 0.4,
                  height: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.movie['Poster'] ?? "",
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 50,
                        left: 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: SingleChildScrollView(child: detailContent)),
              ],
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        widget.movie['Poster'] ?? "",
                        width: double.infinity,
                        height: 530,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 530,
                          color: Colors.grey[900],
                          child: const Icon(Icons.broken_image,
                              size: 80, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        top: 80,
                        left: 20,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  detailContent,
                ],
              ),
            ),
    );
  }

  Widget _buildRatingLine(
      String platform, String score, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(platform, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          Text(
            score,
            style: const TextStyle(
                color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
