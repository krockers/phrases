class Sentence {
  final String id;
  final String audioFilename;
  final String originalText;
  final String translation;
  final int repetitions;
  final DateTime? lastPracticed;
  final String driveFileId;
  final int? audioDurationMs;
  final bool isDownloaded;
  final String? localAudioPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Sentence({
    required this.id,
    required this.audioFilename,
    required this.originalText,
    required this.translation,
    this.repetitions = 0,
    this.lastPracticed,
    required this.driveFileId,
    this.audioDurationMs,
    this.isDownloaded = false,
    this.localAudioPath,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'audio_filename': audioFilename,
      'original_text': originalText,
      'translation': translation,
      'repetitions': repetitions,
      'last_practiced': lastPracticed?.toIso8601String(),
      'drive_file_id': driveFileId,
      'audio_duration_ms': audioDurationMs,
      'is_downloaded': isDownloaded ? 1 : 0,
      'local_audio_path': localAudioPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Sentence.fromMap(Map<String, dynamic> map) {
    return Sentence(
      id: map['id'] as String,
      audioFilename: map['audio_filename'] as String,
      originalText: map['original_text'] as String,
      translation: map['translation'] as String,
      repetitions: (map['repetitions'] as int?) ?? 0,
      lastPracticed: map['last_practiced'] != null
          ? DateTime.parse(map['last_practiced'] as String)
          : null,
      driveFileId: map['drive_file_id'] as String,
      audioDurationMs: map['audio_duration_ms'] as int?,
      isDownloaded: (map['is_downloaded'] as int?) == 1,
      localAudioPath: map['local_audio_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audio_filename': audioFilename,
      'original_text': originalText,
      'translation': translation,
      'repetitions': repetitions,
      'last_practiced': lastPracticed?.toIso8601String(),
      'drive_file_id': driveFileId,
      'audio_duration_ms': audioDurationMs,
      'is_downloaded': isDownloaded,
      'local_audio_path': localAudioPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      id: json['id'] as String,
      audioFilename: json['audio_filename'] as String,
      originalText: json['original_text'] as String,
      translation: json['translation'] as String,
      repetitions: (json['repetitions'] as int?) ?? 0,
      lastPracticed: json['last_practiced'] != null
          ? DateTime.parse(json['last_practiced'] as String)
          : null,
      driveFileId: json['drive_file_id'] as String,
      audioDurationMs: json['audio_duration_ms'] as int?,
      isDownloaded: json['is_downloaded'] as bool? ?? false,
      localAudioPath: json['local_audio_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory Sentence.fromSheetRow(List<dynamic> row) {
    return Sentence(
      id: row[0] as String,
      audioFilename: row[1] as String,
      originalText: row[2] as String,
      translation: row[3] as String,
      repetitions: int.tryParse(row[4].toString()) ?? 0,
      lastPracticed: row[5] != null && row[5].toString().isNotEmpty
          ? DateTime.parse(row[5] as String)
          : null,
      driveFileId: row[6] as String,
      createdAt: DateTime.parse(row[7] as String),
      updatedAt: DateTime.parse(row[8] as String),
      isDownloaded: false,
    );
  }

  List<dynamic> toSheetRow() {
    return [
      id,
      audioFilename,
      originalText,
      translation,
      repetitions,
      lastPracticed?.toIso8601String() ?? '',
      driveFileId,
      createdAt.toIso8601String(),
      updatedAt.toIso8601String(),
    ];
  }

  Sentence copyWith({
    String? id,
    String? audioFilename,
    String? originalText,
    String? translation,
    int? repetitions,
    DateTime? lastPracticed,
    String? driveFileId,
    int? audioDurationMs,
    bool? isDownloaded,
    String? localAudioPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sentence(
      id: id ?? this.id,
      audioFilename: audioFilename ?? this.audioFilename,
      originalText: originalText ?? this.originalText,
      translation: translation ?? this.translation,
      repetitions: repetitions ?? this.repetitions,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      driveFileId: driveFileId ?? this.driveFileId,
      audioDurationMs: audioDurationMs ?? this.audioDurationMs,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localAudioPath: localAudioPath ?? this.localAudioPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sentence &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Sentence{id: $id, originalText: $originalText, repetitions: $repetitions}';
  }
}
