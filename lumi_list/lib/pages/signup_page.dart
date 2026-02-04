import 'package:flutter/material.dart';
import 'package:lumi_list/database/app_database.dart'; 

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final Color _primaryColor = Colors.deepPurple;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), 
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1_rounded, size: 60, color: _primaryColor),
              const SizedBox(height: 20),
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, color: Colors.grey[900]
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign up to get started!",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // --- Signup Form ---
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email
                      _buildLabel("Email"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: "hello@example.com",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Password
                      _buildLabel("Password"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: "••••••••",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        obscureText: _obscurePassword,
                        onToggleVisibility: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password
                      _buildLabel("Confirm Password"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: "••••••••",
                        icon: Icons.lock_reset,
                        isPassword: true,
                        obscureText: _obscureConfirmPassword,
                        onToggleVisibility: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                      ),

                      const SizedBox(height: 30),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          // Disable button while loading
                          onPressed: _isLoading ? null : () async {
                            // --- 1. Validation Logic ---
                            if (_emailController.text.isEmpty || 
                                _passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please fill in all fields"), backgroundColor: Colors.redAccent)
                                );
                                return;
                            }
                            if (!_emailController.text.contains('@')) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Invalid email address"), backgroundColor: Colors.redAccent)
                                );
                                return;
                            }
                            if (_passwordController.text != _confirmPasswordController.text) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.redAccent)
                                );
                                return;
                            }

                            // --- 2. Database Insertion Logic ---
                            setState(() => _isLoading = true);

                            try {
                              // Get the database instance
                              final db = await AppDatabase.database;

                              // Create a default username (e.g., "chriss" from "chriss@gmail.com")
                              String defaultUsername = _emailController.text.split('@')[0];

                              // Insert into 'users' table
                              await db.insert('users', {
                                'email': _emailController.text,
                                'password': _passwordController.text, // In real apps, hash this!
                                'username': defaultUsername,
                              });

                              if (!mounted) return;

                              // Success!
                              ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text("Account Created! Please Login."), backgroundColor: Colors.green)
                              );
                              
                              // Return to Login Page
                              Navigator.pop(context, {
                                'email': _emailController.text,
                                'password': _passwordController.text,
                              });

                            } catch (e) {
                              // Handle errors (like duplicate email)
                              print("Sign up error: $e");
                              if (!mounted) return;

                              String errorMessage = "Registration failed";
                              // Check if error is because email already exists (Unique constraint)
                              if (e.toString().contains("UNIQUE constraint failed")) {
                                errorMessage = "This email is already registered.";
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent)
                              );
                            } finally {
                              // Stop loading spinner regardless of success or failure
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading 
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- Return to Login ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Return to Login Page
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}