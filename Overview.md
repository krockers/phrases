# Language Practice App - Project Overview

## Project Summary
A Flutter-based Android language learning app with audio-based spaced repetition, Google Drive/Sheets sync, and Android Auto support for hands-free practice.

## Key Features
- Upload audio sentences (MP3) with translations
- Set repetitions per practice session
- Random playback with smart spacing (no immediate repeats)
- Configurable pause after each sentence for repetition practice
- Track lifetime repetition counts
- Filter sentences by repetition range (min/max)
- Sync via Google Drive (audio) + Google Sheets (metadata)
- Toggle translation display on/off
- Android Auto interface for hands-free practice while driving

## Technical Stack
- **Framework**: Flutter (Dart)
- **Native**: Kotlin (Android Auto module)
- **Database**: SQLite (local caching)
- **Cloud Storage**: Google Drive (audio files)
- **Cloud Database**: Google Sheets API v4 (metadata)
- **State Management**: Riverpod
- **Audio**: audioplayers package

## Project Status
- Current Phase: Phase 0 (Planning Complete)
- Next Phase: Phase 1 (Project Setup)

## Quick Links
- Design Doc: DESIGN_DOC.md
- Task List: TASK_LIST.md
- Data Models: See DESIGN_DOC.md Section 4
