import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<Either<Failure, List<ConversationEntity>>> getConversations(
    String userId,
  );

  Stream<List<ConversationEntity>> watchConversations(String userId);

  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  });

  Future<Either<Failure, List<MessageEntity>>> getMessages(
    String conversationId,
  );

  Stream<List<MessageEntity>> watchMessages(String conversationId);

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  });

  Future<Either<Failure, MessageEntity>> sendSharedPost({
    required String conversationId,
    required String senderId,
    required String senderName,
    required SharedPostData sharedPost,
  });

  Future<Either<Failure, MessageEntity>> sendSharedSurvey({
    required String conversationId,
    required String senderId,
    required String senderName,
    required SharedSurveyData sharedSurvey,
  });

  Future<Either<Failure, void>> markAsRead({
    required String conversationId,
    required String userId,
  });

  Future<Either<Failure, void>> deleteConversation(String conversationId);

  Future<Either<Failure, List<ProfileEntity>>> getConnectedUsers(String userId);
}
