/*edit user profile info, including avatar, name, bio, phone number*/
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lumi_list/database/app_database.dart';
import 'package:lumi_list/database/user.dart';
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
    _loadDataFromDb();
  }

  // data from database
// profile_page.dart

Future<void> _loadDataFromDb() async {
  try {
    final db = await AppDatabase.database;
    int? currentId = UserDao.getCurrentUserId();
    
    if (currentId == null) {
      print("Error: No user logged in (ID is null)");
      setState(() => _isLoading = false);
      return;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [currentId],
    );

    if (maps.isNotEmpty) {
      final userData = maps.first;
      setState(() {
        _name = userData['username'] ?? "Movie Fan";
        _bio = userData['bio'] ?? "LumiList User";
        _phone = userData['phone'] ?? "N/A";
        _avatarPath = userData['avatar'] == 'NA' ? null : userData['avatar'];
        _email = userData['email']; 
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  } catch (e) {
    print("Database Error: $e");
    setState(() => _isLoading = false);
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
      await UserDao.updateUser(
      id: UserDao.getCurrentUserId()!,
      username: result['name'],
      bio: result['bio'],
      phone: result['phone'],
      avatar: result['avatar'],
    );
      await _loadDataFromDb(); 
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
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
                color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          
          SafeArea(
            child: _isLoading 
              ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // AppBar 
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Profile",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_note_rounded, color: colorScheme.primary, size: 28),
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
                            border: Border.all(color: colorScheme.primary.withOpacity(0.5), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            backgroundImage: (_avatarPath != null && _avatarPath!.isNotEmpty) 
                                ? FileImage(File(_avatarPath!)) 
                                : null,
                            child: (_avatarPath == null || _avatarPath!.isEmpty)
                                ? Icon(Icons.person_rounded, size: 60, color: colorScheme.onSurfaceVariant.withOpacity(0.5)) 
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(_name, style: TextStyle(color: colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_bio, textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),

                      const SizedBox(height: 40),

                      // list tiles
                      _buildDarkInfoTile("Email", _email ?? "N/A", Icons.email_rounded, colorScheme, isDark),
                      _buildDarkInfoTile("Phone", _phone, Icons.phone_iphone_rounded, colorScheme, isDark),
                      
                      const SizedBox(height: 50),
                      
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                          icon: Icon(Icons.logout_rounded, color: colorScheme.error, size: 20),
                          label: const Text("Log Out", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: colorScheme.error.withOpacity(isDark ? 0.1 : 0.05),
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

  Widget _buildDarkInfoTile(String label, String value, IconData icon, ColorScheme colorScheme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}