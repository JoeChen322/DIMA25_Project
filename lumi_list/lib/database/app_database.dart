/*Basic setting of sqlite database
Info of the users including account Email, password*/

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lumilist.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorites (
            imdb_id TEXT PRIMARY KEY,
            title TEXT,
            poster TEXT,
            rating INTEGER
          )
        ''');

        // User table for authentication
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            username TEXT,
            bio TEXT,           
            phone TEXT,         
            avatar TEXT         
          )
        ''');
        // Favorite movies table
        await db.execute('''
          CREATE TABLE favorite (
            imdb_id TEXT PRIMARY KEY,
            title TEXT,
            rating INTEGER,
            poster STRING
          )
        ''');
        // Personal ratings table
        await db.execute('''
          CREATE TABLE personal_rate (
            imdb_id TEXT PRIMARY KEY,
            title TEXT,
            rating INTEGER,
            timestamp INTEGER
          )
        ''');
        // See Later table
          await db.execute('''
            CREATE TABLE see_later (
              imdb_id TEXT PRIMARY KEY,
              title TEXT,
              poster TEXT
            )
          ''');
      },
    );
  }
}
