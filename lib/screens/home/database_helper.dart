import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'item.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<List<Map<String, dynamic>>> getItems() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> items = await db.query(
        'items',
        orderBy: 'timestamp DESC',
      );
      
      // Convert the integer ID to string before returning
      return items.map((item) {
        return {
          ...item,
          'id': item['id'].toString(), // Convert ID to string
        };
      }).toList();
      
    } catch (e) {
      print('Error getting items: $e');
      return [];
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('barter.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Delete existing database to avoid migration issues during development
    await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT NOT NULL,
      imagePath TEXT NOT NULL,
      uploadedBy TEXT NOT NULL,
      rating REAL NOT NULL,
      category TEXT,
      location TEXT,
      timestamp INTEGER NOT NULL,
      status TEXT DEFAULT 'available'
    )
    ''');
  }



  Future<List<Map<String, dynamic>>> getUserItems(String username) async {
    try {
      final db = await database;
      return await db.query(
        'items',
        where: 'uploadedBy = ?',
        whereArgs: [username],
        orderBy: 'timestamp DESC',
      );
    } catch (e) {
      print('Error getting user items: $e');
      return [];
    }
  }

  Future<int> insertItem(Map<String, dynamic> item) async {
    try {
      final db = await database;
      
      // Ensure all required fields are present
      final requiredFields = {
        'name': item['name'],
        'description': item['description'],
        'imagePath': item['imagePath'],
        'uploadedBy': item['uploadedBy'],
        'rating': item['rating'],
        'category': item['category'],
        'location': item['location'],
      };

      // Check if any required field is missing
      final missingFields = requiredFields.entries
          .where((entry) => entry.value == null)
          .map((entry) => entry.key)
          .toList();

      if (missingFields.isNotEmpty) {
        throw Exception('Missing required fields: ${missingFields.join(', ')}');
      }

      // Add timestamp and status
      item['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      item['status'] = 'available';

      final id = await db.insert(
        'items',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print('Successfully inserted item with ID: $id');
      return id;
    } catch (e) {
      print('Error inserting item: $e');
      return -1;
    }
  }

  Future<Map<String, dynamic>?> getItemById(int id) async {
    try {
      final db = await database;
      final results = await db.query(
        'items',
        where: 'id = ?',
        whereArgs: [id],
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      print('Error getting item by id: $e');
      return null;
    }
  }
}