import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../database/user.dart';
import 'classics_page.dart';
import 'favorite_page.dart';

class MyListPage extends StatelessWidget {
  final String? email; // optional fallback
  const MyListPage({super.key, this.email});

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
            top: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(isDark ? 0.2 : 0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: UserDao.profileStream(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() ?? <String, dynamic>{};

                final fallbackEmail =
                    FirebaseAuth.instance.currentUser?.email ?? email ?? "N/A";

                final name = (data['username'] ?? "Movie Fan").toString();
                final shownEmail = (data['email'] ?? fallbackEmail).toString();

                final avatarUrlRaw = data['avatarUrl']?.toString();
                final avatarUrl = (avatarUrlRaw == null ||
                        avatarUrlRaw.isEmpty ||
                        avatarUrlRaw == 'NA')
                    ? null
                    : avatarUrlRaw;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: _ProfileHeader(
                          name: name,
                          email: shownEmail,
                          avatarUrl: avatarUrl,
                          colorScheme: colorScheme,
                          isDark: isDark,
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                        child: Text(
                          "My Movie Lists",
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
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
                                MaterialPageRoute(
                                  builder: (context) => const FavoritePage(),
                                ),
                              );
                            },
                            child: _buildDarkItem(
                              context,
                              Colors.amber,
                              "Favorites",
                              Icons.star_rounded,
                              colorScheme,
                              isDark,
                            ),
                          ),

                          // ----------Watch Later ---------------
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/seelater'),
                            child: _buildDarkItem(
                              context,
                              Colors.redAccent,
                              "Watch Later",
                              Icons.access_time_filled_rounded,
                              colorScheme,
                              isDark,
                            ),
                          ),

                          //------------- IMDb Classics----------------
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ClassicsPage(),
                                ),
                              );
                            },
                            child: _buildDarkItem(
                              context,
                              Colors.blueAccent,
                              "IMDb Classics",
                              Icons.movie_filter_rounded,
                              colorScheme,
                              isDark,
                            ),
                          ),

                          // -----------------My Profile------------
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/profile'),
                            child: _buildDarkItem(
                              context,
                              const Color(0xFF00E5FF),
                              "My Profile",
                              Icons.person_rounded,
                              colorScheme,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
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

  Widget _buildDarkItem(
    BuildContext context,
    Color color,
    String title,
    IconData icon,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? color.withOpacity(0.05) : Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.1),
        ),
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
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final ColorScheme colorScheme;
  final bool isDark;
  final VoidCallback onTap;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.colorScheme,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetworkAvatar = avatarUrl != null && avatarUrl!.startsWith('http');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest.withOpacity(0.55)
              : Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: colorScheme.primary.withOpacity(0.12),
              backgroundImage:
                  hasNetworkAvatar ? NetworkImage(avatarUrl!) : null,
              child: !hasNetworkAvatar
                  ? Icon(
                      Icons.person_rounded,
                      color: colorScheme.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, $name",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
