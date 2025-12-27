import 'package:flutter/material.dart';
import 'search_page.dart';
import 'my_list.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 1; // 默认显示中间的 Home

  // ... 在 _index = 1; 下面加入 ...

  bool _isInit = false; // 加上这个标记，防止重复刷新

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // 🕵️‍♂️ 侦查：看看有没有人（比如登录页）给我传了数据？
      final args = ModalRoute.of(context)?.settings.arguments;
      
      if (args != null && args is Map) {
        setState(() {
          // 如果有，就覆盖掉默认的 "Movie Lover"
          if (args['name'] != null) _userName = args['name'];
          if (args['bio'] != null) _userBio = args['bio'];
          if (args['avatar'] != null) _drawerAvatarPath = args['avatar'];
        });
      }
      _isInit = true; // 标记已处理
    }
  }

  // 🔥 1. 中央档案室：存住用户的所有信息
  String _userName = "Movie Lover"; 
  String _userBio = "Write something..."; 
  String _userPhone = "";
  String? _drawerAvatarPath; // 存头像路径

  final List<Widget> _pages = const [
    SearchPage(),
    HomeContent(),
    MyListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LumiList", 
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 头像区域
            UserAccountsDrawerHeader(
              // 🔥 2. 注意：这里去掉了 const，因为里面用了变量
              decoration: const BoxDecoration(color: Colors.deepPurple),
              
              // 🔥 3. 核心修改：这里使用变量 _userName，而不是死文字
              accountName: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text("hello@example.com"),
              
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                // A. 背景图逻辑
                backgroundImage: _drawerAvatarPath != null
                    ? FileImage(File(_drawerAvatarPath!))
                    : null,
                // B. 图标逻辑
                child: _drawerAvatarPath == null
                    ? const Icon(Icons.person, size: 40, color: Colors.deepPurple)
                    : null,
              ),
            ),
            
            // My Profile 按钮
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.deepPurple),
              title: const Text("My Profile", style: TextStyle(color: Colors.black)),
              onTap: () async {
                Navigator.pop(context); // 关侧边栏
                
                // 🔥 4. 关键点：进去时，把“中央档案”传给 ProfilePage
                final result = await Navigator.pushNamed(
                  context, 
                  '/profile',
                  arguments: {
                    'name': _userName,
                    'bio': _userBio,
                    'phone': _userPhone,
                    'avatar': _drawerAvatarPath,
                  }
                );
                
                // 🔥 5. 关键点：回来时，接收 Map 数据并更新“中央档案”
                if (result != null && result is Map) {
                  setState(() {
                    if (result['name'] != null) _userName = result['name'];
                    if (result['bio'] != null) _userBio = result['bio'];
                    if (result['phone'] != null) _userPhone = result['phone'];
                    if (result['avatar'] != null) _drawerAvatarPath = result['avatar'];
                  });
                }
              },
            ),

            const Divider(), 

            // 退出按钮
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Log Out", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context); 
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      
      body: _pages[_index],
      
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: "Search"),
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.list), label: "My List"),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("LumiList Home – Trending, Recommendations Coming Soon"),
    );
  }
}