class PracticeHistory {
  final String id;
  final String sessionId;
  final String sentenceId;
  final DateTime practicedAt;
  final int repetitionsCompleted;

  PracticeHistory({
    required this.id,
    required this.sessionId,
    required this.sentenceId,
    required this.practicedAt,
    this.repetitionsCompleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'sentence_id': sentenceId,
      'practiced_at': practicedAt.toIso8601String(),
      'repetitions_completed': repetitionsCompleted,
    };
  }

  factory PracticeHistory.fromMap(Map<String, dynamic> map) {
    return PracticeHistory(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      sentenceId: map['sentence_id'] as String,
      practicedAt: DateTime.parse(map['practiced_at'] as String),
      repetitionsCompleted: (map['repetitions_completed'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'sentence_id': sentenceId,
      'practiced_at': practicedAt.toIso8601String(),
      'repetitions_completed': repetitionsCompleted,
    };
  }

  factory PracticeHistory.fromJson(Map<String, dynamic> json) {
    return PracticeHistory(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      sentenceId: json['sentence_id'] as String,
      practicedAt: DateTime.parse(json['practiced_at'] as String),
      repetitionsCompleted: (json['repetitions_completed'] as int?) ?? 0,
    );
  }

  PracticeHistory copyWith({
    String? id,
    String? sessionId,
    String? sentenceId,
    DateTime? practicedAt,
    int? repetitionsCompleted,
  }) {
    return PracticeHistory(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      sentenceId: sentenceId ?? this.sentenceId,
      practicedAt: practicedAt ?? this.practicedAt,
      repetitionsCompleted: repetitionsCompleted ?? this.repetitionsCompleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PracticeHistory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PracticeHistory{id: $id, sessionId: $sessionId, sentenceId: $sentenceId, repetitionsCompleted: $repetitionsCompleted}';
  }
}
