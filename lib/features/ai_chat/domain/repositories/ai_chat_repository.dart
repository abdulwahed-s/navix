import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/chat_entities.dart';

abstract class AIChatRepository {
  Future<Either<Failure, String>> sendMessage({
    required String message,
    required List<ChatMessage> chatHistory,
    required ChatContext context,
  });

  Stream<Either<Failure, String>> streamMessage({
    required String message,
    required List<ChatMessage> chatHistory,
    required ChatContext context,
  });
}
