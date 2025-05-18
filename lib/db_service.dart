import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'duygupan.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE moods(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mood INTEGER,
            note TEXT,
            date TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE habits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            isDone INTEGER,
            date TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE journals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            note TEXT,
            date TEXT
          );
        ''');
      },
    );
  }

  // Mood ekle
  static Future<void> insertMood(int mood, String? note, String date) async {
    final db = await database;
    await db.insert('moods', {
      'mood': mood,
      'note': note,
      'date': date,
    });
  }

  // Alışkanlık ekle/güncelle
  static Future<void> insertOrUpdateHabit(String name, bool isDone, String date) async {
    final db = await database;
    final existing = await db.query('habits', where: 'name = ? AND date = ?', whereArgs: [name, date]);
    if (existing.isEmpty) {
      await db.insert('habits', {
        'name': name,
        'isDone': isDone ? 1 : 0,
        'date': date,
      });
    } else {
      await db.update('habits', {'isDone': isDone ? 1 : 0}, where: 'name = ? AND date = ?', whereArgs: [name, date]);
    }
  }

  // Mikro günlük ekle
  static Future<void> insertJournal(String note, String date) async {
    final db = await database;
    await db.insert('journals', {
      'note': note,
      'date': date,
    });
  }

  // Moodları getir (tarihe göre)
  static Future<List<Map<String, dynamic>>> getMoodsByDate(String date) async {
    final db = await database;
    return await db.query('moods', where: 'date = ?', whereArgs: [date]);
  }

  // Alışkanlıkları getir (tarihe göre)
  static Future<List<Map<String, dynamic>>> getHabitsByDate(String date) async {
    final db = await database;
    return await db.query('habits', where: 'date = ?', whereArgs: [date]);
  }

  // Mikro günlükleri getir (tarihe göre)
  static Future<List<Map<String, dynamic>>> getJournalsByDate(String date) async {
    final db = await database;
    return await db.query('journals', where: 'date = ?', whereArgs: [date]);
  }

  // Moodları getir (tarih aralığı)
  static Future<List<Map<String, dynamic>>> getMoodsByDateRange(String startDate, String endDate) async {
    final db = await database;
    return await db.query(
      'moods',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
    );
  }

  // Mikro günlükleri getir (tarih aralığı)
  static Future<List<Map<String, dynamic>>> getJournalsByDateRange(String startDate, String endDate) async {
    final db = await database;
    return await db.query(
      'journals',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
    );
  }
}
