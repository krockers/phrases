# Language Practice App - Design Document

## 1. Project Overview

**Name**: Language Practice App (working title)

**Purpose**: A language learning app that uses spaced repetition with audio playback, synced via Google Drive/Sheets, with Android Auto support for hands-free practice.

**Target Platform**: Android (Flutter), with Android Auto extension

---

## 2. Technical Stack

### Core Technologies
- **Flutter** (Dart) - Main app framework
- **Kotlin** - Native Android Auto module
- **SQLite** (sqflite) - Local data persistence
- **Google Drive API** - Audio file storage
- **Google Sheets API v4** - Metadata and sync

### Key Flutter Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Google Services
  googleapis: ^11.0.0
  google_sign_in: ^6.1.5
  googleapis_auth: ^1.4.1
  
  # Audio
  audioplayers: ^5.2.1
  
  # Storage
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  shared_preferences: ^2.2.2
  
  # HTTP & File Download
  http: ^1.1.0
  dio: ^5.4.0  # For better download progress
  
  # UI/UX
  flutter_riverpod: ^2.4.9  # State management
  go_router: ^12.1.3  # Navigation
  
  # Utilities
  intl: ^0.18.1  # Date formatting
  uuid: ^4.2.2  # Generate IDs
```

### Native Android (Android Auto)
- Android Automotive OS library
- MediaSessionCompat
- MediaBrowserServiceCompat

---

## 3. Architecture

### App Architecture Pattern
**MVVM + Repository Pattern**
```
lib/
├── main.dart
├── models/              # Data models
│   ├── sentence.dart
│   ├── practice_session.dart
│   └── app_settings.dart
├── repositories/        # Data layer
│   ├── sentence_repository.dart
│   ├── google_drive_repository.dart
│   └── google_sheets_repository.dart
├── services/            # Business logic
│   ├── sync_service.dart
│   ├── audio_service.dart
│   └── practice_service.dart
├── providers/           # Riverpod state management
│   ├── auth_provider.dart
│   ├── sentences_provider.dart
│   └── settings_provider.dart
├── screens/             # UI screens
│   ├── home_screen.dart
│   ├── practice_screen.dart
│   ├── settings_screen.dart
│   └── manage_sentences_screen.dart
└── widgets/             # Reusable components
    ├── sentence_card.dart
    └── sync_status_widget.dart
