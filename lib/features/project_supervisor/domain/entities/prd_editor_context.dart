import 'package:equatable/equatable.dart';

import '../../../ai/domain/entities/prd_entity.dart';

class PrdEditorContext extends Equatable {
  final PrdEntity prd;

  final List<String> userSkills;

  final int teamSize;

  final DateTime startDate;
  final DateTime endDate;

  bool get isTeamProject => teamSize > 1;

  int get durationWeeks {
    final days = endDate.difference(startDate).inDays;
    return (days / 7).round();
  }

  const PrdEditorContext({
    required this.prd,
    required this.userSkills,
    required this.teamSize,
    required this.startDate,
    required this.endDate,
  });

  PrdEditorContext copyWith({
    PrdEntity? prd,
    List<String>? userSkills,
    int? teamSize,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return PrdEditorContext(
      prd: prd ?? this.prd,
      userSkills: userSkills ?? this.userSkills,
      teamSize: teamSize ?? this.teamSize,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [prd, userSkills, teamSize, startDate, endDate];
}
