import 'package:flutter_test/flutter_test.dart';
import 'package:language_practice_app/models/sentence.dart';
import 'package:language_practice_app/models/practice_session.dart';
import 'package:language_practice_app/models/practice_history.dart';
import 'package:language_practice_app/models/app_settings.dart';
import 'package:language_practice_app/models/sync_result.dart';

void main() {
  group('Sentence Model', () {
    test('should create sentence from map', () {
      final map = {
        'id': 'test-123',
        'audio_filename': 'test.mp3',
        'original_text': 'Hola',
        'translation': 'Hello',
        'repetitions': 5,
        'last_practiced': '2026-01-13T10:00:00.000Z',
        'drive_file_id': 'drive-123',
        'audio_duration_ms': 3000,
        'is_downloaded': 1,
        'local_audio_path': '/path/to/audio',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-13T10:00:00.000Z',
      };

      final sentence = Sentence.fromMap(map);

      expect(sentence.id, 'test-123');
      expect(sentence.originalText, 'Hola');
      expect(sentence.translation, 'Hello');
      expect(sentence.repetitions, 5);
      expect(sentence.isDownloaded, true);
    });

    test('should convert sentence to map', () {
      final sentence = Sentence(
        id: 'test-456',
        audioFilename: 'test2.mp3',
        originalText: 'Buenos días',
        translation: 'Good morning',
        repetitions: 10,
        driveFileId: 'drive-456',
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-13T10:00:00.000Z'),
      );

      final map = sentence.toMap();

      expect(map['id'], 'test-456');
      expect(map['original_text'], 'Buenos días');
      expect(map['translation'], 'Good morning');
      expect(map['repetitions'], 10);
      expect(map['is_downloaded'], 0);
    });

    test('should convert sentence to/from JSON', () {
      final sentence = Sentence(
        id: 'json-123',
        audioFilename: 'json.mp3',
        originalText: 'Gracias',
        translation: 'Thank you',
        repetitions: 3,
        driveFileId: 'drive-json',
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-13T10:00:00.000Z'),
      );

      final json = sentence.toJson();
      final fromJson = Sentence.fromJson(json);

      expect(fromJson.id, sentence.id);
      expect(fromJson.originalText, sentence.originalText);
      expect(fromJson.translation, sentence.translation);
    });

    test('should create sentence from sheet row', () {
      final row = [
        'sheet-123',
        'sheet.mp3',
        '¿Cómo estás?',
        'How are you?',
        '7',
        '2026-01-13T10:00:00.000Z',
        'drive-sheet',
        '2026-01-01T00:00:00.000Z',
        '2026-01-13T10:00:00.000Z',
      ];

      final sentence = Sentence.fromSheetRow(row);

      expect(sentence.id, 'sheet-123');
      expect(sentence.originalText, '¿Cómo estás?');
      expect(sentence.repetitions, 7);
    });

    test('should convert sentence to sheet row', () {
      final sentence = Sentence(
        id: 'sheet-456',
        audioFilename: 'sheet2.mp3',
        originalText: 'Por favor',
        translation: 'Please',
        repetitions: 5,
        driveFileId: 'drive-sheet2',
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-13T10:00:00.000Z'),
      );

      final row = sentence.toSheetRow();

      expect(row[0], 'sheet-456');
      expect(row[2], 'Por favor');
      expect(row[4], 5);
    });

    test('should copy sentence with new values', () {
      final sentence = Sentence(
        id: 'copy-123',
        audioFilename: 'copy.mp3',
        originalText: 'Original',
        translation: 'Translation',
        repetitions: 1,
        driveFileId: 'drive-copy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final copied = sentence.copyWith(
        repetitions: 10,
        originalText: 'Modified',
      );

      expect(copied.id, sentence.id);
      expect(copied.repetitions, 10);
      expect(copied.originalText, 'Modified');
      expect(copied.translation, sentence.translation);
    });

    test('should implement equality correctly', () {
      final sentence1 = Sentence(
        id: 'equal-123',
        audioFilename: 'equal.mp3',
        originalText: 'Text',
        translation: 'Trans',
        driveFileId: 'drive-equal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final sentence2 = Sentence(
        id: 'equal-123',
        audioFilename: 'different.mp3',
        originalText: 'Different',
        translation: 'Different',
        driveFileId: 'drive-different',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(sentence1, equals(sentence2));
    });
  });

  group('PracticeSession Model', () {
    test('should create practice session from map', () {
      final map = {
        'id': 'session-123',
        'started_at': '2026-01-13T10:00:00.000Z',
        'ended_at': '2026-01-13T10:30:00.000Z',
        'total_repetitions': 45,
        'sentences_practiced': 15,
        'filter_min': 0,
        'filter_max': 10,
      };

      final session = PracticeSession.fromMap(map);

      expect(session.id, 'session-123');
      expect(session.totalRepetitions, 45);
      expect(session.sentencesPracticed, 15);
      expect(session.isActive, false);
    });

    test('should detect active session', () {
      final activeSession = PracticeSession(
        id: 'active-123',
        startedAt: DateTime.now(),
      );

      final completedSession = PracticeSession(
        id: 'completed-123',
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        endedAt: DateTime.now(),
      );

      expect(activeSession.isActive, true);
      expect(completedSession.isActive, false);
    });

    test('should calculate session duration', () {
      final session = PracticeSession(
        id: 'duration-123',
        startedAt: DateTime.parse('2026-01-13T10:00:00.000Z'),
        endedAt: DateTime.parse('2026-01-13T10:30:00.000Z'),
      );

      expect(session.duration, const Duration(minutes: 30));
    });

    test('should copy session with new values', () {
      final session = PracticeSession(
        id: 'copy-session',
        startedAt: DateTime.now(),
        totalRepetitions: 10,
      );

      final copied = session.copyWith(totalRepetitions: 20);

      expect(copied.id, session.id);
      expect(copied.totalRepetitions, 20);
    });
  });

  group('PracticeHistory Model', () {
    test('should create practice history from map', () {
      final map = {
        'id': 'history-123',
        'session_id': 'session-123',
        'sentence_id': 'sentence-123',
        'practiced_at': '2026-01-13T10:00:00.000Z',
        'repetitions_completed': 3,
      };

      final history = PracticeHistory.fromMap(map);

      expect(history.id, 'history-123');
      expect(history.sessionId, 'session-123');
      expect(history.sentenceId, 'sentence-123');
      expect(history.repetitionsCompleted, 3);
    });

    test('should convert to/from JSON', () {
      final history = PracticeHistory(
        id: 'json-history',
        sessionId: 'json-session',
        sentenceId: 'json-sentence',
        practicedAt: DateTime.parse('2026-01-13T10:00:00.000Z'),
        repetitionsCompleted: 5,
      );

      final json = history.toJson();
      final fromJson = PracticeHistory.fromJson(json);

      expect(fromJson.id, history.id);
      expect(fromJson.sessionId, history.sessionId);
      expect(fromJson.repetitionsCompleted, history.repetitionsCompleted);
    });
  });

  group('AppSettings Model', () {
    test('should create default settings', () {
      final settings = AppSettings.defaultSettings();

      expect(settings.pausePercentage, 1.0);
      expect(settings.showTranslation, true);
      expect(settings.repetitionsPerSentence, 3);
      expect(settings.filterMinReps, 0);
      expect(settings.filterMaxReps, 10);
      expect(settings.androidAutoEnabled, false);
    });

    test('should convert to/from JSON', () {
      final settings = AppSettings(
        googleAccountEmail: 'test@example.com',
        driveAudioFolderId: 'folder-123',
        sheetsSpreadsheetId: 'sheet-123',
        pausePercentage: 1.5,
        showTranslation: false,
        repetitionsPerSentence: 5,
      );

      final json = settings.toJson();
      final fromJson = AppSettings.fromJson(json);

      expect(fromJson.googleAccountEmail, settings.googleAccountEmail);
      expect(fromJson.pausePercentage, settings.pausePercentage);
      expect(fromJson.showTranslation, settings.showTranslation);
      expect(fromJson.repetitionsPerSentence, settings.repetitionsPerSentence);
    });

    test('should detect if configured', () {
      final configured = AppSettings(
        googleAccountEmail: 'test@example.com',
        driveAudioFolderId: 'folder-123',
        sheetsSpreadsheetId: 'sheet-123',
      );

      final notConfigured = AppSettings();

      expect(configured.isConfigured, true);
      expect(notConfigured.isConfigured, false);
    });

    test('should copy with new values', () {
      final settings = AppSettings();
      final copied = settings.copyWith(
        pausePercentage: 2.0,
        showTranslation: false,
      );

      expect(copied.pausePercentage, 2.0);
      expect(copied.showTranslation, false);
      expect(copied.repetitionsPerSentence, settings.repetitionsPerSentence);
    });
  });

  group('SyncResult Model', () {
    test('should create successful sync result', () {
      final result = SyncResult(
        inserted: 5,
        updated: 3,
        deleted: 1,
        audioDownloaded: 4,
      );

      expect(result.success, true);
      expect(result.totalChanges, 9);
      expect(result.hasChanges, true);
    });

    test('should create error result', () {
      final result = SyncResult.error('Network error');

      expect(result.success, false);
      expect(result.errorMessage, 'Network error');
    });

    test('should generate correct summary', () {
      final result1 = SyncResult(
        inserted: 5,
        updated: 3,
        deleted: 1,
        audioDownloaded: 4,
      );

      expect(
        result1.getSummary(),
        '5 added, 3 updated, 1 removed, 4 audio files downloaded',
      );

      final result2 = SyncResult();
      expect(result2.getSummary(), 'Already up to date');

      final result3 = SyncResult.error('Failed');
      expect(result3.getSummary(), 'Sync failed: Failed');
    });

    test('should convert to/from JSON', () {
      final result = SyncResult(
        inserted: 2,
        updated: 3,
        deleted: 1,
        audioDownloaded: 2,
      );

      final json = result.toJson();
      final fromJson = SyncResult.fromJson(json);

      expect(fromJson.inserted, result.inserted);
      expect(fromJson.updated, result.updated);
      expect(fromJson.deleted, result.deleted);
      expect(fromJson.success, result.success);
    });

    test('should copy with new values', () {
      final result = SyncResult(inserted: 5);
      final copied = result.copyWith(updated: 3);

      expect(copied.inserted, 5);
      expect(copied.updated, 3);
    });
  });
}
