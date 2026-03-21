import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class CreateProfileUseCase implements UseCase<ProfileEntity, ProfileEntity> {
  final ProfileRepository repository;

  CreateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity>> call(ProfileEntity params) {
    return repository.createProfile(params);
  }
}
