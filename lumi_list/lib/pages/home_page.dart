import 'package:flutter/material.dart';
import 'search_page.dart';
import 'me_page.dart';
import 'movie_detail.dart';
import '../services/tmdb_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialIndex = 1});

  /// For tests (and optionally future UX): start on a specific tab.
  /// 0 = Search, 1 = Home, 2 = Me
  final int initialIndex;

  // Stable keys for tests
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

  List<dynamic> _trendingMovies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    try {
      final movies = await tmdbService.getTrendingMovies();
      if (mounted) {
        setState(() {
          _trendingMovies = movies
              .where(
                  (m) => m['media_type'] == 'movie' || m['media_type'] == null)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MovieDetailPage(movie: movieData)),
      );
    }
  }

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
    final String posterUrl =
        "https://image.tmdb.org/t/p/w780${topMovie['poster_path']}";
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Column(
        children: [
          if (isLandscape)
            Container(
              height: screenHeight * 0.6,
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 10),
              child: Row(
                children: _trendingMovies.take(3).map((movie) {
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
                          image: DecorationImage(
                            image: NetworkImage(
                              "https://image.tmdb.org/t/p/w780${movie['poster_path']}",
                            ),
                            fit: BoxFit.cover,
                          ),
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
                            movie['title'] ?? movie['name'],
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
                  image: DecorationImage(
                      image: NetworkImage(posterUrl), fit: BoxFit.cover),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Trending Now",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount:
                  _trendingMovies.length > 8 ? 8 : _trendingMovies.length,
              itemBuilder: (context, index) {
                final movie = _trendingMovies[index];
                return GestureDetector(
                  onTap: () => _navigateToDetail(movie),
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://image.tmdb.org/t/p/w342${movie['poster_path']}",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
