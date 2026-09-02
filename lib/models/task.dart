class WorkTask {
  WorkTask({
    required this.id,
    required this.name,
    this.allocatedMinutes,
    this.isCompleted = false,
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// How many minutes of life this task is worth. Null = no strict allocation.
  final int? allocatedMinutes;
  bool isCompleted;
  bool isActive;
  final DateTime createdAt;

  WorkTask copyWith({
    String? name,
    int? allocatedMinutes,
    bool? isCompleted,
    bool? isActive,
  }) {
    return WorkTask(
      id: id,
      name: name ?? this.name,
      allocatedMinutes: allocatedMinutes ?? this.allocatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'allocatedMinutes': allocatedMinutes,
        'isCompleted': isCompleted,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory WorkTask.fromJson(Map<String, dynamic> json) => WorkTask(
        id: json['id'] as String,
        name: json['name'] as String,
        allocatedMinutes: json['allocatedMinutes'] as int?,
        isCompleted: json['isCompleted'] as bool? ?? false,
        isActive: json['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
