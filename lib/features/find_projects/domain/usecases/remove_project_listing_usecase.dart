import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/find_projects_repository.dart';

class RemoveProjectListingUseCase
    implements UseCase<void, RemoveProjectListingParams> {
  final FindProjectsRepository repository;

  RemoveProjectListingUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveProjectListingParams params) {
    return repository.removeProjectListing(listingId: params.listingId);
  }
}

class RemoveProjectListingParams extends Equatable {
  final String listingId;

  const RemoveProjectListingParams({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}
