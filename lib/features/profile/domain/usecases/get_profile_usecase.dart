import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase implements UseCase<ProfileEntity?, GetProfileParams> {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  @override
  Future<Either<Failure, ProfileEntity?>> call(GetProfileParams params) {
    return repository.getProfile(params.userId);
  }
}

class GetProfileParams extends Equatable {
  final String userId;

  const GetProfileParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
