class PracticeSession {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int totalRepetitions;
  final int sentencesPracticed;
  final int? filterMin;
  final int? filterMax;

  PracticeSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.totalRepetitions = 0,
    this.sentencesPracticed = 0,
    this.filterMin,
    this.filterMax,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'total_repetitions': totalRepetitions,
      'sentences_practiced': sentencesPracticed,
      'filter_min': filterMin,
      'filter_max': filterMax,
    };
  }

  factory PracticeSession.fromMap(Map<String, dynamic> map) {
    return PracticeSession(
      id: map['id'] as String,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
      totalRepetitions: (map['total_repetitions'] as int?) ?? 0,
      sentencesPracticed: (map['sentences_practiced'] as int?) ?? 0,
      filterMin: map['filter_min'] as int?,
      filterMax: map['filter_max'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'total_repetitions': totalRepetitions,
      'sentences_practiced': sentencesPracticed,
      'filter_min': filterMin,
      'filter_max': filterMax,
    };
  }

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      totalRepetitions: (json['total_repetitions'] as int?) ?? 0,
      sentencesPracticed: (json['sentences_practiced'] as int?) ?? 0,
      filterMin: json['filter_min'] as int?,
      filterMax: json['filter_max'] as int?,
    );
  }

  PracticeSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    int? totalRepetitions,
    int? sentencesPracticed,
    int? filterMin,
    int? filterMax,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalRepetitions: totalRepetitions ?? this.totalRepetitions,
      sentencesPracticed: sentencesPracticed ?? this.sentencesPracticed,
      filterMin: filterMin ?? this.filterMin,
      filterMax: filterMax ?? this.filterMax,
    );
  }

  bool get isActive => endedAt == null;

  Duration? get duration =>
      endedAt != null ? endedAt!.difference(startedAt) : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PracticeSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PracticeSession{id: $id, sentencesPracticed: $sentencesPracticed, totalRepetitions: $totalRepetitions}';
  }
}
