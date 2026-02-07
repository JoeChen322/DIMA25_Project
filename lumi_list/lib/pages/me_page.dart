import 'package:flutter/material.dart';
import 'dart:ui'; 
import 'classics_page.dart';
import 'favorite_page.dart';

class MyListPage extends StatelessWidget {
  final String? email; 

  const MyListPage({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F), 
      body: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      "ME",
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 34, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Text(
                      "My Movie Lists",
                      style: TextStyle(
                        color: Colors.grey, 
                        fontSize: 18, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                    children: [
                      // ---------------Favorites--------------------
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FavoritePage()),
                          );
                        },
                        child: _buildDarkItem(context, Colors.amber, "Favorites", Icons.star_rounded),
                      ),
                      
                      // ----------Watch Later ---------------
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/seelater'),
                        child: _buildDarkItem(context, Colors.redAccent, "Watch Later", Icons.access_time_filled_rounded),
                      ),
                      
                      //------------- IMDb Classics----------------
                      GestureDetector(
                        onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => const ClassicsPage()),
                            );
                       },
                       child: _buildDarkItem(context, Colors.blueAccent, "IMDb Classics", Icons.movie_filter_rounded),
                      ),

                      // -----------------My Profile------------
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/profile',
                            arguments: {
                              'name': 'User Name', 
                              'bio': 'Write something about yourself...',
                              'phone': '+39 123 456 7890',
                              'email': email, 
                              'avatar': null, 
                            },
                          );
                        },
                        child: _buildDarkItem(
                          context, 
                          const Color(0xFF00E5FF), 
                          "My Profile", 
                          Icons.person_rounded 
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkItem(BuildContext context, Color color, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15), 
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 15, 
              fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }
}