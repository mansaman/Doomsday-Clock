class QuickNote {
  QuickNote({
    required this.id,
    required this.content,
    this.flashIntervalMinutes,
    this.isPinned = false,
    required this.createdAt,
  });

  final String id;
  final String content;

  /// How often (in minutes) this note should flash on screen. Null = no flashing.
  final int? flashIntervalMinutes;
  final bool isPinned;
  final DateTime createdAt;

  QuickNote copyWith({
    String? content,
    int? flashIntervalMinutes,
    bool? isPinned,
  }) {
    return QuickNote(
      id: id,
      content: content ?? this.content,
      flashIntervalMinutes: flashIntervalMinutes ?? this.flashIntervalMinutes,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'flashIntervalMinutes': flashIntervalMinutes,
        'isPinned': isPinned,
        'createdAt': createdAt.toIso8601String(),
      };

  factory QuickNote.fromJson(Map<String, dynamic> json) => QuickNote(
        id: json['id'] as String,
        content: json['content'] as String,
        flashIntervalMinutes: json['flashIntervalMinutes'] as int?,
        isPinned: json['isPinned'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
