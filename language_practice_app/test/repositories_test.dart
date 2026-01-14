import 'package:flutter_test/flutter_test.dart';
import 'package:language_practice_app/database/database_helper.dart';
import 'package:language_practice_app/models/sentence.dart';
import 'package:language_practice_app/models/practice_session.dart';
import 'package:language_practice_app/models/practice_history.dart';
import 'package:language_practice_app/repositories/sentence_repository.dart';
import 'package:language_practice_app/repositories/practice_session_repository.dart';
import 'package:language_practice_app/repositories/practice_history_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper dbHelper;
  late SentenceRepository sentenceRepo;
  late PracticeSessionRepository sessionRepo;
  late PracticeHistoryRepository historyRepo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteDatabase();

    sentenceRepo = SentenceRepository(dbHelper: dbHelper);
    sessionRepo = PracticeSessionRepository(dbHelper: dbHelper);
    historyRepo = PracticeHistoryRepository(dbHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.deleteDatabase();
  });

  group('SentenceRepository', () {
    test('should insert and retrieve sentence', () async {
      final sentence = Sentence(
        id: 'test-1',
        audioFilename: 'test1.mp3',
        originalText: 'Hola',
        translation: 'Hello',
        driveFileId: 'drive-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await sentenceRepo.insertSentence(sentence);
      final retrieved = await sentenceRepo.getSentenceById('test-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.originalText, 'Hola');
      expect(retrieved.translation, 'Hello');
    });

    test('should get all sentences', () async {
      final sentences = [
        Sentence(
          id: 'test-1',
          audioFilename: 'test1.mp3',
          originalText: 'Hola',
          translation: 'Hello',
          driveFileId: 'drive-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Sentence(
          id: 'test-2',
          audioFilename: 'test2.mp3',
          originalText: 'Adiós',
          translation: 'Goodbye',
          driveFileId: 'drive-2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await sentenceRepo.insertMany(sentences);
      final retrieved = await sentenceRepo.getAllSentences();

      expect(retrieved.length, 2);
    });

    test('should filter sentences by repetition range', () async {
      final sentences = [
        Sentence(
          id: 'low-1',
          audioFilename: 'low1.mp3',
          originalText: 'Low',
          translation: 'Low',
          repetitions: 2,
          driveFileId: 'drive-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Sentence(
          id: 'mid-1',
          audioFilename: 'mid1.mp3',
          originalText: 'Mid',
          translation: 'Mid',
          repetitions: 7,
          driveFileId: 'drive-2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Sentence(
          id: 'high-1',
          audioFilename: 'high1.mp3',
          originalText: 'High',
          translation: 'High',
          repetitions: 15,
          driveFileId: 'drive-3',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await sentenceRepo.insertMany(sentences);
      final filtered = await sentenceRepo.getSentencesByRepetitionRange(0, 10);

      expect(filtered.length, 2);
      expect(filtered.every((s) => s.repetitions <= 10), true);
    });

    test('should update sentence', () async {
      final sentence = Sentence(
        id: 'update-1',
        audioFilename: 'update1.mp3',
        originalText: 'Original',
        translation: 'Translation',
        repetitions: 5,
        driveFileId: 'drive-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await sentenceRepo.insertSentence(sentence);

      final updated = sentence.copyWith(repetitions: 10);
      await sentenceRepo.updateSentence(updated);

      final retrieved = await sentenceRepo.getSentenceById('update-1');
      expect(retrieved!.repetitions, 10);
    });

    test('should delete sentence', () async {
      final sentence = Sentence(
        id: 'delete-1',
        audioFilename: 'delete1.mp3',
        originalText: 'Delete',
        translation: 'Delete',
        driveFileId: 'drive-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await sentenceRepo.insertSentence(sentence);
      await sentenceRepo.deleteSentence('delete-1');

      final retrieved = await sentenceRepo.getSentenceById('delete-1');
      expect(retrieved, isNull);
    });

    test('should get total repetitions', () async {
      final sentences = [
        Sentence(
          id: 'rep-1',
          audioFilename: 'rep1.mp3',
          originalText: 'One',
          translation: 'One',
          repetitions: 5,
          driveFileId: 'drive-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Sentence(
          id: 'rep-2',
          audioFilename: 'rep2.mp3',
          originalText: 'Two',
          translation: 'Two',
          repetitions: 10,
          driveFileId: 'drive-2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await sentenceRepo.insertMany(sentences);
      final total = await sentenceRepo.getTotalRepetitions();

      expect(total, 15);
    });

    test('should increment repetitions', () async {
      final sentence = Sentence(
        id: 'inc-1',
        audioFilename: 'inc1.mp3',
        originalText: 'Increment',
        translation: 'Increment',
        repetitions: 5,
        driveFileId: 'drive-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await sentenceRepo.insertSentence(sentence);
      await sentenceRepo.incrementRepetitions('inc-1', 3);

      final retrieved = await sentenceRepo.getSentenceById('inc-1');
      expect(retrieved!.repetitions, 8);
    });

    test('should mark as downloaded', () async {
      final sentence = Sentence(
        id: 'dl-1',
        audioFilename: 'dl1.mp3',
        originalText: 'Download',
        translation: 'Download',
        driveFileId: 'drive-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await sentenceRepo.insertSentence(sentence);
      await sentenceRepo.markAsDownloaded('dl-1', '/path/to/audio');

      final retrieved = await sentenceRepo.getSentenceById('dl-1');
      expect(retrieved!.isDownloaded, true);
      expect(retrieved.localAudioPath, '/path/to/audio');
    });

    test('should search by text', () async {
      final sentences = [
        Sentence(
          id: 'search-1',
          audioFilename: 'search1.mp3',
          originalText: 'Buenos días',
          translation: 'Good morning',
          driveFileId: 'drive-1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Sentence(
          id: 'search-2',
          audioFilename: 'search2.mp3',
          originalText: 'Buenas noches',
          translation: 'Good night',
          driveFileId: 'drive-2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await sentenceRepo.insertMany(sentences);
      final results = await sentenceRepo.searchByText('Buenos');

      expect(results.length, 1);
      expect(results.first.originalText, 'Buenos días');
    });
  });

  group('PracticeSessionRepository', () {
    test('should insert and retrieve session', () async {
      final session = PracticeSession(
        id: 'session-1',
        startedAt: DateTime.now(),
        totalRepetitions: 10,
        sentencesPracticed: 5,
      );

      await sessionRepo.insertSession(session);
      final retrieved = await sessionRepo.getSessionById('session-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.totalRepetitions, 10);
      expect(retrieved.sentencesPracticed, 5);
    });

    test('should get active session', () async {
      final activeSession = PracticeSession(
        id: 'active-1',
        startedAt: DateTime.now(),
      );

      final completedSession = PracticeSession(
        id: 'completed-1',
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        endedAt: DateTime.now(),
      );

      await sessionRepo.insertSession(activeSession);
      await sessionRepo.insertSession(completedSession);

      final retrieved = await sessionRepo.getActiveSession();

      expect(retrieved, isNotNull);
      expect(retrieved!.id, 'active-1');
    });

    test('should end session', () async {
      final session = PracticeSession(
        id: 'end-1',
        startedAt: DateTime.now(),
      );

      await sessionRepo.insertSession(session);

      final endTime = DateTime.now();
      await sessionRepo.endSession('end-1', endTime, 15, 5);

      final retrieved = await sessionRepo.getSessionById('end-1');

      expect(retrieved!.endedAt, isNotNull);
      expect(retrieved.totalRepetitions, 15);
      expect(retrieved.sentencesPracticed, 5);
    });

    test('should get completed sessions', () async {
      final sessions = [
        PracticeSession(
          id: 'comp-1',
          startedAt: DateTime.now().subtract(const Duration(days: 2)),
          endedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        PracticeSession(
          id: 'comp-2',
          startedAt: DateTime.now().subtract(const Duration(days: 1)),
          endedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        PracticeSession(
          id: 'active-1',
          startedAt: DateTime.now(),
        ),
      ];

      for (var session in sessions) {
        await sessionRepo.insertSession(session);
      }

      final completed = await sessionRepo.getCompletedSessions();

      expect(completed.length, 2);
    });

    test('should get session statistics', () async {
      final sessions = [
        PracticeSession(
          id: 'stat-1',
          startedAt: DateTime.now(),
          endedAt: DateTime.now(),
          totalRepetitions: 10,
          sentencesPracticed: 5,
        ),
        PracticeSession(
          id: 'stat-2',
          startedAt: DateTime.now(),
          endedAt: DateTime.now(),
          totalRepetitions: 20,
          sentencesPracticed: 10,
        ),
      ];

      for (var session in sessions) {
        await sessionRepo.insertSession(session);
      }

      final stats = await sessionRepo.getSessionStatistics();

      expect(stats['total_sessions'], 2);
      expect(stats['total_repetitions'], 30);
      expect(stats['total_sentences'], 15);
    });
  });

  group('PracticeHistoryRepository', () {
    test('should insert and retrieve history', () async {
      final history = PracticeHistory(
        id: 'hist-1',
        sessionId: 'session-1',
        sentenceId: 'sentence-1',
        practicedAt: DateTime.now(),
        repetitionsCompleted: 3,
      );

      await historyRepo.insertHistory(history);
      final retrieved = await historyRepo.getHistoryById('hist-1');

      expect(retrieved, isNotNull);
      expect(retrieved!.sessionId, 'session-1');
      expect(retrieved.repetitionsCompleted, 3);
    });

    test('should get history by session', () async {
      final histories = [
        PracticeHistory(
          id: 'hist-1',
          sessionId: 'session-1',
          sentenceId: 'sentence-1',
          practicedAt: DateTime.now(),
          repetitionsCompleted: 3,
        ),
        PracticeHistory(
          id: 'hist-2',
          sessionId: 'session-1',
          sentenceId: 'sentence-2',
          practicedAt: DateTime.now(),
          repetitionsCompleted: 3,
        ),
        PracticeHistory(
          id: 'hist-3',
          sessionId: 'session-2',
          sentenceId: 'sentence-1',
          practicedAt: DateTime.now(),
          repetitionsCompleted: 3,
        ),
      ];

      await historyRepo.insertMany(histories);
      final retrieved = await historyRepo.getHistoryBySessionId('session-1');

      expect(retrieved.length, 2);
    });

    test('should get history by sentence', () async {
      final histories = [
        PracticeHistory(
          id: 'hist-1',
          sessionId: 'session-1',
          sentenceId: 'sentence-1',
          practicedAt: DateTime.now(),
          repetitionsCompleted: 3,
        ),
        PracticeHistory(
          id: 'hist-2',
          sessionId: 'session-2',
          sentenceId: 'sentence-1',
          practicedAt: DateTime.now(),
          repetitionsCompleted: 3,
        ),
      ];

      await historyRepo.insertMany(histories);
      final retrieved = await historyRepo.getHistoryBySentenceId('sentence-1');

      expect(retrieved.length, 2);
    });

    test('should get total practice count', () async {
      final histories = [
        PracticeHistory(
          id: 'hist-1',
          sessionId: 'session-1',
          sentenceId: 'sentence-1',
          practicedAt: DateTime.now(),
          repetitionsCompleted: 5,
        ),
        PracticeHistory(
          id: 'hist-2',
          sessionId: 'session-1',
          sentenceId: 'sentence-2',
          practicedAt: DateTime.now(),
          repetitionsCompleted: 10,
        ),
      ];

      await historyRepo.insertMany(histories);
      final total = await historyRepo.getTotalPracticeCount();

      expect(total, 15);
    });

    test('should delete history by session', () async {
      final histories = [
        PracticeHistory(
          id: 'hist-1',
          sessionId: 'session-1',
          sentenceId: 'sentence-1',
          practicedAt: DateTime.now(),
          repetitionsCompleted: 3,
        ),
        PracticeHistory(
          id: 'hist-2',
          sessionId: 'session-1',
          sentenceId: 'sentence-2',
          practicedAt: DateTime.now(),
          repetitionsCompleted: 3,
        ),
      ];

      await historyRepo.insertMany(histories);
      await historyRepo.deleteHistoryBySessionId('session-1');

      final retrieved = await historyRepo.getHistoryBySessionId('session-1');
      expect(retrieved.length, 0);
    });
  });
}
