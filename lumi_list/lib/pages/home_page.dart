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
  int _index = 1; // default to Home tab

  bool _isInit = false; // Mark to prevent repeated refreshes

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      // Detect if there is data passed from the previous page
      final args = ModalRoute.of(context)?.settings.arguments;
      
      if (args != null && args is Map) {
        setState(() {
          // Update central profile data if passed
          if (args['name'] != null) _userName = args['name'];
          if (args['bio'] != null) _userBio = args['bio'];
          if (args['avatar'] != null) _drawerAvatarPath = args['avatar'];
        });
      }
      _isInit = true; 
    }
  }

  // Central profile data
  String _userName = "Movie Lover"; 
  String _userBio = "Write something..."; 
  String _userPhone = "";
  String? _drawerAvatarPath; // Path to avatar image in drawer

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
        backgroundColor: const Color.fromARGB(255, 227, 219, 240),
        foregroundColor: Colors.white,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Avatar header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 227, 219, 240)),
              
              // Use the variable _userName
              accountName: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text("hello@example.com"),
              
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                // A. Avatar logic
                backgroundImage: _drawerAvatarPath != null
                    ? FileImage(File(_drawerAvatarPath!))
                    : null,
                // B. Fallback icon
                child: _drawerAvatarPath == null
                    ? const Icon(Icons.person, size: 40, color: Colors.deepPurple)
                    : null,
              ),
            ),
            
            // My Profile button
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.deepPurple),
              title: const Text("My Profile", style: TextStyle(color: Colors.black)),
              onTap: () async {
                Navigator.pop(context); // Close the drawer
                
                // Upon entry, pass the data to ProfilePage.
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
                
                //  update data when returning from ProfilePage
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

            //  Log Out button
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