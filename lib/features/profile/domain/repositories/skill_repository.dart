import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/skill_test_model.dart';
import '../entities/skill_entity.dart';

abstract class SkillRepository {
  Future<Either<Failure, SkillEntity>> validateCustomSkill(String skillName);

  Future<Either<Failure, SkillTestModel>> generateSkillTest(
    List<String> skillNames,
  );

  Future<Either<Failure, SkillTestResult>> evaluateSkillTest({
    required SkillTestModel test,
    required Map<String, String> answers,
  });
}
