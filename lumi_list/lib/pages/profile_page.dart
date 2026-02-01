import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lumi_list/database/app_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = "Movie Fan"; 
  String _bio = "LumiList User"; 
  String _phone = "N/A"; 
  String? _avatarPath;
  String? _email;
  bool _isLoading = true; 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_email == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['email'] != null) {
        _email = args['email'];
        _loadDataFromDb();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  // data from database
  Future<void> _loadDataFromDb() async {
    if (_email == null) return;
    
    try {
      final db = await AppDatabase.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [_email],
      );

      if (maps.isNotEmpty) {
        if (mounted) {
          setState(() {
            _name = maps.first['username'] ?? "User Name";
            _bio = maps.first['bio'] ?? "Write something about yourself...";
            _phone = maps.first['phone'] ?? "N/A";
            _avatarPath = maps.first['avatar'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      if (mounted) setState(() => _isLoading = false);
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
        'email': _email,
      }
    );

    if (result != null && result is Map<String, dynamic>) {
      await _updateUserInDatabase(result);
      await _loadDataFromDb(); 
    }
  }

  Future<void> _updateUserInDatabase(Map<String, dynamic> data) async {
    if (_email == null) return;
    final db = await AppDatabase.database;
    await db.update(
      'users',
      {
        'username': data['name'],
        'bio': data['bio'],
        'phone': data['phone'],
        'avatar': data['avatar'],
      },
      where: 'email = ?',
      whereArgs: [_email],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // AppBar 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Profile",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded, color: Colors.deepPurpleAccent, size: 28),
                            onPressed: _navigateToEdit,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Avatar
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.deepPurpleAccent.withOpacity(0.5), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            backgroundImage: (_avatarPath != null && _avatarPath!.isNotEmpty) 
                                ? FileImage(File(_avatarPath!)) 
                                : null,
                            child: (_avatarPath == null || _avatarPath!.isEmpty)
                                ? const Icon(Icons.person_rounded, size: 60, color: Colors.white24) 
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(_name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_bio, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 14)),

                      const SizedBox(height: 40),

                      // list tiles
                      _buildDarkInfoTile("Email", _email ?? "N/A", Icons.email_rounded),
                      _buildDarkInfoTile("Phone", _phone, Icons.phone_iphone_rounded),
                      
                      const SizedBox(height: 50),
                      
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                          label: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkInfoTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.deepPurpleAccent.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.deepPurpleAccent, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}