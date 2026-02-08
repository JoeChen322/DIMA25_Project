/* In ME/Watch Later Page 
to display the list of movies marked to watch later */

import 'package:flutter/material.dart';
import '../database/seelater.dart'; 
import 'movie_detail.dart';

import 'package:flutter/material.dart';
import 'movie_detail.dart';
import '../database/seelater.dart';

class SeeLaterPage extends StatefulWidget {
  const SeeLaterPage({super.key});

  @override
  State<SeeLaterPage> createState() => _SeeLaterPageState();
}

class _SeeLaterPageState extends State<SeeLaterPage> {
  bool _isSyncing = false; 

  
  void _refresh() {
    setState(() {});
  }

  Future<void> _handleSync() async {
    setState(() => _isSyncing = true);
    try {
      await SeeLaterDao.syncWithFirebase();
      _refresh(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sync completed!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sync failed: $e")),
      );
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Watch Later", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // --- sys button ---
        actions: [
          _isSyncing
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20, height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.sync, color: Colors.white),
                  onPressed: _handleSync,
                ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: SeeLaterDao.getSeeLaterMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Your list is empty", style: TextStyle(color: Colors.grey)),
            );
          }

          final movies = snapshot.data!;

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      movie['poster'] ?? "",
                      width: 60, height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, e, s) => 
                          Container(width: 60, height: 90, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    movie['title'] ?? "Unknown",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    movie['year'] ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailPage(movie: {
                          'imdbID': movie['imdb_id'],
                          'Title': movie['title'],
                          'Poster': movie['poster'],
                          'Year': movie['year']
                        }),
                      ),
                    ).then((_) => _refresh()); 
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}