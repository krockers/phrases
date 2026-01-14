import 'package:language_practice_app/database/database_helper.dart';
import 'package:language_practice_app/models/practice_history.dart';

class PracticeHistoryRepository {
  final DatabaseHelper _dbHelper;

  PracticeHistoryRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<PracticeHistory>> getAllHistory() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_history',
      orderBy: 'practiced_at DESC',
    );
    return maps.map((map) => PracticeHistory.fromMap(map)).toList();
  }

  Future<PracticeHistory?> getHistoryById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_history',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return PracticeHistory.fromMap(maps.first);
  }

  Future<List<PracticeHistory>> getHistoryBySessionId(String sessionId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_history',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'practiced_at ASC',
    );
    return maps.map((map) => PracticeHistory.fromMap(map)).toList();
  }

  Future<List<PracticeHistory>> getHistoryBySentenceId(
    String sentenceId,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_history',
      where: 'sentence_id = ?',
      whereArgs: [sentenceId],
      orderBy: 'practiced_at DESC',
    );
    return maps.map((map) => PracticeHistory.fromMap(map)).toList();
  }

  Future<List<PracticeHistory>> getHistoryInDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_history',
      where: 'practiced_at >= ? AND practiced_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'practiced_at DESC',
    );
    return maps.map((map) => PracticeHistory.fromMap(map)).toList();
  }

  Future<int> insertHistory(PracticeHistory history) async {
    final db = await _dbHelper.database;
    return await db.insert('practice_history', history.toMap());
  }

  Future<void> insertMany(List<PracticeHistory> historyList) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var history in historyList) {
      batch.insert('practice_history', history.toMap());
    }

    await batch.commit(noResult: true);
  }

  Future<int> updateHistory(PracticeHistory history) async {
    final db = await _dbHelper.database;
    return await db.update(
      'practice_history',
      history.toMap(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  Future<int> deleteHistory(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'practice_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteHistoryBySessionId(String sessionId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'practice_history',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<int> deleteHistoryBySentenceId(String sentenceId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'practice_history',
      where: 'sentence_id = ?',
      whereArgs: [sentenceId],
    );
  }

  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('practice_history');
  }

  Future<int> getTotalPracticeCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(repetitions_completed) as total FROM practice_history',
    );

    if (result.isEmpty || result.first['total'] == null) {
      return 0;
    }

    return result.first['total'] as int;
  }

  Future<Map<String, int>> getSentencePracticeCount(String sentenceId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as sessions, SUM(repetitions_completed) as total '
      'FROM practice_history WHERE sentence_id = ?',
      [sentenceId],
    );

    return {
      'sessions': result.first['sessions'] as int? ?? 0,
      'total_repetitions': result.first['total'] as int? ?? 0,
    };
  }
}
