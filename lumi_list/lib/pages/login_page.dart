import 'package:flutter/material.dart';
import '../database/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // Stable keys for tests
  static const Key kEmailField = Key('login_email');
  static const Key kPasswordField = Key('login_password');
  static const Key kLoginButton = Key('login_submit');
  static const Key kToSignupButton = Key('login_to_signup');

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Color _primaryColor = Colors.deepPurple;

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await UserDao.login(email, password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      // Map Firebase error codes to friendly messages
      final msg = switch (e.code) {
        'invalid-email' => 'Invalid email format.',
        'user-disabled' => 'This account has been disabled.',
        'user-not-found' => 'No account found for this email.',
        'wrong-password' => 'Incorrect password.',
        // Newer SDKs often return this for wrong email/password:
        'invalid-credential' => 'Incorrect email or password.',
        'too-many-requests' => 'Too many attempts. Try again later.',
        'network-request-failed' => 'Network error. Check your connection.',
        _ => 'Login failed. Please try again.',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateToSignup() async {
    final result = await Navigator.pushNamed(context, '/signup');
    if (result != null && result is Map && mounted) {
      setState(() {
        _emailController.text = result['email'] ?? '';
        _passwordController.text = result['password'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Background + card colors that look OK in both modes
    final pageBg = isDark ? colorScheme.surface : const Color(0xFFF5F5F5);
    final cardBg = isDark ? colorScheme.surfaceContainerHighest : Colors.white;

    // Responsive width: 92% on phones, grows on wide screens, but capped
    final w = MediaQuery.of(context).size.width;
    final double cardWidth = (w * 0.92).clamp(360.0, 560.0);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 24), // drift down
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Logo ---
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to continue to LumiList",
                  style: TextStyle(
                      fontSize: 16, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),

                // --- login card (responsive width) ---
                SizedBox(
                  width: cardWidth,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.10 : 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                      border: Border.all(
                        color: colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Email"),
                        const SizedBox(height: 8),
                        _buildMinimalTextField(
                          key: LoginPage.kEmailField,
                          controller: _emailController,
                          hintText: "hello@example.com",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildLabel("Password"),
                        const SizedBox(height: 8),
                        _buildMinimalTextField(
                          key: LoginPage.kPasswordField,
                          controller: _passwordController,
                          hintText: "••••••••",
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(
                                context, '/forgot_password'),
                            style: TextButton.styleFrom(
                                foregroundColor: _primaryColor),
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPrimaryButton(),
                        const SizedBox(height: 16),
                        _buildSecondaryButton(),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                Text(
                  "© 2026 LumiList. All rights reserved.",
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        key: LoginPage.kLoginButton,
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Login",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        key: LoginPage.kToSignupButton,
        onPressed: _isLoading ? null : _navigateToSignup,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _primaryColor.withOpacity(0.5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          foregroundColor: _primaryColor,
        ),
        child: const Text(
          "Create New Account",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildMinimalTextField({
    Key? key,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        key: key,
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
