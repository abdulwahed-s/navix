part of 'ai_chat_bloc.dart';

abstract class AIChatState extends Equatable {
  const AIChatState();

  @override
  List<Object?> get props => [];
}

class AIChatInitial extends AIChatState {
  const AIChatInitial();
}

class AIChatLoaded extends AIChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final ChatContext context;

  const AIChatLoaded({
    required this.messages,
    required this.isLoading,
    required this.context,
  });

  @override
  List<Object?> get props => [messages, isLoading, context];
}

class AIChatError extends AIChatState {
  final String message;
  final List<ChatMessage> previousMessages;
  final ChatContext context;

  const AIChatError({
    required this.message,
    required this.previousMessages,
    required this.context,
  });

  @override
  List<Object?> get props => [message, previousMessages, context];
}
