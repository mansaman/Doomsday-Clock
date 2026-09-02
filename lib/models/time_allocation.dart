/// A standing, recurring time debt that eats into your daily free-time budget.
/// E.g. sleep (8h/day), job (10h/day), commute (2h/day).
class TimeAllocation {
  TimeAllocation({
    required this.id,
    required this.name,
    required this.hoursPerDay,
    required this.icon,
    this.isActive = true,
  });

  final String id;
  final String name;
  final double hoursPerDay;
  final String icon;
  bool isActive;

  TimeAllocation copyWith({
    String? name,
    double? hoursPerDay,
    String? icon,
    bool? isActive,
  }) {
    return TimeAllocation(
      id: id,
      name: name ?? this.name,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hoursPerDay': hoursPerDay,
        'icon': icon,
        'isActive': isActive,
      };

  factory TimeAllocation.fromJson(Map<String, dynamic> json) => TimeAllocation(
        id: json['id'] as String,
        name: json['name'] as String,
        hoursPerDay: (json['hoursPerDay'] as num).toDouble(),
        icon: json['icon'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? true,
      );
}
