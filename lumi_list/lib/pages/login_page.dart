import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//database
import 'package:lumi_list/database/app_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // set the primary color
  final Color _primaryColor = Colors.deepPurple; 

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _handleLogin() async {
    // 1. Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields"), backgroundColor: Colors.redAccent),
      );
      return; 
    }

    setState(() => _isLoading = true); // show loading indicator

    try {
      // 2. Get database instance
      // singleton you wrote in app_database.dart.
      final db = await AppDatabase.database;

      // 3. Query the users table
      // Search the users table for rows where both the email and password match.
      List<Map> result = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [_emailController.text, _passwordController.text],
      );

      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return; // safety check

      // 4. Handle query result
      if (result.isNotEmpty) {
        var user = result.first; // Get the first matching data

        Navigator.pushReplacementNamed(
          context, 
          '/', 
          arguments: {
            // Use the real username stored in the database.
            'name': user['username'], 
            'bio': user['bio'] ?? 'Write something about yourself...',
            'phone': user['phone'] ?? '+39 123 456 7890',
            'avatar': user['avatar'], 
            'email': _emailController.text, // Pass email for future use
          }
        );
      } else {
        // Invalid credentials
        setState(() => _isLoading = false); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid email or password"), 
            backgroundColor: Colors.redAccent
          )
        );
      }
    } catch (e) {
      // Database error
      setState(() => _isLoading = false);
      print("Database Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Logo and Welcome Text ---
              Container(
                width: 80, 
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black, 
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  // shadow effect
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                // clip the image to rounded corners
                clipBehavior: Clip.hardEdge, 
                
                child: Padding(
                  padding: const EdgeInsets.all(12.0), 
                  child: Image.asset(
                    'assets/icon/icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[900],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sign in to continue to LumiList",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              
              const SizedBox(height: 40),

              // --- Email & Password Fields ---
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
                      _buildLabel("Email"),
                      const SizedBox(height: 8),
                      _buildMinimalTextField(
                        controller: _emailController,
                        hintText: "hello@example.com",
                        icon: Icons.email_outlined,
                      ),
                      
                      const SizedBox(height: 20),

                      _buildLabel("Password"),
                      const SizedBox(height: 8),
                      _buildMinimalTextField(
                        controller: _passwordController,
                        hintText: "••••••••",
                        icon: Icons.lock_outline,
                        isPassword: true, // indicate it's a password field
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot_password'); // sink to ForgotPasswordPage
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _primaryColor,
                          ),
                          child: const Text("Forgot password?", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // Login Button 
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin, // disable when loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                )
                              : const Text(
                                  "Login", 
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // --- Divider with "Or login with" ---
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Or login with", style: TextStyle(color: Colors.grey[500])),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              
              const SizedBox(height: 24),

              // --- Social Login Buttons ---
              SizedBox(
                width: 400,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    print("Google Login Tapped");
                  },
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red, size: 20),
                  label: Text(
                    "Continue with Google",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Sign Up Text with tappable "Create Account"
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text("New User? ", style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () async {
                        // sink to SignupPage
                        final result = await Navigator.pushNamed(context, '/signup');
                        
                        // Receive data from SignupPage
                        if (result != null && result is Map) {
                          setState(() {
                            // automatic fill in email
                            _emailController.text = result['email'];
                            // automatic fill in password
                            _passwordController.text = result['password'];
                          });
                          
                          // show success snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Info filled! Please click Login."),
                              backgroundColor: Colors.deepPurple,
                            )
                          );
                        }
                      },
                    child: Text(
                      "Create Account",
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
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
      ),
    );
  }

  // Minimalistic TextField
  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false, // obscure or reveal for password
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          // If it's a password field, display the toggle button.
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}