part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ConversationEvent {
  final String conversationId;

  const LoadMessages({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

class SubscribeToMessages extends ConversationEvent {
  final String conversationId;
  final String currentUserId;

  const SubscribeToMessages({
    required this.conversationId,
    required this.currentUserId,
  });

  @override
  List<Object?> get props => [conversationId, currentUserId];
}

class MessagesUpdated extends ConversationEvent {
  final List<MessageEntity> messages;

  const MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class SendMessage extends ConversationEvent {
  final String text;

  const SendMessage({required this.text});

  @override
  List<Object?> get props => [text];
}
