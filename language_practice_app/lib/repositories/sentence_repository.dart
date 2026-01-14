import 'package:language_practice_app/database/database_helper.dart';
import 'package:language_practice_app/models/sentence.dart';

class SentenceRepository {
  final DatabaseHelper _dbHelper;

  SentenceRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<Sentence>> getAllSentences() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('sentences');
    return maps.map((map) => Sentence.fromMap(map)).toList();
  }

  Future<Sentence?> getSentenceById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sentences',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Sentence.fromMap(maps.first);
  }

  Future<List<Sentence>> getSentencesByRepetitionRange(
    int minReps,
    int maxReps,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sentences',
      where: 'repetitions >= ? AND repetitions <= ?',
      whereArgs: [minReps, maxReps],
      orderBy: 'repetitions ASC',
    );
    return maps.map((map) => Sentence.fromMap(map)).toList();
  }

  Future<List<Sentence>> getDownloadedSentences() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sentences',
      where: 'is_downloaded = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Sentence.fromMap(map)).toList();
  }

  Future<List<Sentence>> getSentencesNotDownloaded() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sentences',
      where: 'is_downloaded = ?',
      whereArgs: [0],
    );
    return maps.map((map) => Sentence.fromMap(map)).toList();
  }

  Future<int> getTotalRepetitions() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(repetitions) as total FROM sentences',
    );

    if (result.isEmpty || result.first['total'] == null) {
      return 0;
    }

    return result.first['total'] as int;
  }

  Future<int> getSentenceCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sentences');
    return result.first['count'] as int;
  }

  Future<int> insertSentence(Sentence sentence) async {
    final db = await _dbHelper.database;
    return await db.insert('sentences', sentence.toMap());
  }

  Future<void> insertMany(List<Sentence> sentences) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var sentence in sentences) {
      batch.insert('sentences', sentence.toMap());
    }

    await batch.commit(noResult: true);
  }

  Future<int> updateSentence(Sentence sentence) async {
    final db = await _dbHelper.database;
    return await db.update(
      'sentences',
      sentence.toMap(),
      where: 'id = ?',
      whereArgs: [sentence.id],
    );
  }

  Future<void> updateMany(List<Sentence> sentences) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var sentence in sentences) {
      batch.update(
        'sentences',
        sentence.toMap(),
        where: 'id = ?',
        whereArgs: [sentence.id],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<int> deleteSentence(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'sentences',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return;

    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var id in ids) {
      batch.delete(
        'sentences',
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('sentences');
  }

  Future<int> incrementRepetitions(String id, int amount) async {
    final db = await _dbHelper.database;
    return await db.rawUpdate(
      'UPDATE sentences SET repetitions = repetitions + ?, updated_at = ? WHERE id = ?',
      [amount, DateTime.now().toIso8601String(), id],
    );
  }

  Future<void> updateRepetitionsAndLastPracticed(
    String id,
    int repetitions,
    DateTime lastPracticed,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'sentences',
      {
        'repetitions': repetitions,
        'last_practiced': lastPracticed.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markAsDownloaded(String id, String localPath) async {
    final db = await _dbHelper.database;
    await db.update(
      'sentences',
      {
        'is_downloaded': 1,
        'local_audio_path': localPath,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateAudioDuration(String id, int durationMs) async {
    final db = await _dbHelper.database;
    await db.update(
      'sentences',
      {
        'audio_duration_ms': durationMs,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Sentence>> searchByText(String query) async {
    final db = await _dbHelper.database;
    final searchPattern = '%$query%';
    final List<Map<String, dynamic>> maps = await db.query(
      'sentences',
      where: 'original_text LIKE ? OR translation LIKE ?',
      whereArgs: [searchPattern, searchPattern],
    );
    return maps.map((map) => Sentence.fromMap(map)).toList();
  }
}
