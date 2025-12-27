import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 🔥 主题色：深紫色
  final Color _primaryColor = Colors.deepPurple; 

  // ✨ 新增状态：控制加载和密码显示
  bool _isLoading = false;
  bool _obscurePassword = true;

  // ✨ 新增逻辑：处理登录
  Future<void> _handleLogin() async {
    // 收起键盘
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields"), backgroundColor: Colors.redAccent),
      );
      return; 
    }

    setState(() => _isLoading = true); // 开始转圈

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 150));

    if (_passwordController.text == "123456") {
      if (!mounted) return;
      
      // 登录成功，带着数据去主页！
      Navigator.pushReplacementNamed(
        context, 
        '/',
        arguments: {
          'name': _emailController.text.split('@')[0], 
          'bio': 'Logged in via email',
          'avatar': null, 
        }
      );
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false); // 停，报错
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong password! Try: 123456"), backgroundColor: Colors.redAccent)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // ✅ 保持你的浅灰背景
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Logo (保持原样) ---
              // 🌟 登录页：改用新的透明图片
              // lib/pages/login_page.dart

              // --- Logo 区域 ---
              // --- 登录页 Logo 区域 ---
              // --- Login Page Logo 区域 ---
              // 把它做成一个精致的“App图标”样式
              Container(
                width: 80, 
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.black, // 背景纯黑
                  borderRadius: BorderRadius.circular(20), // 🔥 关键：设置圆角 (比如 20)
                  // 加一点阴影，让它立体起来
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                // 裁切掉多余的直角，防止图片溢出
                clipBehavior: Clip.hardEdge, 
                
                child: Padding(
                  padding: const EdgeInsets.all(12.0), // 内部稍微留点呼吸感
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

              // --- 登录卡片 (保持原样) ---
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
                        isPassword: true, // 开启密码功能
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot_password'); // 跳转忘记密码页
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _primaryColor,
                          ),
                          child: const Text("Forgot password?", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      // Login Button (只改了这里：加了加载状态)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin, // 加载时禁用
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

              // --- 分割线 (保持原样) ---
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

              // --- Google Login (保持原样) ---
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
              
              // Sign Up Text (保持原样)
               Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text("New User? ", style: TextStyle(color: Colors.grey[600])),
                  GestureDetector(
                    onTap: () async {
                        // 🔥 1. 加 await，等待注册页返回结果
                        final result = await Navigator.pushNamed(context, '/signup');
                        
                        // 🔥 2. 如果注册成功带回了数据
                        if (result != null && result is Map) {
                          setState(() {
                            // 自动填入邮箱
                            _emailController.text = result['email'];
                            // 自动填入密码
                            _passwordController.text = result['password'];
                          });
                          
                          // 提示用户
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

  // ✨ 稍微升级了输入框：加了小眼睛图标
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
        obscureText: isPassword ? _obscurePassword : false, // 根据状态显示/隐藏
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[500]),
          // 如果是密码框，显示切换按钮
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