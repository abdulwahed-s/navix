part of 'skill_bloc.dart';

sealed class SkillEvent extends Equatable {
  const SkillEvent();

  @override
  List<Object?> get props => [];
}

class ValidateSkill extends SkillEvent {
  final String skillName;

  const ValidateSkill({required this.skillName});

  @override
  List<Object?> get props => [skillName];
}

class AddPredefinedSkill extends SkillEvent {
  final String skillName;

  const AddPredefinedSkill({required this.skillName});

  @override
  List<Object?> get props => [skillName];
}

class GenerateSkillTest extends SkillEvent {
  final List<String> skillNames;

  const GenerateSkillTest({required this.skillNames});

  @override
  List<Object?> get props => [skillNames];
}

class SubmitSkillTest extends SkillEvent {
  final Map<String, String> answers;

  const SubmitSkillTest({required this.answers});

  @override
  List<Object?> get props => [answers];
}

class ResetSkillState extends SkillEvent {
  const ResetSkillState();
}
