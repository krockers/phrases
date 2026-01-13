# Implementation Task List

## Phase 0: Setup & Planning ✅
- [x] Create design document
- [x] Define data models
- [x] Define architecture
- [x] Prepare documents for Claude Code

## Phase 1: Project Setup (Week 1)
### 1.1 Flutter Project Initialization
- [ ] Create new Flutter project: `flutter create language_practice_app`
- [ ] Add required dependencies to pubspec.yaml
- [ ] Configure Android manifest permissions
- [ ] Set up folder structure (models, repositories, services, etc.)
- [ ] Initialize Git repository

### 1.2 Google Services Setup
- [ ] Create Google Cloud project
- [ ] Enable Google Drive API
- [ ] Enable Google Sheets API v4
- [ ] Configure OAuth 2.0 credentials
- [ ] Download and configure google-services.json
- [ ] Test Google Sign-In flow

### 1.3 Local Database Setup
- [ ] Create SQLite database helper class
- [ ] Implement sentences table schema
- [ ] Implement practice_sessions table schema
- [ ] Implement practice_history table schema
- [ ] Add database migration logic
- [ ] Write unit tests for database operations

## Phase 2: Core Data Layer (Week 2)
### 2.1 Models
- [ ] Create Sentence model with fromJson/toJson
- [ ] Create PracticeSession model
- [ ] Create PracticeHistory model
- [ ] Create AppSettings model
- [ ] Create SyncResult model
- [ ] Write unit tests for all models

### 2.2 Repositories
- [ ] Implement SentenceRepository (CRUD operations)
- [ ] Implement GoogleDriveRepository
  - [ ] List files in folder
  - [ ] Download file by ID
  - [ ] Get file metadata
- [ ] Implement GoogleSheetsRepository
  - [ ] Fetch all rows
  - [ ] Update specific rows
  - [ ] Append new rows
- [ ] Write integration tests for repositories

### 2.3 Services
- [ ] Implement AuthService (Google Sign-In)
- [ ] Implement SyncService
  - [ ] Implement sync algorithm
  - [ ] Handle conflict resolution
  - [ ] Track sync progress
- [ ] Implement AudioService
  - [ ] Download and cache audio
  - [ ] Play audio with duration tracking
  - [ ] Pause/resume/stop controls
- [ ] Implement PracticeService
  - [ ] Filter sentences by repetition range
  - [ ] Smart spacing algorithm
  - [ ] Track practice session
  - [ ] Update repetition counts
- [ ] Write unit tests for all services

## Phase 3: State Management (Week 3)
### 3.1 Riverpod Providers
- [ ] Create AuthProvider (user state)
- [ ] Create SettingsProvider (app settings)
- [ ] Create SentencesProvider (sentence list)
- [ ] Create PracticeProvider (practice session state)
- [ ] Create SyncProvider (sync status)
- [ ] Test provider interactions

## Phase 4: UI Implementation (Week 4-5)
### 4.1 Core Screens
- [ ] Create Welcome/Onboarding screen
- [ ] Create Google Sign-In screen
- [ ] Create Setup screen (folder/sheet selection)
- [ ] Create Home screen
  - [ ] Display lifetime repetitions
  - [ ] Filter controls (min/max reps)
  - [ ] Start practice button
  - [ ] Sync button with status
- [ ] Create Settings screen
  - [ ] Pause percentage slider
  - [ ] Show translation toggle
  - [ ] Reps per sentence input
  - [ ] Account management
  - [ ] Google Drive/Sheets links

### 4.2 Practice Screen
- [ ] Create Practice screen layout
  - [ ] Sentence counter (X/Y, Rep Z/N)
  - [ ] Original text display
  - [ ] Translation display (conditional)
  - [ ] Audio progress bar
  - [ ] Control buttons (Repeat, Next, Pause)
- [ ] Implement practice session logic
- [ ] Add animations/transitions
- [ ] Handle pause/resume
- [ ] Show session summary on completion

### 4.3 Additional Screens
- [ ] Create Manage Sentences screen (list view)
- [ ] Create Sentence Detail screen
- [ ] Create Sync Progress screen
- [ ] Create Error/Warning dialogs

### 4.4 Widgets
- [ ] SentenceCard widget
- [ ] SyncStatusWidget
- [ ] AudioProgressBar widget
- [ ] FilterControls widget
- [ ] StatisticsCard widget

## Phase 5: Audio Implementation (Week 5)
- [ ] Integrate audioplayers package
- [ ] Implement audio caching logic
- [ ] Calculate pause duration based on audio length
- [ ] Handle audio playback errors
- [ ] Add background audio support (notifications)
- [ ] Test with various audio formats/lengths

## Phase 6: Sync Implementation (Week 6)
- [ ] Implement first-time sync (download all)
- [ ] Implement incremental sync
- [ ] Add sync progress indicators
- [ ] Handle sync conflicts (local vs remote)
- [ ] Implement offline mode detection
- [ ] Test sync with large datasets (100+ sentences)

## Phase 7: Testing & Polish (Week 7)
### 7.1 Testing
- [ ] Write widget tests for all screens
- [ ] Integration tests for complete flows
- [ ] Manual testing with checklist
- [ ] Test on multiple Android versions
- [ ] Test with slow/unstable network
- [ ] Test with empty/large datasets

### 7.2 Polish
- [ ] Add loading indicators
- [ ] Improve error messages
- [ ] Add haptic feedback
- [ ] Optimize performance (profile with DevTools)
- [ ] Add app icon and splash screen
- [ ] Implement proper navigation stack

## Phase 8: Android Auto Integration (Week 8-9)
### 8.1 Native Module Setup
- [ ] Create Kotlin module in /android
- [ ] Set up MediaBrowserService
- [ ] Implement MediaSession callbacks
- [ ] Configure Android Auto metadata

### 8.2 AA Functionality
- [ ] Create AA main screen (browse)
- [ ] Create AA playback screen
- [ ] Implement playback controls
- [ ] Add voice command support
- [ ] Bridge Flutter ↔ Kotlin communication
- [ ] Test in Android Auto emulator
- [ ] Test in actual car (if available)

## Phase 9: Documentation & Deployment (Week 10)
- [ ] Write user manual (setup instructions)
- [ ] Document Google Sheets template
- [ ] Create demo video
- [ ] Write README for repository
- [ ] Prepare for Play Store release
  - [ ] Create app listing (description, screenshots)
  - [ ] Privacy policy
  - [ ] Generate signed APK/AAB
- [ ] Beta test with users
- [ ] Address beta feedback
- [ ] Official release to Play Store

## Phase 10: Post-Launch
- [ ] Monitor crash reports
- [ ] Gather user feedback
- [ ] Plan Phase 2 features
- [ ] Create roadmap for future versions

---

## Current Status
**Phase**: 0 (Planning Complete)  
**Next Task**: Phase 1.1 - Flutter Project Initialization  
**Ready to begin**: Yes
