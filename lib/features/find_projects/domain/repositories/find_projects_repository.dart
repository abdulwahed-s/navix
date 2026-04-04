import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/open_role.dart';
import '../entities/project_join_request_entity.dart';
import '../entities/project_listing_entity.dart';

abstract class FindProjectsRepository {
  Future<Either<Failure, List<ProjectListingEntity>>> getProjectListings();

  Future<Either<Failure, void>> publishProjectListing({
    required String projectId,
    required String projectName,
    required String projectDescription,
    required String leaderId,
    String? leaderMessage,
    required List<OpenRole> openRoles,
  });

  Future<Either<Failure, void>> removeProjectListing({
    required String listingId,
  });

  Future<Either<Failure, ProjectListingEntity?>> getListingForProject({
    required String projectId,
  });

  Future<Either<Failure, void>> applyToProject({
    required String listingId,
    required String projectId,
    required String leaderId,
    required String roleName,
    String? message,
  });

  Future<Either<Failure, List<ProjectJoinRequestEntity>>>
  getJoinRequestsForProject({required String projectId});

  Future<Either<Failure, void>> respondToJoinRequest({
    required String requestId,
    required bool accepted,
    required String projectId,
    required String applicantId,
    required String projectName,
  });
}
