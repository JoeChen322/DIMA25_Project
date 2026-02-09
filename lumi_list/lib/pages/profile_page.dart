import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumi_list/database/user.dart'; // your updated Firebase-based UserDao

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
    Navigator.pushNamedAndRemoveUntil(
        context, '/', (route) => false); // AuthGate handles routing
  }

  @override
  Widget build(BuildContext context) {
    final fallbackEmail = FirebaseAuth.instance.currentUser?.email ?? "N/A";

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
            child: StreamBuilder(
              stream: UserDao.profileStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Colors.deepPurpleAccent),
                  );
                }

                // If not logged in, profileStream() may be empty
                if (!snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Not logged in",
                            style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text("Go to Login"),
                        ),
                      ],
                    ),
                  );
                }

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Profile",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded,
                                color: Colors.deepPurpleAccent, size: 28),
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
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.deepPurpleAccent.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white.withOpacity(0.05),
                            backgroundImage: hasNetworkAvatar
                                ? NetworkImage(avatarUrl!)
                                : null,
                            child: !hasNetworkAvatar
                                ? const Icon(Icons.person_rounded,
                                    size: 60, color: Colors.white24)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bio,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14),
                      ),
                      const SizedBox(height: 40),
                      _buildDarkInfoTile("Email", email, Icons.email_rounded),
                      _buildDarkInfoTile(
                          "Phone", phone, Icons.phone_iphone_rounded),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.redAccent, size: 20),
                          label: const Text("Log Out",
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 16)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.redAccent.withOpacity(0.1),
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
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurpleAccent, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      color: Colors.white,
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
