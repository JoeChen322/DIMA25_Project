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
      version: 7,
      onCreate: (db, version) async {
        

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
          CREATE TABLE favorites (
            user_id INTEGER,
            imdb_id TEXT,
            title TEXT,
            poster STRING,
            genre TEXT,
            rating INTEGER,
            PRIMARY KEY (user_id, imdb_id)
          )
        ''');
        // Personal ratings table
        await db.execute('''
          CREATE TABLE personal_ratings (
            user_id INTEGER,
            imdb_id TEXT,
            title TEXT,
            rating INTEGER,
            timestamp INTEGER,
            PRIMARY KEY (user_id, imdb_id)
          )
        ''');
        // See Later table
          await db.execute('''
            CREATE TABLE see_later (
              user_id INTEGER,
              imdb_id TEXT,
              title TEXT,
              poster TEXT,
              PRIMARY KEY (user_id, imdb_id)
            )
          ''');
      },
    onUpgrade: (db, oldVersion, newVersion) async {
    if (oldVersion < 7) {
    await db.execute('CREATE TABLE IF NOT EXISTS personal_ratings (user_id INTEGER, imdb_id TEXT, title TEXT, rating INTEGER, timestamp INTEGER, PRIMARY KEY (user_id, imdb_id))');
    await db.execute('CREATE TABLE IF NOT EXISTS see_later (user_id INTEGER, imdb_id TEXT, title TEXT, poster TEXT, PRIMARY KEY (user_id, imdb_id))');
    await db.execute('CREATE TABLE IF NOT EXISTS favorites (user_id INTEGER, imdb_id TEXT, title TEXT, poster TEXT, genre TEXT, rating INTEGER, PRIMARY KEY (user_id, imdb_id))');
        }
},
    );
    
  }
}
