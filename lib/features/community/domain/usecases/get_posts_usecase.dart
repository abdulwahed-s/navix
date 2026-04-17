import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/community_repository.dart';

class GetPostsUseCase implements UseCase<List<PostEntity>, GetPostsParams> {
  final CommunityRepository repository;

  GetPostsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetPostsParams params) {
    return repository.getPosts(
      sortType: params.sortType,
      limit: params.limit,
      lastDocument: params.lastDocument,
      currentUserId: params.currentUserId,
    );
  }
}

class GetPostsParams extends Equatable {
  final PostSortType sortType;
  final int limit;
  final DocumentSnapshot? lastDocument;
  final String currentUserId;

  const GetPostsParams({
    required this.sortType,
    this.limit = 20,
    this.lastDocument,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [sortType, limit, lastDocument, currentUserId];
}
