import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/skill_model.dart';
import '../entities/skill_entity.dart';
import '../entities/skill_status.dart';
import '../repositories/skill_repository.dart';

class AddSkillParams extends Equatable {
  final String skillName;

  final bool isPredefined;

  const AddSkillParams({required this.skillName, required this.isPredefined});

  @override
  List<Object?> get props => [skillName, isPredefined];
}

class AddSkillUseCase {
  final SkillRepository repository;

  AddSkillUseCase(this.repository);

  Future<Either<Failure, SkillEntity>> call(AddSkillParams params) async {
    if (params.isPredefined) {
      return Right(
        SkillModel(
          skillName: params.skillName,
          status: SkillStatus.approved,
          isVerified: false,
        ),
      );
    }

    return repository.validateCustomSkill(params.skillName);
  }
}
