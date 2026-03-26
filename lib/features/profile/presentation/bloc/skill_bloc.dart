import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/skill_model.dart';
import '../../data/models/skill_test_model.dart';
import '../../domain/entities/skill_entity.dart';
import '../../domain/entities/skill_status.dart';
import '../../domain/usecases/add_skill_usecase.dart';
import '../../domain/usecases/evaluate_skill_test_usecase.dart';
import '../../domain/usecases/generate_skill_test_usecase.dart';

part 'skill_event.dart';
part 'skill_state.dart';

class SkillBloc extends Bloc<SkillEvent, SkillState> {
  final AddSkillUseCase addSkillUseCase;
  final GenerateSkillTestUseCase generateSkillTestUseCase;
  final EvaluateSkillTestUseCase evaluateSkillTestUseCase;

  SkillTestModel? _currentTest;

  SkillBloc({
    required this.addSkillUseCase,
    required this.generateSkillTestUseCase,
    required this.evaluateSkillTestUseCase,
  }) : super(const SkillInitial()) {
    on<ValidateSkill>(_onValidateSkill);
    on<AddPredefinedSkill>(_onAddPredefinedSkill);
    on<GenerateSkillTest>(_onGenerateSkillTest);
    on<SubmitSkillTest>(_onSubmitSkillTest);
    on<ResetSkillState>(_onResetSkillState);
  }

  Future<void> _onValidateSkill(
    ValidateSkill event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillValidating(skillName: event.skillName));

    final result = await addSkillUseCase(
      AddSkillParams(skillName: event.skillName, isPredefined: false),
    );

    result.fold(
      (failure) =>
          emit(SkillError(message: failure.message, code: failure.code)),
      (skill) => emit(SkillValidated(skill: skill)),
    );
  }

  Future<void> _onAddPredefinedSkill(
    AddPredefinedSkill event,
    Emitter<SkillState> emit,
  ) async {
    final skill = SkillModel(
      skillName: event.skillName,
      status: SkillStatus.approved,
      isVerified: false,
    );
    emit(PredefinedSkillAdded(skill: skill));
  }

  Future<void> _onGenerateSkillTest(
    GenerateSkillTest event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillTestGenerating(skillNames: event.skillNames));

    final result = await generateSkillTestUseCase(
      GenerateSkillTestParams(skillNames: event.skillNames),
    );

    result.fold(
      (failure) =>
          emit(SkillError(message: failure.message, code: failure.code)),
      (test) {
        _currentTest = test;
        emit(SkillTestReady(test: test));
      },
    );
  }

  Future<void> _onSubmitSkillTest(
    SubmitSkillTest event,
    Emitter<SkillState> emit,
  ) async {
    if (_currentTest == null) {
      emit(
        const SkillError(message: 'No active test to submit', code: 'no-test'),
      );
      return;
    }

    emit(const SkillTestEvaluating());

    final result = await evaluateSkillTestUseCase(
      EvaluateSkillTestParams(test: _currentTest!, answers: event.answers),
    );

    result.fold(
      (failure) =>
          emit(SkillError(message: failure.message, code: failure.code)),
      (testResult) {
        emit(
          SkillTestEvaluated(
            result: testResult,
            skillsTested: _currentTest!.skillsCovered,
          ),
        );
        _currentTest = null;
      },
    );
  }

  void _onResetSkillState(ResetSkillState event, Emitter<SkillState> emit) {
    _currentTest = null;
    emit(const SkillInitial());
  }
}
