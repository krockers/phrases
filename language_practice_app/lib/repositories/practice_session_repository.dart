import 'package:language_practice_app/database/database_helper.dart';
import 'package:language_practice_app/models/practice_session.dart';

class PracticeSessionRepository {
  final DatabaseHelper _dbHelper;

  PracticeSessionRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<PracticeSession>> getAllSessions() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_sessions',
      orderBy: 'started_at DESC',
    );
    return maps.map((map) => PracticeSession.fromMap(map)).toList();
  }

  Future<PracticeSession?> getSessionById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return PracticeSession.fromMap(maps.first);
  }

  Future<PracticeSession?> getActiveSession() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_sessions',
      where: 'ended_at IS NULL',
      orderBy: 'started_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return PracticeSession.fromMap(maps.first);
  }

  Future<List<PracticeSession>> getCompletedSessions({int? limit}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_sessions',
      where: 'ended_at IS NOT NULL',
      orderBy: 'started_at DESC',
      limit: limit,
    );
    return maps.map((map) => PracticeSession.fromMap(map)).toList();
  }

  Future<List<PracticeSession>> getSessionsInDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'practice_sessions',
      where: 'started_at >= ? AND started_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'started_at DESC',
    );
    return maps.map((map) => PracticeSession.fromMap(map)).toList();
  }

  Future<int> insertSession(PracticeSession session) async {
    final db = await _dbHelper.database;
    return await db.insert('practice_sessions', session.toMap());
  }

  Future<int> updateSession(PracticeSession session) async {
    final db = await _dbHelper.database;
    return await db.update(
      'practice_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<void> endSession(
    String id,
    DateTime endedAt,
    int totalRepetitions,
    int sentencesPracticed,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'practice_sessions',
      {
        'ended_at': endedAt.toIso8601String(),
        'total_repetitions': totalRepetitions,
        'sentences_practiced': sentencesPracticed,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSession(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'practice_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAll() async {
    final db = await _dbHelper.database;
    await db.delete('practice_sessions');
  }

  Future<Map<String, dynamic>> getSessionStatistics() async {
    final db = await _dbHelper.database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total_sessions, '
      'SUM(total_repetitions) as total_reps, '
      'SUM(sentences_practiced) as total_sentences '
      'FROM practice_sessions '
      'WHERE ended_at IS NOT NULL',
    );

    final avgResult = await db.rawQuery(
      'SELECT AVG(total_repetitions) as avg_reps, '
      'AVG(sentences_practiced) as avg_sentences '
      'FROM practice_sessions '
      'WHERE ended_at IS NOT NULL',
    );

    return {
      'total_sessions': totalResult.first['total_sessions'] ?? 0,
      'total_repetitions': totalResult.first['total_reps'] ?? 0,
      'total_sentences': totalResult.first['total_sentences'] ?? 0,
      'average_repetitions': avgResult.first['avg_reps'] ?? 0.0,
      'average_sentences': avgResult.first['avg_sentences'] ?? 0.0,
    };
  }
}
