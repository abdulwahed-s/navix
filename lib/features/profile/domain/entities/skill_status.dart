enum SkillStatus {
  pending,

  approved,

  rejected;

  static SkillStatus fromString(String value) {
    return SkillStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => SkillStatus.pending,
    );
  }

  String toJson() => name.toUpperCase();
}
