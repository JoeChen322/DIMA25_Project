import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;

  Uint8List? _selectedImageBytes; // works on web + mobile
  String? _existingAvatarUrl; // existing network URL from Firestore
  String? _email;

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) return;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _nameController = TextEditingController(
      text: (args?['name'] ?? "Movie Lover").toString(),
    );
    _bioController = TextEditingController(
      text: (args?['bio'] ?? "I love watching sci-fi movies!").toString(),
    );
    _phoneController = TextEditingController(
      text: (args?['phone'] ?? "+39 123 456 7890").toString(),
    );

    _email = args?['email']?.toString();

    // args['avatar'] is a Firestore URL (string)
    final rawAvatar = args?['avatar'];
    if (rawAvatar != null) {
      final s = rawAvatar.toString().trim();
      if (s.startsWith('http')) _existingAvatarUrl = s;
    }

    _isInit = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes(); // key for web
    setState(() => _selectedImageBytes = bytes);
  }

  void _finish() {
    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'phone': _phoneController.text.trim(),

      // Return bytes instead of local path
      'avatarBytes': _selectedImageBytes,

      // keep existing URL if no new pick
      'existingAvatarUrl': _existingAvatarUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    ImageProvider? avatarProvider;
    if (_selectedImageBytes != null) {
      avatarProvider = MemoryImage(_selectedImageBytes!);
    } else if (_existingAvatarUrl != null &&
        _existingAvatarUrl!.startsWith('http')) {
      avatarProvider = NetworkImage(_existingAvatarUrl!);
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          Positioned(
            bottom: -100,
            left: -50,
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
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: _finish,
                        child: Text(
                          "Done",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        // Avatar picker
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colorScheme.outlineVariant,
                                      width: 1,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor:
                                        colorScheme.surfaceContainerHighest,
                                    backgroundImage: avatarProvider,
                                    child: avatarProvider == null
                                        ? Icon(
                                            Icons.person_rounded,
                                            size: 60,
                                            color: colorScheme.onSurfaceVariant
                                                .withOpacity(0.5),
                                          )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.primary.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt_rounded,
                                      size: 20,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        _buildGlassTextField(
                          "Username",
                          _nameController,
                          Icons.person_outline_rounded,
                          colorScheme,
                          isDark,
                        ),
                        const SizedBox(height: 20),
                        _buildGlassTextField(
                          "Bio",
                          _bioController,
                          Icons.info_outline_rounded,
                          colorScheme,
                          isDark,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        _buildGlassTextField(
                          "Phone",
                          _phoneController,
                          Icons.phone_android_rounded,
                          colorScheme,
                          isDark,
                        ),
                        const SizedBox(height: 20),
                        if (_email != null)
                          Text(
                            "Account: $_email",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    ColorScheme colorScheme,
    bool isDark, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
            cursorColor: colorScheme.primary,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: colorScheme.primary.withOpacity(0.8),
                size: 22,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}