```

---

## 4. Data Models

### 4.1 Local Database Schema (SQLite)

**Table: sentences**
```sql
CREATE TABLE sentences (
  id TEXT PRIMARY KEY,
  audio_filename TEXT NOT NULL,
  original_text TEXT NOT NULL,
  translation TEXT NOT NULL,
  repetitions INTEGER DEFAULT 0,
  last_practiced TEXT,  -- ISO 8601 datetime
  drive_file_id TEXT NOT NULL,
  audio_duration_ms INTEGER,  -- Cached duration
  is_downloaded INTEGER DEFAULT 0,
  local_audio_path TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE INDEX idx_repetitions ON sentences(repetitions);
CREATE INDEX idx_last_practiced ON sentences(last_practiced);
```

**Table: practice_sessions**
```sql
CREATE TABLE practice_sessions (
  id TEXT PRIMARY KEY,
  started_at TEXT NOT NULL,
  ended_at TEXT,
  total_repetitions INTEGER DEFAULT 0,
  sentences_practiced INTEGER DEFAULT 0,
  filter_min INTEGER,
  filter_max INTEGER
);
```

**Table: practice_history**
```sql
CREATE TABLE practice_history (
  id TEXT PRIMARY KEY,
  session_id TEXT NOT NULL,
  sentence_id TEXT NOT NULL,
  practiced_at TEXT NOT NULL,
  repetitions_completed INTEGER DEFAULT 0,
  FOREIGN KEY (session_id) REFERENCES practice_sessions(id),
  FOREIGN KEY (sentence_id) REFERENCES sentences(id)
);
```

### 4.2 Google Sheets Structure

**Sheet Name**: "Sentences"

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| id | string | Unique identifier (UUID) | `550e8400-e29b-41d4-a716-446655440000` |
| audio_filename | string | Filename in Drive | `es_001.mp3` |
| original_text | string | Text in target language | `Hola, ¿cómo estás?` |
| translation | string | Translation | `Hello, how are you?` |
| repetitions | integer | Lifetime count | `15` |
| last_practiced | string | ISO date | `2026-01-12T14:30:00Z` |
| drive_file_id | string | Google Drive file ID | `1a2b3c4d5e6f...` |
| created_at | string | ISO date | `2026-01-01T10:00:00Z` |
| updated_at | string | ISO date | `2026-01-12T14:30:00Z` |

### 4.3 App Settings (SharedPreferences)
```dart
class AppSettings {
  String? googleAccountEmail;
  String? driveAudioFolderId;
  String? sheetsSpreadsheetId;
  double pausePercentage;  // 1.0 = 100%, 1.5 = 150%
  bool showTranslation;
  int repetitionsPerSentence;  // Default: 3
  int filterMinReps;  // Default: 0
  int filterMaxReps;  // Default: 10
  DateTime? lastSyncTime;
  bool androidAutoEnabled;
}
```

---

## 5. Core Features & User Flows

### 5.1 Initial Setup Flow
1. User opens app (first time)
2. Welcome screen → "Connect Google Account"
3. Google Sign-In
4. Request permissions: Drive (specific folder), Sheets
5. User enters/creates:
   - Google Drive folder ID (or browse to select)
   - Google Sheets spreadsheet ID (or create new)
6. Initial sync downloads metadata + audio files
7. Navigate to home screen

### 5.2 Desktop: Adding New Sentences
1. Record audio → save as MP3 → upload to Drive folder
2. Open Google Sheets
3. Add new row:
   - Generate UUID (or use formula)
   - Enter audio filename
   - Enter original text
   - Enter translation
   - Set repetitions = 0
   - Leave last_practiced empty
   - Copy Drive file ID
   - Set created_at = NOW()
   - Set updated_at = NOW()

### 5.3 Mobile: Sync Flow
1. User taps "Sync Now" button
2. Show loading indicator
3. Fetch all rows from Google Sheets
4. Compare with local database:
   - New sentences → insert
   - Updated sentences → update
   - Deleted sentences → remove locally
5. Download missing audio files (show progress)
6. Upload local repetition counts to Sheets
7. Update last_sync_time
8. Show success message + stats

### 5.4 Practice Session Flow
1. **Start Practice**:
   - User sets filter (min/max reps)
   - App queries local DB for matching sentences
   - If none found → show message
   - If found → randomize order (smart spacing)

2. **During Practice**:
   - Show sentence X/Y, Rep Z/N
   - Display original text (always)
   - Display translation (if enabled in settings)
   - Play audio
   - Wait pause_duration = audio_length × pause_percentage
   - Increment rep counter
   - If rep < repetitionsPerSentence → repeat same sentence
   - If rep >= repetitionsPerSentence → mark complete, next sentence
   
3. **Smart Spacing Logic**:
   - Shuffle sentences initially
   - After completing a sentence, don't play it again for at least 3 other sentences
   - Keep a "recently played" queue (size: 3)

4. **Controls**:
   - **Next button**: Skip to next sentence, current reps don't count
   - **Repeat button**: Replay current audio, doesn't count toward reps
   - **Pause/Resume**: Standard audio controls
   - **Stop**: End session early

5. **End Session**:
   - Update local DB: increment repetitions, set last_practiced
   - Save practice_session record
   - Show summary: "Practiced X sentences, Y total reps"
   - Prompt: "Sync now?" (optional)

### 5.5 Android Auto Flow
1. User connects phone to car
2. Android Auto launches app icon
3. **AA Main Screen**: "Start Practice" (uses default filter)
4. **AA Playback Screen**:
   - Large text: current original sentence
   - Auto-plays audio → pause → next sentence
   - Controls: Previous | Play/Pause | Next
   - Voice: "Next sentence", "Repeat", "Stop practice"
5. No translation display (safety)
6. After session: "Practice complete" notification

---

## 6. Key Algorithms

### 6.1 Smart Spacing Algorithm
```dart
class SmartSpacer {
  final int recentlyPlayedWindowSize = 3;
  List<Sentence> _recentlyPlayed = [];
  
  Sentence? getNextSentence(List<Sentence> remainingSentences) {
    // Filter out recently played
    final available = remainingSentences
        .where((s) => !_recentlyPlayed.contains(s))
        .toList();
    
    if (available.isEmpty) {
      // All sentences recently played, clear history
      _recentlyPlayed.clear();
      return remainingSentences.isNotEmpty 
          ? remainingSentences[Random().nextInt(remainingSentences.length)]
          : null;
    }
    
    // Pick random from available
    final next = available[Random().nextInt(available.length)];
    
    // Update recently played queue
    _recentlyPlayed.add(next);
    if (_recentlyPlayed.length > recentlyPlayedWindowSize) {
      _recentlyPlayed.removeAt(0);
    }
    
    return next;
  }
}
```

### 6.2 Sync Algorithm
```dart
Future<SyncResult> syncWithGoogleSheets() async {
  // 1. Fetch remote data
  final remoteRows = await sheetsRepository.fetchAllRows();
  final remoteSentences = remoteRows.map((r) => Sentence.fromSheetRow(r));
  
  // 2. Fetch local data
  final localSentences = await sentenceRepository.getAllSentences();
  
  // 3. Three-way comparison
  final toInsert = <Sentence>[];
  final toUpdate = <Sentence>[];
  final toDelete = <String>[];
  
  final localMap = {for (var s in localSentences) s.id: s};
  final remoteMap = {for (var s in remoteSentences) s.id: s};
  
  // Find new and updated
  for (var remote in remoteSentences) {
    final local = localMap[remote.id];
    if (local == null) {
      toInsert.add(remote);
    } else if (remote.updatedAt.isAfter(local.updatedAt)) {
      // Remote is newer, but preserve local repetitions if higher
      toUpdate.add(remote.copyWith(
        repetitions: max(remote.repetitions, local.repetitions),
      ));
    }
  }
  
  // Find deleted
  for (var local in localSentences) {
    if (!remoteMap.containsKey(local.id)) {
      toDelete.add(local.id);
    }
  }
  
  // 4. Apply changes locally
  await sentenceRepository.insertMany(toInsert);
  await sentenceRepository.updateMany(toUpdate);
  await sentenceRepository.deleteMany(toDelete);
  
  // 5. Download missing audio files
  for (var sentence in [...toInsert, ...toUpdate]) {
    if (!sentence.isDownloaded) {
      await downloadAudioFile(sentence);
    }
  }
  
  // 6. Upload local changes to remote
  final localUpdates = localSentences
      .where((s) => s.updatedAt.isAfter(lastSyncTime))
      .toList();
  
  await sheetsRepository.updateRows(localUpdates);
  
  return SyncResult(
    inserted: toInsert.length,
    updated: toUpdate.length,
    deleted: toDelete.length,
  );
}
```

---

## 7. UI/UX Specifications

### 7.1 Home Screen
```
┌─────────────────────────────┐
│  Language Practice App      │
│  [☰ Menu]         [⚙️ Settings] │
├─────────────────────────────┤
│                             │
│   Lifetime Repetitions      │
│   ┌─────────────────────┐   │
│   │       1,247         │   │
│   └─────────────────────┘   │
│                             │
│   Practice Filter           │
│   Min: [0 ] Max: [10]       │
│   Reps per sentence: [3]    │
│                             │
│   ┌─────────────────────┐   │
│   │ 47 sentences match  │   │
│   └─────────────────────┘   │
│                             │
│   ┌─────────────────────┐   │
│   │  START PRACTICE  ▶  │   │
│   └─────────────────────┘   │
│                             │
│   [📋 Manage Sentences]      │
│                             │
│   ┌─────────────────────┐   │
│   │ 🔄 Sync Now         │   │
│   │ Last: 2 hours ago   │   │
│   └─────────────────────┘   │
└─────────────────────────────┘
```

### 7.2 Practice Screen
```
┌─────────────────────────────┐
│  [← Back]          [⏸ Pause] │
├─────────────────────────────┤
│                             │
│  Sentence 5/47              │
│  Repetition 2/3             │
│                             │
│  ┌─────────────────────┐   │
│  │  ¿Cómo estás?       │   │  ← Original (always shown)
│  │                     │   │
│  │  How are you?       │   │  ← Translation (toggleable)
│  └─────────────────────┘   │
│                             │
│  [🔁 Repeat] [⏭️ Next]       │
│                             │
│  ▰▰▰▰▰▰▰▰▰▰▱▱▱▱▱▱▱▱         │  ← Audio progress
│  Playing... 2.3s / 3.1s     │
│                             │
│  Then pause: 1.5s           │
│                             │
└─────────────────────────────┘
```

### 7.3 Settings Screen
```
┌─────────────────────────────┐
│  Settings          [← Back] │
├─────────────────────────────┤
│                             │
│  Account                    │
│  [👤 user@gmail.com]         │
│  [🔓 Disconnect]             │
│                             │
│  ─────────────────────      │
│                             │
│  Practice Settings          │
│                             │
│  Pause Duration             │
│  [────●────] 150%           │
│  (1.0x - 3.0x audio length) │
│                             │
│  Show Translation           │
│  [✓ ON ] [ OFF]             │
│                             │
│  Reps per Sentence          │
│  [- 3 +]                    │
│                             │
│  ─────────────────────      │
│                             │
│  Google Drive Folder        │
│  [📁 Browse...]              │
│  Current: /LanguagePractice │
│                             │
│  Google Sheet               │
│  [📊 Select Sheet...]        │
│  Current: Sentences.xlsx    │
│                             │
│  ─────────────────────      │
│                             │
│  Android Auto               │
│  [✓ Enable]                 │
│  Default Filter: 0-5 reps   │
│                             │
└─────────────────────────────┘
```

### 7.4 Android Auto Screens

**Main Screen** (simplified list):
```
┌─────────────────────────────┐
│  Language Practice          │
├─────────────────────────────┤
│                             │
│  ▶️  Start Practice          │
│     (47 sentences ready)    │
│                             │
│  📊  Last Session            │
│     15 sentences, 45 reps   │
│                             │
└─────────────────────────────┘
```

**Playback Screen** (large text):
```
┌─────────────────────────────┐
│  Sentence 5/47              │
├─────────────────────────────┤
│                             │
│   ¿Cómo estás?              │  ← Very large font
│                             │
│                             │
│  [⏮️]  [⏸️]  [⏭️]             │  ← Large buttons
│                             │
└─────────────────────────────┘
```

---

## 8. Error Handling & Edge Cases

### 8.1 Network Issues
- **No internet during sync**: Show clear error, allow offline practice with cached data
- **Timeout**: Retry with exponential backoff (3 attempts)
- **Partial download**: Resume from last checkpoint

### 8.2 Audio Issues
- **Missing audio file**: Show warning, skip to next sentence
- **Corrupt audio**: Catch playback exception, mark for re-download
- **Audio too long**: Show warning if > 30 seconds (might indicate wrong file)

### 8.3 Google API Issues
- **Auth expired**: Prompt re-authentication
- **Rate limits**: Queue requests, retry after delay
- **Insufficient permissions**: Clear error with instructions to fix

### 8.4 Data Integrity
- **Duplicate IDs**: Last-write-wins, log warning
- **Missing required fields**: Skip row, log error
- **Invalid file references**: Mark for cleanup, notify user

### 8.5 Storage Issues
- **Low disk space**: Warn user, don't download new audio
- **Database corruption**: Backup old DB, reinitialize, force full sync

---

## 9. Testing Strategy

### Unit Tests
- Sentence model serialization/deserialization
- Smart spacing algorithm
- Sync conflict resolution
- Audio duration calculation

### Integration Tests
- Google Sheets API calls (with mock data)
- Google Drive download
- SQLite CRUD operations
- Audio playback service

### Widget Tests
- Practice screen UI
- Settings screen
- Filter validation

### Manual Testing Checklist
- [ ] First-time setup flow
- [ ] Sync: add sentence on desktop → sync → appears in app
- [ ] Practice: complete session, verify counts updated
- [ ] Sync: counts pushed back to Google Sheets
- [ ] Offline: practice without internet
- [ ] Settings: change pause %, toggle translation
- [ ] Android Auto: start practice, controls work
- [ ] Edge: delete sentence on desktop → sync → removed from app
- [ ] Edge: low storage warning
- [ ] Edge: bad network during sync

---

## 10. Security & Privacy

### Data Security
- **Google credentials**: Stored securely via Google Sign-In SDK
- **Local database**: Unencrypted (no sensitive data)
- **Audio files**: Cached locally in app-private directory

### Permissions Required
- **Internet**: For Google API calls
- **Storage**: For audio file caching (scoped storage)
- **Android Auto**: For car integration

### Privacy Considerations
- No analytics/tracking by default
- All data stored in user's own Google account
- Audio never uploaded to third-party servers

---

## 11. Performance Considerations

### Optimization Targets
- **App launch**: < 2 seconds
- **Sync time**: < 30 seconds for 100 sentences
- **Audio playback start**: < 500ms
- **Database queries**: < 100ms for filtered results

### Caching Strategy
- Audio files: Persistent cache in app directory
- Sheets data: SQLite (fast local queries)
- Audio duration: Cached after first play

### Memory Management
- Limit in-memory audio queue to 3 sentences
- Release audio player resources when not in use
- Paginate sentence list if > 500 items

---

## 12. Future Enhancements (Post-MVP)

### Phase 2 Features
- **Import/Export**: Backup local database
- **Categories/Tags**: Group sentences by topic
- **Search**: Find sentences by text
- **Statistics**: Graphs of progress over time
- **Multiple languages**: Support multiple language pairs

### Phase 3 Features
- **Spaced repetition algorithm**: Smarter scheduling (Leitner/SM2)
- **Speech recognition**: Verify pronunciation
- **Web interface**: Manage sentences from browser
- **Collaborative**: Share sentence collections
- **iOS version**: Port to iOS with CarPlay
