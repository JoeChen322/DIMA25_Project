import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumi_list/database/user.dart'; 
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _navigateToEdit({
    required String name,
    required String bio,
    required String phone,
    required String? avatarUrl,
    required String email,
  }) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit_profile',
      arguments: {
        'name': name,
        'bio': bio,
        'phone': phone,
        'avatar': avatarUrl,
        'email': email,
      },
    );

    if (result != null && result is Map<String, dynamic>) {
      await UserDao.updateUser(
        username: (result['name'] ?? name).toString(),
        bio: (result['bio'] ?? bio).toString(),
        phone: (result['phone'] ?? phone).toString(),
        avatarUrl: result['avatar']?.toString(),
      );
    }
  }

  Future<void> _logout() async {
    await UserDao.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    //get current theme and color scheme for dynamic styling
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    
    // use email from FirebaseAuth as fallback if profile data doesn't have email 
    final fallbackEmail = FirebaseAuth.instance.currentUser?.email ?? "N/A";

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
            child: StreamBuilder(
              stream: UserDao.profileStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: colorScheme.primary),
                  );
                }

                // check if user is logged in and has profile data
                if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Not logged in",
                            style: TextStyle(color: colorScheme.onSurface)),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text("Go to Login"),
                        ),
                      ],
                    ),
                  );
                }

                // data is available, extract user info with fallbacks
                final doc = snapshot.data;
                final data = (doc as dynamic).data() as Map<String, dynamic>?;

                final name = (data?['username'] ?? "Movie Fan").toString();
                final bio = (data?['bio'] ?? "LumiList User").toString();
                final phone = (data?['phone'] ?? "N/A").toString();
                final email = (data?['email'] ?? fallbackEmail).toString();
                final avatarUrl = data?['avatarUrl']?.toString();

                final bool hasNetworkAvatar = avatarUrl != null &&
                    avatarUrl.isNotEmpty &&
                    avatarUrl.startsWith('http');

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      //top bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                color: colorScheme.onSurface, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            "Profile",
                            style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_note_rounded,
                                color: colorScheme.primary, size: 28),
                            onPressed: () => _navigateToEdit(
                              name: name,
                              bio: bio,
                              phone: phone,
                              avatarUrl: avatarUrl,
                              email: email,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // profile photo
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            backgroundImage: hasNetworkAvatar
                                ? NetworkImage(avatarUrl!)
                                : null,
                            child: !hasNetworkAvatar
                                ? Icon(Icons.person_rounded,
                                    size: 60, color: colorScheme.onSurfaceVariant.withOpacity(0.5))
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // basic info (name and bio)
                      Text(
                        name,
                        style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bio,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: colorScheme.onSurfaceVariant, fontSize: 14),
                      ),
                      const SizedBox(height: 40),
                      // contact info tiles
                      _buildDarkInfoTile("Email", email, Icons.email_rounded, colorScheme, isDark),
                      _buildDarkInfoTile("Phone", phone, Icons.phone_iphone_rounded, colorScheme, isDark),
                      const SizedBox(height: 50),
                      // logout button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _logout,
                          icon: Icon(Icons.logout_rounded,
                              color: colorScheme.error, size: 20),
                          label: Text("Log Out",
                              style: TextStyle(
                                  color: colorScheme.error, fontSize: 16)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: colorScheme.error.withOpacity(isDark ? 0.1 : 0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}