import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/community_repository.dart';

class VotePostUseCase implements UseCase<void, VotePostParams> {
  final CommunityRepository repository;

  VotePostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VotePostParams params) {
    return repository.votePost(
      postId: params.postId,
      userId: params.userId,
      voteType: params.voteType,
    );
  }
}

class VotePostParams extends Equatable {
  final String postId;
  final String userId;
  final String voteType;

  const VotePostParams({
    required this.postId,
    required this.userId,
    required this.voteType,
  });

  @override
  List<Object?> get props => [postId, userId, voteType];
}
