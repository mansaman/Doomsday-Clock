class UserProfile {
  UserProfile({
    required this.dateOfBirth,
    required this.lifeExpectancyYears,
    required this.isOnboarded,
  });

  final DateTime dateOfBirth;
  final int lifeExpectancyYears;
  final bool isOnboarded;

  UserProfile copyWith({
    DateTime? dateOfBirth,
    int? lifeExpectancyYears,
    bool? isOnboarded,
  }) {
    return UserProfile(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      lifeExpectancyYears: lifeExpectancyYears ?? this.lifeExpectancyYears,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  Map<String, dynamic> toJson() => {
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'lifeExpectancyYears': lifeExpectancyYears,
        'isOnboarded': isOnboarded,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
        lifeExpectancyYears: json['lifeExpectancyYears'] as int,
        isOnboarded: json['isOnboarded'] as bool? ?? false,
      );
}
