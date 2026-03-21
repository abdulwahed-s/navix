import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/skill_test_model.dart';
import '../repositories/skill_repository.dart';

class EvaluateSkillTestParams extends Equatable {
  final SkillTestModel test;

  final Map<String, String> answers;

  const EvaluateSkillTestParams({required this.test, required this.answers});

  @override
  List<Object?> get props => [test, answers];
}

class EvaluateSkillTestUseCase {
  final SkillRepository repository;

  EvaluateSkillTestUseCase(this.repository);

  Future<Either<Failure, SkillTestResult>> call(
    EvaluateSkillTestParams params,
  ) async {
    final unansweredQuestions = params.test.questions
        .where(
          (q) =>
              !params.answers.containsKey(q.id) ||
              params.answers[q.id]?.trim().isEmpty == true,
        )
        .toList();

    if (unansweredQuestions.isNotEmpty) {
      return Left(
        ValidationFailure(
          message:
              'Please answer all questions (${unansweredQuestions.length} unanswered)',
          code: 'incomplete-test',
        ),
      );
    }

    return repository.evaluateSkillTest(
      test: params.test,
      answers: params.answers,
    );
  }
}
