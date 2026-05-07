import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../entities/connection_status.dart';

abstract class UserDiscoveryRepository {
  Future<Either<Failure, List<ProfileEntity>>> searchUsers({
    required String query,
    List<String>? skills,
    int? limit,
    String? lastUserId,
  });

  Future<Either<Failure, List<ProfileEntity>>> filterBySkills({
    required List<String> skills,
    int? limit,
  });

  Future<Either<Failure, void>> sendConnectionRequest({
    required String toUserId,
    String? message,
  });

  Future<Either<Failure, void>> sendProjectInvitation({
    required String toUserId,
    required String projectId,
    required String projectName,
  });

  Future<Either<Failure, ProfileEntity>> getUserProfile(String userId);

  Future<Either<Failure, Map<String, ConnectionStatus>>> getConnectionStatuses(
    List<String> userIds,
  );

  Future<Either<Failure, void>> acceptConnectionRequest({
    required String requestId,
  });

  Future<Either<Failure, void>> rejectConnectionRequest({
    required String requestId,
  });

  Future<Either<Failure, void>> cancelConnectionRequest({
    required String toUserId,
  });

  Future<Either<Failure, void>> removeConnection({required String userId});
}
