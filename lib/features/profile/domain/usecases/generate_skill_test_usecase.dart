import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/skill_test_model.dart';
import '../repositories/skill_repository.dart';

class GenerateSkillTestParams extends Equatable {
  final List<String> skillNames;

  const GenerateSkillTestParams({required this.skillNames});

  @override
  List<Object?> get props => [skillNames];
}

class GenerateSkillTestUseCase {
  final SkillRepository repository;

  GenerateSkillTestUseCase(this.repository);

  Future<Either<Failure, SkillTestModel>> call(
    GenerateSkillTestParams params,
  ) async {
    if (params.skillNames.isEmpty) {
      return const Left(
        ValidationFailure(
          message: 'No skills selected for testing',
          code: 'no-skills',
        ),
      );
    }

    return repository.generateSkillTest(params.skillNames);
  }
}
