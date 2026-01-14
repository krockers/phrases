import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'language_practice.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createSentencesTable(db);
    await _createPracticeSessionsTable(db);
    await _createPracticeHistoryTable(db);
  }

  Future<void> _createSentencesTable(Database db) async {
    await db.execute('''
      CREATE TABLE sentences (
        id TEXT PRIMARY KEY,
        audio_filename TEXT NOT NULL,
        original_text TEXT NOT NULL,
        translation TEXT NOT NULL,
        repetitions INTEGER DEFAULT 0,
        last_practiced TEXT,
        drive_file_id TEXT NOT NULL,
        audio_duration_ms INTEGER,
        is_downloaded INTEGER DEFAULT 0,
        local_audio_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_repetitions ON sentences(repetitions)
    ''');

    await db.execute('''
      CREATE INDEX idx_last_practiced ON sentences(last_practiced)
    ''');
  }

  Future<void> _createPracticeSessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE practice_sessions (
        id TEXT PRIMARY KEY,
        started_at TEXT NOT NULL,
        ended_at TEXT,
        total_repetitions INTEGER DEFAULT 0,
        sentences_practiced INTEGER DEFAULT 0,
        filter_min INTEGER,
        filter_max INTEGER
      )
    ''');
  }

  Future<void> _createPracticeHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE practice_history (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        sentence_id TEXT NOT NULL,
        practiced_at TEXT NOT NULL,
        repetitions_completed INTEGER DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES practice_sessions(id),
        FOREIGN KEY (sentence_id) REFERENCES sentences(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE sentences ADD COLUMN new_field TEXT');
    // }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'language_practice.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
