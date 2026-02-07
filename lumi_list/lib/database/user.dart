import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class UserDao {
  static int? _currentUserId;

  static void setCurrentUser(int id) {
    _currentUserId = id;
  }

  
  static int? getCurrentUserId() {
    return _currentUserId;
  }

  // register
  static Future<int> registerUser(String email, String password, String username) async {
    final db = await AppDatabase.database;
    return await db.insert('users', {
      'email': email,
      'password': password,
      'username': username,
    });
  }

  // login
  static Future<int?> login(String email, String password) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) { 
      int id = maps.first['id'] as int;
      setCurrentUser(id); 
      return id;
    }
    return null;
  }
}