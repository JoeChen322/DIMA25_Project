import 'package:flutter/material.dart';

import 'search_page.dart';
import 'me_page.dart';
import 'movie_detail.dart';
import '../services/tmdb_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialIndex = 1});

  /// 0 = Search, 1 = Home, 2 = Me
  final int initialIndex;

  static const Key kBottomNav = Key('home_bottom_nav');
  static const Key kNavRail = Key('home_nav_rail');
  static const Key kTabSearch = Key('home_tab_search');
  static const Key kTabHome = Key('home_tab_home');
  static const Key kTabMe = Key('home_tab_me');

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 1;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args.containsKey('email')) {
      setState(() {
        _userEmail = args['email'];
      });
    }
  }

  Widget _buildBody() {
    switch (_index) {
      case 0:
        return const SearchPage();
      case 2:
        return MyListPage(email: _userEmail);
      default:
        return const HomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      bottomNavigationBar: isWideScreen
          ? null
          : BottomNavigationBar(
              key: HomePage.kBottomNav,
              currentIndex: _index,
              onTap: (index) => setState(() => _index = index),
              backgroundColor: colorScheme.surface,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurfaceVariant,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.search, key: HomePage.kTabSearch),
                  label: "Search",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, key: HomePage.kTabHome),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, key: HomePage.kTabMe),
                  label: "Me",
                ),
              ],
            ),
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              key: HomePage.kNavRail,
              backgroundColor: colorScheme.surface,
              selectedIndex: _index,
              onDestinationSelected: (index) => setState(() => _index = index),
              groupAlignment: 0.0,
              labelType: NavigationRailLabelType.all,
              selectedIconTheme: IconThemeData(color: colorScheme.primary),
              unselectedIconTheme:
                  IconThemeData(color: colorScheme.onSurfaceVariant),
              selectedLabelTextStyle: TextStyle(color: colorScheme.primary),
              unselectedLabelTextStyle:
                  TextStyle(color: colorScheme.onSurfaceVariant),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Icon(Icons.movie_filter,
                    color: Colors.deepPurpleAccent, size: 40),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.search, key: HomePage.kTabSearch),
                  label: Text("Search"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.home, key: HomePage.kTabHome),
                  label: Text("Home"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person, key: HomePage.kTabMe),
                  label: Text("Me"),
                ),
              ],
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TmdbService tmdbService = TmdbService(
    'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U',
  );

  // TMDb returns ~20 results per page (not configurable).
  // We implement UI paging of 10 using a buffer.
  static const int _tmdbPageSize = 20; // informational
  static const int _uiPageSize = 10; // what YOU want (per button press)
  static const int _maxItemsPerLane = 30;

  // --- TRENDING lane ---
  final ScrollController _trendingCtrl = ScrollController();
  List<dynamic> _trendingMovies = [];
  List<dynamic> _trendingBuffer = [];
  final Set<int> _trendingIds = <int>{};
  bool _isLoading = true; // whole page initial
  bool _isTrendingPaging = false;
  bool _trendingHasMore = true;
  int _trendingTmdbPage = 1; // last fetched TMDb page
  bool _trendingReachedEnd = false; // TMDb returned less than a full page

  // --- UPCOMING lane ---
  final ScrollController _upcomingCtrl = ScrollController();
  List<dynamic> _upcomingMovies = [];
  List<dynamic> _upcomingBuffer = [];
  final Set<int> _upcomingIds = <int>{};
  bool _isUpcomingLoading = true; // section loading
  bool _isUpcomingPaging = false;
  bool _upcomingHasMore = true;
  int _upcomingTmdbPage = 1;
  bool _upcomingReachedEnd = false;

  @override
  void initState() {
    super.initState();
    _fetchTrendingInitial();
    _fetchUpcomingInitial();
  }

  @override
  void dispose() {
    _trendingCtrl.dispose();
    _upcomingCtrl.dispose();
    super.dispose();
  }

  // -----------------------------
  // Common helpers (buffer + dedupe)
  // -----------------------------
  int _safeId(dynamic item) {
    final v = item is Map ? item['id'] : null;
    return v is int ? v : -1;
  }

  void _pushUniqueToBuffer({
    required List<dynamic> raw,
    required Set<int> seenIds,
    required List<dynamic> buffer,
  }) {
    for (final m in raw) {
      final id = _safeId(m);
      if (id <= 0) continue;
      if (seenIds.contains(id)) continue;
      seenIds.add(id);
      buffer.add(m);
    }
  }

  int _drainFromBuffer({
    required List<dynamic> buffer,
    required List<dynamic> visible,
    required int want,
    required int maxTotal,
  }) {
    if (want <= 0) return 0;

    final remainingTotal = maxTotal - visible.length;
    final canAdd = remainingTotal <= 0 ? 0 : remainingTotal;
    final toTake = want < canAdd ? want : canAdd;

    if (toTake <= 0) return 0;

    final n = buffer.length < toTake ? buffer.length : toTake;
    if (n <= 0) return 0;

    visible.addAll(buffer.take(n));
    buffer.removeRange(0, n);
    return n;
  }

  bool _computeHasMore({
    required List<dynamic> visible,
    required List<dynamic> buffer,
    required bool reachedEnd,
  }) {
    if (visible.length >= _maxItemsPerLane) return false;
    if (buffer.isNotEmpty) return true;
    if (reachedEnd) return false;
    return true;
  }

  // -----------------------------
  // TRENDING fetch
  // -----------------------------
  Future<List<dynamic>> _fetchTrendingPage(int tmdbPage) async {
    final movies = await tmdbService.getTrendingMovies(page: tmdbPage);

    // keep only movies
    final filtered = movies
        .where((m) => m['media_type'] == 'movie' || m['media_type'] == null)
        .toList();

    return filtered;
  }

  Future<void> _fetchTrendingInitial() async {
    try {
      final raw = await _fetchTrendingPage(1);
      if (!mounted) return;

      _trendingMovies = [];
      _trendingBuffer = [];
      _trendingIds.clear();

      _trendingTmdbPage = 1;
      _trendingReachedEnd = raw.length < _tmdbPageSize;

      _pushUniqueToBuffer(
        raw: raw,
        seenIds: _trendingIds,
        buffer: _trendingBuffer,
      );

      _drainFromBuffer(
        buffer: _trendingBuffer,
        visible: _trendingMovies,
        want: _uiPageSize,
        maxTotal: _maxItemsPerLane,
      );

      setState(() {
        _isLoading = false;
        _isTrendingPaging = false;
        _trendingHasMore = _computeHasMore(
          visible: _trendingMovies,
          buffer: _trendingBuffer,
          reachedEnd: _trendingReachedEnd,
        );
      });
    } catch (e) {
      debugPrint('Trending fetch error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreTrending() async {
    if (_isLoading || _isTrendingPaging || !_trendingHasMore) return;

    // already at max?
    if (_trendingMovies.length >= _maxItemsPerLane) {
      setState(() => _trendingHasMore = false);
      return;
    }

    setState(() => _isTrendingPaging = true);

    try {
      int added = 0;

      // 1) drain buffer first
      added += _drainFromBuffer(
        buffer: _trendingBuffer,
        visible: _trendingMovies,
        want: _uiPageSize,
        maxTotal: _maxItemsPerLane,
      );

      // 2) if still need, fetch next TMDb pages until we add 10 or no more
      while (added < _uiPageSize &&
          _trendingMovies.length < _maxItemsPerLane &&
          !_trendingReachedEnd &&
          _trendingBuffer.isEmpty) {
        final nextTmdbPage = _trendingTmdbPage + 1;
        final raw = await _fetchTrendingPage(nextTmdbPage);
        if (!mounted) return;

        _trendingTmdbPage = nextTmdbPage;
        _trendingReachedEnd = raw.length < _tmdbPageSize;

        _pushUniqueToBuffer(
          raw: raw,
          seenIds: _trendingIds,
          buffer: _trendingBuffer,
        );

        // drain after fetching
        added += _drainFromBuffer(
          buffer: _trendingBuffer,
          visible: _trendingMovies,
          want: _uiPageSize - added,
          maxTotal: _maxItemsPerLane,
        );

        // If TMDb gave nothing new (rare edge), break to avoid loops
        if (raw.isEmpty) break;
      }

      if (!mounted) return;

      setState(() {
        _isTrendingPaging = false;
        _trendingHasMore = _computeHasMore(
          visible: _trendingMovies,
          buffer: _trendingBuffer,
          reachedEnd: _trendingReachedEnd,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTrendingPaging = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load more trending movies.")),
      );
    }
  }

  // -----------------------------
  // UPCOMING fetch
  // -----------------------------
  Future<List<dynamic>> _fetchUpcomingPage(int tmdbPage) async {
    // You can change region if you want (e.g. "IT", "US").
    final movies =
        await tmdbService.getUpcomingMovies(page: tmdbPage, region: 'US');
    return movies;
  }

  Future<void> _fetchUpcomingInitial() async {
    try {
      final raw = await _fetchUpcomingPage(1);
      if (!mounted) return;

      _upcomingMovies = [];
      _upcomingBuffer = [];
      _upcomingIds.clear();

      _upcomingTmdbPage = 1;
      _upcomingReachedEnd = raw.length < _tmdbPageSize;

      _pushUniqueToBuffer(
        raw: raw,
        seenIds: _upcomingIds,
        buffer: _upcomingBuffer,
      );

      _drainFromBuffer(
        buffer: _upcomingBuffer,
        visible: _upcomingMovies,
        want: _uiPageSize,
        maxTotal: _maxItemsPerLane,
      );

      setState(() {
        _isUpcomingLoading = false;
        _isUpcomingPaging = false;
        _upcomingHasMore = _computeHasMore(
          visible: _upcomingMovies,
          buffer: _upcomingBuffer,
          reachedEnd: _upcomingReachedEnd,
        );
      });
    } catch (e) {
      debugPrint('Upcoming fetch error: $e');
      if (!mounted) return;
      setState(() => _isUpcomingLoading = false);
    }
  }

  Future<void> _loadMoreUpcoming() async {
    if (_isUpcomingLoading || _isUpcomingPaging || !_upcomingHasMore) return;

    if (_upcomingMovies.length >= _maxItemsPerLane) {
      setState(() => _upcomingHasMore = false);
      return;
    }

    setState(() => _isUpcomingPaging = true);

    try {
      int added = 0;

      // 1) drain buffer
      added += _drainFromBuffer(
        buffer: _upcomingBuffer,
        visible: _upcomingMovies,
        want: _uiPageSize,
        maxTotal: _maxItemsPerLane,
      );

      // 2) fetch more if needed
      while (added < _uiPageSize &&
          _upcomingMovies.length < _maxItemsPerLane &&
          !_upcomingReachedEnd &&
          _upcomingBuffer.isEmpty) {
        final nextTmdbPage = _upcomingTmdbPage + 1;
        final raw = await _fetchUpcomingPage(nextTmdbPage);
        if (!mounted) return;

        _upcomingTmdbPage = nextTmdbPage;
        _upcomingReachedEnd = raw.length < _tmdbPageSize;

        _pushUniqueToBuffer(
          raw: raw,
          seenIds: _upcomingIds,
          buffer: _upcomingBuffer,
        );

        added += _drainFromBuffer(
          buffer: _upcomingBuffer,
          visible: _upcomingMovies,
          want: _uiPageSize - added,
          maxTotal: _maxItemsPerLane,
        );

        if (raw.isEmpty) break;
      }

      if (!mounted) return;

      setState(() {
        _isUpcomingPaging = false;
        _upcomingHasMore = _computeHasMore(
          visible: _upcomingMovies,
          buffer: _upcomingBuffer,
          reachedEnd: _upcomingReachedEnd,
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpcomingPaging = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to load more coming soon movies.")),
      );
    }
  }

  // -----------------------------
  // UI helpers
  // -----------------------------
  void _navigateToDetail(dynamic movie) async {
    final int tmdbId = movie['id'];
    final String? realImdbId = await tmdbService.getImdbIdByTmdbId(tmdbId);

    final Map<String, dynamic> movieData = {
      "Title": movie['title'] ?? movie['name'],
      "Year": movie['release_date']?.split('-')[0] ?? "",
      "Poster": "https://image.tmdb.org/t/p/w500${movie['poster_path']}",
      "Plot": movie['overview'],
      "imdbID": realImdbId,
      "imdbRating": movie['vote_average']?.toString(),
    };

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MovieDetailPage(movie: movieData)),
    );
  }

  Widget _sectionHeader(String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _footerCard({
    required ColorScheme cs,
    required bool isPaging,
    required bool hasMore,
    required VoidCallback onLoadMore,
    required ScrollController controller,
  }) {
    BoxDecoration deco() => BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: cs.surfaceContainerHighest.withOpacity(0.45),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        );

    if (isPaging) {
      return Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: deco(),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: cs.primary,
            ),
          ),
        ),
      );
    }

    if (hasMore) {
      return GestureDetector(
        onTap: onLoadMore,
        child: Container(
          width: 130,
          margin: const EdgeInsets.only(right: 12),
          decoration: deco(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: cs.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                "Load more",
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "+$_uiPageSize",
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (!controller.hasClients) return;
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: deco(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.first_page_rounded, color: cs.primary, size: 30),
            const SizedBox(height: 8),
            Text(
              "Start",
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "max $_maxItemsPerLane",
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _posterLane({
    required List<dynamic> items,
    required ScrollController controller,
    required bool isPaging,
    required bool hasMore,
    required VoidCallback onLoadMore,
  }) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 200,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index < items.length) {
            final movie = items[index];
            final posterPath = movie['poster_path'];
            final posterUrl = posterPath == null
                ? null
                : "https://image.tmdb.org/t/p/w342$posterPath";

            return GestureDetector(
              onTap: () => _navigateToDetail(movie),
              child: Container(
                width: 130,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: cs.surfaceContainerHighest.withOpacity(0.35),
                  image: posterUrl == null
                      ? null
                      : DecorationImage(
                          image: NetworkImage(posterUrl),
                          fit: BoxFit.cover,
                        ),
                ),
                child: posterUrl == null
                    ? Center(
                        child: Icon(Icons.broken_image_outlined,
                            color: cs.onSurfaceVariant),
                      )
                    : null,
              ),
            );
          }

          return _footerCard(
            cs: cs,
            isPaging: isPaging,
            hasMore: hasMore,
            onLoadMore: onLoadMore,
            controller: controller,
          );
        },
      ),
    );
  }

  // -----------------------------
  // Build
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_trendingMovies.isEmpty) {
      return Center(
        child: Text("No data", style: TextStyle(color: colorScheme.onSurface)),
      );
    }

    final topMovie = _trendingMovies[0];
    final String? posterPath = topMovie['poster_path'];
    final String posterUrl =
        posterPath == null ? "" : "https://image.tmdb.org/t/p/w780$posterPath";

    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          // HERO
          if (isLandscape)
            Container(
              height: screenHeight * 0.6,
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 10),
              child: Row(
                children: _trendingMovies.take(3).map((movie) {
                  final String? p = movie['poster_path'];
                  final String? img =
                      p == null ? null : "https://image.tmdb.org/t/p/w780$p";
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToDetail(movie),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                          image: img == null
                              ? null
                              : DecorationImage(
                                  image: NetworkImage(img),
                                  fit: BoxFit.cover,
                                ),
                          color: img == null
                              ? colorScheme.surfaceContainerHighest
                              : null,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.deepPurple.withOpacity(0.7)
                              ],
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            movie['title'] ?? movie['name'] ?? "Untitled",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          else
            GestureDetector(
              onTap: () => _navigateToDetail(topMovie),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: posterUrl.isEmpty
                      ? null
                      : DecorationImage(
                          image: NetworkImage(posterUrl),
                          fit: BoxFit.cover,
                        ),
                  color: posterUrl.isEmpty
                      ? colorScheme.surfaceContainerHighest
                      : null,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        topMovie['title'] ?? topMovie['name'] ?? "Untitled",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

          // TRENDING
          _sectionHeader("Trending Now"),
          _posterLane(
            items: _trendingMovies,
            controller: _trendingCtrl,
            isPaging: _isTrendingPaging,
            hasMore: _trendingHasMore,
            onLoadMore: _loadMoreTrending,
          ),

          // COMING SOON
          _sectionHeader("Coming Soon"),
          if (_isUpcomingLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_upcomingMovies.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                "No coming soon data",
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            )
          else
            _posterLane(
              items: _upcomingMovies,
              controller: _upcomingCtrl,
              isPaging: _isUpcomingPaging,
              hasMore: _upcomingHasMore,
              onLoadMore: _loadMoreUpcoming,
            ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
