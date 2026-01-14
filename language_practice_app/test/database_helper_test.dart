import 'package:flutter_test/flutter_test.dart';
import 'package:language_practice_app/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper dbHelper;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteDatabase();
  });

  tearDown(() async {
    await dbHelper.deleteDatabase();
  });

  group('DatabaseHelper', () {
    test('should create database with correct tables', () async {
      final db = await dbHelper.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );

      final tableNames = tables.map((t) => t['name'] as String).toList();

      expect(tableNames, contains('sentences'));
      expect(tableNames, contains('practice_sessions'));
      expect(tableNames, contains('practice_history'));
    });

    test('should create sentences table with correct schema', () async {
      final db = await dbHelper.database;

      final columns = await db.rawQuery('PRAGMA table_info(sentences)');

      final columnNames = columns.map((c) => c['name'] as String).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('audio_filename'));
      expect(columnNames, contains('original_text'));
      expect(columnNames, contains('translation'));
      expect(columnNames, contains('repetitions'));
      expect(columnNames, contains('last_practiced'));
      expect(columnNames, contains('drive_file_id'));
      expect(columnNames, contains('audio_duration_ms'));
      expect(columnNames, contains('is_downloaded'));
      expect(columnNames, contains('local_audio_path'));
      expect(columnNames, contains('created_at'));
      expect(columnNames, contains('updated_at'));
    });

    test('should create indexes on sentences table', () async {
      final db = await dbHelper.database;

      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='sentences'",
      );

      final indexNames = indexes.map((i) => i['name'] as String).toList();

      expect(indexNames, contains('idx_repetitions'));
      expect(indexNames, contains('idx_last_practiced'));
    });

    test('should create practice_sessions table with correct schema', () async {
      final db = await dbHelper.database;

      final columns = await db.rawQuery('PRAGMA table_info(practice_sessions)');

      final columnNames = columns.map((c) => c['name'] as String).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('started_at'));
      expect(columnNames, contains('ended_at'));
      expect(columnNames, contains('total_repetitions'));
      expect(columnNames, contains('sentences_practiced'));
      expect(columnNames, contains('filter_min'));
      expect(columnNames, contains('filter_max'));
    });

    test('should create practice_history table with correct schema', () async {
      final db = await dbHelper.database;

      final columns = await db.rawQuery('PRAGMA table_info(practice_history)');

      final columnNames = columns.map((c) => c['name'] as String).toList();

      expect(columnNames, contains('id'));
      expect(columnNames, contains('session_id'));
      expect(columnNames, contains('sentence_id'));
      expect(columnNames, contains('practiced_at'));
      expect(columnNames, contains('repetitions_completed'));
    });

    test('should insert and retrieve data from sentences table', () async {
      final db = await dbHelper.database;

      final testData = {
        'id': 'test-123',
        'audio_filename': 'test.mp3',
        'original_text': 'Hola',
        'translation': 'Hello',
        'repetitions': 0,
        'drive_file_id': 'drive-123',
        'is_downloaded': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await db.insert('sentences', testData);

      final result = await db.query(
        'sentences',
        where: 'id = ?',
        whereArgs: ['test-123'],
      );

      expect(result.length, 1);
      expect(result.first['original_text'], 'Hola');
      expect(result.first['translation'], 'Hello');
    });

    test('should update sentence repetitions', () async {
      final db = await dbHelper.database;

      final testData = {
        'id': 'test-456',
        'audio_filename': 'test2.mp3',
        'original_text': 'Buenos días',
        'translation': 'Good morning',
        'repetitions': 5,
        'drive_file_id': 'drive-456',
        'is_downloaded': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await db.insert('sentences', testData);

      await db.update(
        'sentences',
        {'repetitions': 10, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: ['test-456'],
      );

      final result = await db.query(
        'sentences',
        where: 'id = ?',
        whereArgs: ['test-456'],
      );

      expect(result.first['repetitions'], 10);
    });

    test('should delete sentence', () async {
      final db = await dbHelper.database;

      final testData = {
        'id': 'test-789',
        'audio_filename': 'test3.mp3',
        'original_text': 'Gracias',
        'translation': 'Thank you',
        'repetitions': 0,
        'drive_file_id': 'drive-789',
        'is_downloaded': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await db.insert('sentences', testData);

      await db.delete(
        'sentences',
        where: 'id = ?',
        whereArgs: ['test-789'],
      );

      final result = await db.query(
        'sentences',
        where: 'id = ?',
        whereArgs: ['test-789'],
      );

      expect(result.length, 0);
    });

    test('should query sentences by repetition range', () async {
      final db = await dbHelper.database;

      await db.insert('sentences', {
        'id': 'low-rep-1',
        'audio_filename': 'low1.mp3',
        'original_text': 'Uno',
        'translation': 'One',
        'repetitions': 2,
        'drive_file_id': 'drive-1',
        'is_downloaded': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await db.insert('sentences', {
        'id': 'high-rep-1',
        'audio_filename': 'high1.mp3',
        'original_text': 'Dos',
        'translation': 'Two',
        'repetitions': 15,
        'drive_file_id': 'drive-2',
        'is_downloaded': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      final result = await db.query(
        'sentences',
        where: 'repetitions >= ? AND repetitions <= ?',
        whereArgs: [0, 10],
      );

      expect(result.length, 1);
      expect(result.first['original_text'], 'Uno');
    });
  });
}
