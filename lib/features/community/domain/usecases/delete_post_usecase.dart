import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/community_repository.dart';

class DeletePostUseCase implements UseCase<void, DeletePostParams> {
  final CommunityRepository repository;

  DeletePostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePostParams params) {
    return repository.deletePost(params.postId);
  }
}

class DeletePostParams extends Equatable {
  final String postId;

  const DeletePostParams({required this.postId});

  @override
  List<Object?> get props => [postId];
}
