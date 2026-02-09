import 'package:flutter/material.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart'; 
import 'database/user.dart';
import 'database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  String? savedEmail = await AuthService.getToken();
  
  String initialRoute = '/login';

  if (savedEmail != null && savedEmail.isNotEmpty) {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [savedEmail],
    );

    if (maps.isNotEmpty) {
      UserDao.setCurrentUser(maps.first['id'] as int, maps.first['email'] as String);
      initialRoute = '/'; 
    }
  }

  runApp(LumiListApp(initialRoute: initialRoute));
}