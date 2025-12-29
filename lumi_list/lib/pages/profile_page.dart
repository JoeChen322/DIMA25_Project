import 'dart:io';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "User Name"; 
  String _bio = "Write something about yourself..."; 
  String _phone = "+39 123 456 7890"; 
  String? _avatarPath;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          if (args['name'] != null) _name = args['name'];
          if (args['bio'] != null) _bio = args['bio'];
          if (args['phone'] != null) _phone = args['phone'];
          if (args['avatar'] != null) _avatarPath = args['avatar'];
        });
      }
      _isInit = true;
    }
  }

  Future<void> _navigateToEdit() async {
    final result = await Navigator.pushNamed(
      context, 
      '/edit_profile',
      arguments: {
        'name': _name,
        'bio': _bio,
        'phone': _phone,
        'avatar': _avatarPath,
      }
    );
    
    if (result != null && result is Map) {
      setState(() {
        _name = result['name'];
        _bio = result['bio'];
        _phone = result['phone'];
        _avatarPath = result['avatar'];
      });
    }
  }

  void _goBack() {
    Navigator.pop(context, {
      'name': _name,
      'bio': _bio,
      'phone': _phone,
      'avatar': _avatarPath,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
               Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true, 
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            // --- Film and Television Archives ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Movie Archives", style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  // 3. 
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildArchiveItem("Wishlist", "0", ""), 
                        _buildArchiveItem("Watching", "0", ""), 
                        _buildArchiveItem("Watched", "0", ""), 
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // My Lists
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("My Lists", style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[600]),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 140, 
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildListItem(Colors.amber, "Favorites", Icons.star),
                  _buildListItem(Colors.redAccent, "Watch Later", Icons.access_time),
                  _buildListItem(Colors.blueAccent, "Classics", Icons.movie_filter),
                  _buildListItem(Colors.purple, "Custom List", Icons.add),
                ],
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

// --- Header component ---
  Widget _buildHeader() {
    return Container(
      // Add a little top padding to fit the notch screen.
      padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 20, 24, 30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF673AB7), // DeepPurple
            Color(0xFF512DA8), // DeepPurple[700]
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8), 
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          // Avatar section
          GestureDetector(
            onTap: _navigateToEdit,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), 
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40, 
                    backgroundColor: Colors.white,
                    backgroundImage: _avatarPath != null 
                        ? FileImage(File(_avatarPath!)) 
                        : null,
                    child: _avatarPath == null 
                        ? const Icon(Icons.person, size: 45, color: Colors.grey) 
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepPurple, width: 2), 
                    ),
                    child: const Icon(Icons.edit, size: 12, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Info section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "ID: 10001",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _navigateToEdit,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _bio.isNotEmpty ? _bio : "No bio yet...",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white.withOpacity(0.7)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Film and Television Archive Component ---
  Widget _buildArchiveItem(String label, String count, String imageUrl) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            // If no image is displayed, a gray square with an icon is shown.
            Container(
              width: 40, height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
                image: imageUrl.isNotEmpty 
                    ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                    : null,
              ),
              child: imageUrl.isEmpty 
                  ? const Center(child: Icon(Icons.movie_creation_outlined, color: Colors.grey, size: 20)) 
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(count, style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- List widget ---
  Widget _buildListItem(Color color, String title, IconData icon) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12, bottom: 5), 
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3)),
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), 
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}