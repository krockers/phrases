class AppSettings {
  final String? googleAccountEmail;
  final String? driveAudioFolderId;
  final String? sheetsSpreadsheetId;
  final double pausePercentage;
  final bool showTranslation;
  final int repetitionsPerSentence;
  final int filterMinReps;
  final int filterMaxReps;
  final DateTime? lastSyncTime;
  final bool androidAutoEnabled;

  AppSettings({
    this.googleAccountEmail,
    this.driveAudioFolderId,
    this.sheetsSpreadsheetId,
    this.pausePercentage = 1.0,
    this.showTranslation = true,
    this.repetitionsPerSentence = 3,
    this.filterMinReps = 0,
    this.filterMaxReps = 10,
    this.lastSyncTime,
    this.androidAutoEnabled = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'google_account_email': googleAccountEmail,
      'drive_audio_folder_id': driveAudioFolderId,
      'sheets_spreadsheet_id': sheetsSpreadsheetId,
      'pause_percentage': pausePercentage,
      'show_translation': showTranslation,
      'repetitions_per_sentence': repetitionsPerSentence,
      'filter_min_reps': filterMinReps,
      'filter_max_reps': filterMaxReps,
      'last_sync_time': lastSyncTime?.toIso8601String(),
      'android_auto_enabled': androidAutoEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      googleAccountEmail: json['google_account_email'] as String?,
      driveAudioFolderId: json['drive_audio_folder_id'] as String?,
      sheetsSpreadsheetId: json['sheets_spreadsheet_id'] as String?,
      pausePercentage: (json['pause_percentage'] as num?)?.toDouble() ?? 1.0,
      showTranslation: json['show_translation'] as bool? ?? true,
      repetitionsPerSentence: json['repetitions_per_sentence'] as int? ?? 3,
      filterMinReps: json['filter_min_reps'] as int? ?? 0,
      filterMaxReps: json['filter_max_reps'] as int? ?? 10,
      lastSyncTime: json['last_sync_time'] != null
          ? DateTime.parse(json['last_sync_time'] as String)
          : null,
      androidAutoEnabled: json['android_auto_enabled'] as bool? ?? false,
    );
  }

  factory AppSettings.defaultSettings() {
    return AppSettings();
  }

  AppSettings copyWith({
    String? googleAccountEmail,
    String? driveAudioFolderId,
    String? sheetsSpreadsheetId,
    double? pausePercentage,
    bool? showTranslation,
    int? repetitionsPerSentence,
    int? filterMinReps,
    int? filterMaxReps,
    DateTime? lastSyncTime,
    bool? androidAutoEnabled,
  }) {
    return AppSettings(
      googleAccountEmail: googleAccountEmail ?? this.googleAccountEmail,
      driveAudioFolderId: driveAudioFolderId ?? this.driveAudioFolderId,
      sheetsSpreadsheetId: sheetsSpreadsheetId ?? this.sheetsSpreadsheetId,
      pausePercentage: pausePercentage ?? this.pausePercentage,
      showTranslation: showTranslation ?? this.showTranslation,
      repetitionsPerSentence:
          repetitionsPerSentence ?? this.repetitionsPerSentence,
      filterMinReps: filterMinReps ?? this.filterMinReps,
      filterMaxReps: filterMaxReps ?? this.filterMaxReps,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      androidAutoEnabled: androidAutoEnabled ?? this.androidAutoEnabled,
    );
  }

  bool get isConfigured =>
      googleAccountEmail != null &&
      driveAudioFolderId != null &&
      sheetsSpreadsheetId != null;

  @override
  String toString() {
    return 'AppSettings{googleAccountEmail: $googleAccountEmail, pausePercentage: $pausePercentage, repetitionsPerSentence: $repetitionsPerSentence}';
  }
}
