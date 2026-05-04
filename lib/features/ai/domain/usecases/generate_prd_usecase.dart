import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/prd_entity.dart';
import '../repositories/ai_repository.dart';

class GeneratePrdUseCase implements UseCase<PrdEntity, GeneratePrdParams> {
  final AIRepository repository;

  GeneratePrdUseCase(this.repository);

  @override
  Future<Either<Failure, PrdEntity>> call(GeneratePrdParams params) {
    return repository.generatePrd(params);
  }
}
