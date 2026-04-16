import 'package:equatable/equatable.dart';

enum VoteTargetType { post, comment }

class VoteEntity extends Equatable {
  final String userId;
  final String targetId;
  final VoteTargetType targetType;
  final String voteType;
  final DateTime createdAt;

  const VoteEntity({
    required this.userId,
    required this.targetId,
    required this.targetType,
    required this.voteType,
    required this.createdAt,
  });

  bool get isUpvote => voteType == 'up';

  bool get isDownvote => voteType == 'down';

  @override
  List<Object?> get props => [
    userId,
    targetId,
    targetType,
    voteType,
    createdAt,
  ];
}
