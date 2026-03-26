part of 'skill_bloc.dart';

sealed class SkillState extends Equatable {
  const SkillState();

  @override
  List<Object?> get props => [];
}

class SkillInitial extends SkillState {
  const SkillInitial();
}

class SkillValidating extends SkillState {
  final String skillName;

  const SkillValidating({required this.skillName});

  @override
  List<Object?> get props => [skillName];
}

class SkillValidated extends SkillState {
  final SkillEntity skill;

  const SkillValidated({required this.skill});

  @override
  List<Object?> get props => [skill];
}

class PredefinedSkillAdded extends SkillState {
  final SkillEntity skill;

  const PredefinedSkillAdded({required this.skill});

  @override
  List<Object?> get props => [skill];
}

class SkillTestGenerating extends SkillState {
  final List<String> skillNames;

  const SkillTestGenerating({required this.skillNames});

  @override
  List<Object?> get props => [skillNames];
}

class SkillTestReady extends SkillState {
  final SkillTestModel test;

  const SkillTestReady({required this.test});

  @override
  List<Object?> get props => [test];
}

class SkillTestEvaluating extends SkillState {
  const SkillTestEvaluating();
}

class SkillTestEvaluated extends SkillState {
  final SkillTestResult result;
  final List<String> skillsTested;

  const SkillTestEvaluated({required this.result, required this.skillsTested});

  @override
  List<Object?> get props => [result, skillsTested];
}

class SkillError extends SkillState {
  final String message;
  final String? code;

  const SkillError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}
