part of 'conversation_bloc.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

class ConversationLoaded extends ConversationState {
  final List<MessageEntity> messages;
  final String conversationId;

  const ConversationLoaded({
    required this.messages,
    required this.conversationId,
  });

  @override
  List<Object?> get props => [messages, conversationId];
}

class MessageSent extends ConversationState {
  final ConversationLoaded previousState;

  const MessageSent(this.previousState);

  @override
  List<Object?> get props => [previousState];
}

class ConversationError extends ConversationState {
  final String message;

  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}
