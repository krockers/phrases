class SyncResult {
  final int inserted;
  final int updated;
  final int deleted;
  final int audioDownloaded;
  final bool success;
  final String? errorMessage;
  final DateTime syncTime;

  SyncResult({
    this.inserted = 0,
    this.updated = 0,
    this.deleted = 0,
    this.audioDownloaded = 0,
    this.success = true,
    this.errorMessage,
    DateTime? syncTime,
  }) : syncTime = syncTime ?? DateTime.now();

  int get totalChanges => inserted + updated + deleted;

  bool get hasChanges => totalChanges > 0;

  Map<String, dynamic> toJson() {
    return {
      'inserted': inserted,
      'updated': updated,
      'deleted': deleted,
      'audio_downloaded': audioDownloaded,
      'success': success,
      'error_message': errorMessage,
      'sync_time': syncTime.toIso8601String(),
    };
  }

  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      inserted: json['inserted'] as int? ?? 0,
      updated: json['updated'] as int? ?? 0,
      deleted: json['deleted'] as int? ?? 0,
      audioDownloaded: json['audio_downloaded'] as int? ?? 0,
      success: json['success'] as bool? ?? true,
      errorMessage: json['error_message'] as String?,
      syncTime: json['sync_time'] != null
          ? DateTime.parse(json['sync_time'] as String)
          : DateTime.now(),
    );
  }

  factory SyncResult.error(String message) {
    return SyncResult(
      success: false,
      errorMessage: message,
    );
  }

  SyncResult copyWith({
    int? inserted,
    int? updated,
    int? deleted,
    int? audioDownloaded,
    bool? success,
    String? errorMessage,
    DateTime? syncTime,
  }) {
    return SyncResult(
      inserted: inserted ?? this.inserted,
      updated: updated ?? this.updated,
      deleted: deleted ?? this.deleted,
      audioDownloaded: audioDownloaded ?? this.audioDownloaded,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      syncTime: syncTime ?? this.syncTime,
    );
  }

  String getSummary() {
    if (!success) {
      return 'Sync failed: ${errorMessage ?? 'Unknown error'}';
    }

    if (!hasChanges && audioDownloaded == 0) {
      return 'Already up to date';
    }

    final parts = <String>[];
    if (inserted > 0) parts.add('$inserted added');
    if (updated > 0) parts.add('$updated updated');
    if (deleted > 0) parts.add('$deleted removed');
    if (audioDownloaded > 0) parts.add('$audioDownloaded audio files downloaded');

    return parts.join(', ');
  }

  @override
  String toString() {
    return 'SyncResult{inserted: $inserted, updated: $updated, deleted: $deleted, audioDownloaded: $audioDownloaded, success: $success}';
  }
}
