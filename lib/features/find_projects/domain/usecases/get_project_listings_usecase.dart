import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_listing_entity.dart';
import '../repositories/find_projects_repository.dart';

class GetProjectListingsUseCase
    implements UseCase<List<ProjectListingEntity>, NoParams> {
  final FindProjectsRepository repository;

  GetProjectListingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProjectListingEntity>>> call(NoParams params) {
    return repository.getProjectListings();
  }
}
