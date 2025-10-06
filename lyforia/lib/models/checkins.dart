class CheckIns {
  final String id;
  final String userId;
  final Map<DateTime, bool> dates;

  const CheckIns({required this.id, required this.userId, required this.dates});

  CheckIns copyWith({
    String? id,
    String? userId,
    Map<DateTime, bool>? dates,
    bool? completed,
  }) {
    return CheckIns(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dates: dates ?? this.dates,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'dates': dates,
      };

  static CheckIns fromJson(Map<String, dynamic> json) => CheckIns(
        id: json['id'] as String,
        userId: (json['userId'] as String?) ?? (json['uid'] as String?) ?? '',
        dates: (json['dates'] as Map<DateTime, bool>?)
                ?.map((k, v) => MapEntry(DateTime.parse(k as String), v)) ??
            const {},
      );
}
