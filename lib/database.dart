import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static final table = 'passwords';
  static final columnId = 'id';
  static final columnSiteName = 'siteName';
  static final columnUsername = 'username';
  static final columnPassword = 'password';

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('passwords_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Define the table structure (Site, Username, Password) 
  Future _onCreate(Database db, int version) async {
    // Table for the passwords
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            userId INTEGER NOT NULL,
            $columnSiteName TEXT NOT NULL,
            $columnUsername TEXT NOT NULL,
            $columnPassword TEXT NOT NULL
          )
          ''');

    // Table for the app users (Login/Signup)
    await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
          ''');
  }

  Future<List<Map<String, dynamic>>> queryUserPasswords(int currentUserId) async {
    Database db = await instance.database;
    return await db.query(table, where: 'userId = ?', whereArgs: [currentUserId]);
  }

  // Add this helper method to the DatabaseHelper class
  /*
  Future<int> registerUser(String user, String pass) async {
    Database db = await instance.database;
    return await db.insert('users', {'username': user, 'password': pass});
  }
   */
  Future<int> registerUser(String username, String password) async {
    Database db = await instance.database;

    // check if the username is already taken
    List<Map> existingUsers = await db.query(
      'users', // make sure this matches actual table name
      where: 'username = ?',
      whereArgs: [username],
    );

    // 2. If the list is not empty, Return -1 as an error code.
    if (existingUsers.isNotEmpty) {
      return -1; 
    }

    // 3. If the name is free, create the account.
    return await db.insert('users', {
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> loginUser(String user, String pass) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query('users',
        where: 'username = ? AND password = ?', whereArgs: [user, pass]);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  // Create (Add) 
  Future<int> addEntry(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('passwords', row);
  }

  // Read (View) 
  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await instance.database;
    return await db.query('passwords');
  }

  // Update (Modify) 
  Future<int> updateEntry(Map<String, dynamic> row) async {
    final db = await instance.database;
    int id = row['id'];
    return await db.update('passwords', row, where: 'id = ?', whereArgs: [id]);
  }

  // Delete (Remove)
  Future<int> deleteEntry(int id) async {
    final db = await instance.database;
    return await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }
}