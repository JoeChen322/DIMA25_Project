import 'package:flutter/material.dart';
import 'search_page.dart';
import 'me_page.dart'; // 
import 'movie_detail.dart';
import '../services/tmdb_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 1; 
  String? _userEmail; // received email from LoginPage

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // retrieve email from arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args.containsKey('email')) {
      setState(() {
        _userEmail = args['email'];
      });
    }
  }

  // logical body builder
  Widget _buildBody() {
    switch (_index) {
      case 0:
        return const SearchPage();
      case 2:
        // pass email to MePage
        // ignore: prefer_if_null_operators
        return MyListPage(email: _userEmail);
      default:
        return const HomeContent(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true, 
      
      appBar: _index == 2 
    ? null  
    : AppBar(
        title: const Text("LumiList", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent, 
        elevation: 0,
        foregroundColor: Colors.white,
      ),

      body: _buildBody(),

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        height: 65,
        indicatorColor: Colors.deepPurple.withOpacity(0.5),
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search, color: Colors.white, size: 22),
            label: "Search",
          ),
          NavigationDestination(
            icon: Icon(Icons.home, color: Colors.white, size: 22), 
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: Colors.white, size: 22), 
            label: "Me",
          ),
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
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJlNWUxYTU5ODc0YzMwZDlmMWM2NTJlYjllZDQ4MmMzMyIsIm5iZiI6MTc2NjQzOTY0Mi40NTIsInN1YiI6IjY5NDliYWRhNTNhODI1Nzk1YzE1NTk5OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.V0Z-rlGFtBKfCUHFx3nNnqxVNoJ-T3YNVDF8URfMj4U');

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
          _trendingMovies = movies;
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
          builder: (context) => MovieDetailPage(movie: movieData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_trendingMovies.isEmpty) return const Center(child: Text("No data", style: TextStyle(color: Colors.white)));

    final topMovie = _trendingMovies[0];
    final String posterUrl = "https://image.tmdb.org/t/p/w780${topMovie['poster_path']}";

    return SingleChildScrollView(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _navigateToDetail(topMovie),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(image: NetworkImage(posterUrl), fit: BoxFit.cover),
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
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Trending Now", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount:_trendingMovies.length > 5 ? 5 : _trendingMovies.length,
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
                        image: NetworkImage("https://image.tmdb.org/t/p/w342${movie['poster_path']}"),
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