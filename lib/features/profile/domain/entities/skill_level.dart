enum SkillLevel {
  beginner,

  intermediate,

  advanced,

  expert;

  static SkillLevel? fromString(String? value) {
    if (value == null) return null;
    return SkillLevel.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SkillLevel.beginner,
    );
  }

  String toJson() => name.toLowerCase();

  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
  }
}
