/*
  UserDao class for handling user-related database operations.
  This includes registration, login, and profile updates.
*/
import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class UserDao {
  static int? _currentUserId;
  static String? _currentUserEmail;

  static void setCurrentUser(int id, String email) {
    _currentUserId = id;
    _currentUserEmail = email; 
  }

  
  static int? getCurrentUserId() => _currentUserId;
  static String? getCurrentUserEmail() => _currentUserEmail;

  // register
  static Future<int> registerUser(String email, String password, String username) async {
    final db = await AppDatabase.database; 
    
    return await db.insert(
      'users', 
      {
        'id': null, // Let the database auto-increment the ID
        'email': email,
        'password': password,
        'username': username,
        'bio': 'NA',      
        'phone': 'NA',
        'avatar': 'NA',
      },
      conflictAlgorithm: ConflictAlgorithm.replace, 
    );
    //print("【Register Success】User ID set to: $id");
  }
  
  // login
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await AppDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) { 
      int id = maps.first['id'] as int;
      String userEmail = maps.first['email'] as String;
      setCurrentUser(id,userEmail); 
      return maps.first;  
    }
    return null;
  }

  // update user profile
  static Future<int> updateUser({
    required int id,
    required String username,
    required String bio,
    required String phone,
    String? avatar,
  }) async {
    final db = await AppDatabase.database;
    return await db.update(
      'users',
      {
        'username': username,
        'bio': bio,
        'phone': phone,
        'avatar': avatar,
      },
      where: 'id = ?',
      whereArgs: [getCurrentUserId()],
    );
  }
}