import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_entities.dart';
import '../repositories/ai_chat_repository.dart';

class ChatWithAIUseCase implements UseCase<String, ChatWithAIParams> {
  final AIChatRepository repository;

  ChatWithAIUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ChatWithAIParams params) async {
    return await repository.sendMessage(
      message: params.message,
      chatHistory: params.chatHistory,
      context: params.context,
    );
  }

  Stream<Either<Failure, String>> stream(ChatWithAIParams params) {
    return repository.streamMessage(
      message: params.message,
      chatHistory: params.chatHistory,
      context: params.context,
    );
  }
}

class ChatWithAIParams extends Equatable {
  final String message;
  final List<ChatMessage> chatHistory;
  final ChatContext context;

  const ChatWithAIParams({
    required this.message,
    required this.chatHistory,
    required this.context,
  });

  @override
  List<Object?> get props => [message, chatHistory, context];
}
