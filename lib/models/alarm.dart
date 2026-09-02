class AppAlarm {
  AppAlarm({
    required this.id,
    required this.hour,
    required this.minute,
    required this.message,
    required this.isActive,
    this.repeatDaily = false,
  });

  final String id;
  final int hour;
  final int minute;
  final String message;
  bool isActive;
  final bool repeatDaily;

  AppAlarm copyWith({
    int? hour,
    int? minute,
    String? message,
    bool? isActive,
  }) {
    return AppAlarm(
      id: id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      message: message ?? this.message,
      isActive: isActive ?? this.isActive,
      repeatDaily: repeatDaily,
    );
  }

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'message': message,
        'isActive': isActive,
        'repeatDaily': repeatDaily,
      };

  factory AppAlarm.fromJson(Map<String, dynamic> json) => AppAlarm(
        id: json['id'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        message: json['message'] as String,
        isActive: json['isActive'] as bool,
        repeatDaily: json['repeatDaily'] as bool? ?? false,
      );
}
