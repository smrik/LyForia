class Habit {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? emoji;
  final int? color;
  final List<int> weeklyDays; // 1=Mon..7=Sun
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastCheckedAt; // UTC
  final int streakCount;
  final int bestStreak;

  const Habit({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.emoji,
    this.color,
    this.weeklyDays = const [1, 2, 3, 4, 5, 6, 7],
    this.archived = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastCheckedAt,
    this.streakCount = 0,
    this.bestStreak = 0,
  });

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? emoji,
    int? color,
    List<int>? weeklyDays,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastCheckedAt,
    int? streakCount,
    int? bestStreak,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      streakCount: streakCount ?? this.streakCount,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'emoji': emoji,
        'color': color,
        'weeklyDays': weeklyDays,
        'archived': archived,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'lastCheckedAt': lastCheckedAt?.toIso8601String(),
        'streakCount': streakCount,
        'bestStreak': bestStreak,
      };

  static Habit fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        userId: (json['userId'] as String?) ?? (json['uid'] as String?) ?? '',
        title: json['title'] as String,
        description: json['description'] as String?,
        emoji: json['emoji'] as String?,
        color: json['color'] as int?,
        weeklyDays: (json['weeklyDays'] as List?)?.map((e) => e as int).toList() ??
            const [1, 2, 3, 4, 5, 6, 7],
        archived: (json['archived'] as bool?) ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        lastCheckedAt: (json['lastCheckedAt'] as String?) != null
            ? DateTime.parse(json['lastCheckedAt'] as String)
            : null,
        streakCount: (json['streakCount'] as num?)?.toInt() ?? 0,
        bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
      );
}
